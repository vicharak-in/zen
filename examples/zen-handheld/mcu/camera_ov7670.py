# camera_ov7670.py - OV7670 camera (module WITHOUT FIFO) on the RP2350: sets the sensor to QVGA RGB565 and grabs one frame at a time with a PIO state machine and DMA
# Wiring (change the numbers below if you wire it differently). The 3V3 and GND wires go to the board's 3V3 and GND:
#   D0..D7 -> GPIO 6..13 (8 pins in a row)   PCLK -> GPIO 14   HREF -> GPIO 16   VSYNC -> GPIO 15 (measured on this board: the HS wire is on GPIO 16, the VS wire on GPIO 15)
#   XCLK <- GPIO 21 (the RP2350 makes the camera clock)   SIOC -> GPIO 23   SIOD -> GPIO 22   RESET -> 3V3   PWDN -> GND
# GPIO 21 was the TFT reset wire: move that wire to 3V3 and set PIN_RST = None in spi_display.py (the panel then resets itself at power-up).
import time
import rp2
import machine
from machine import Pin, PWM, SoftI2C

# Camera pins on the RP2350
PIN_D0 = 6
PIN_PCLK = 14
PIN_HREF = 16
PIN_VSYNC = 15
PIN_XCLK = 21
PIN_SIOC = 23
PIN_SIOD = 22
# Camera clock in Hz (10 to 48 MHz allowed; 15 MHz gives roughly 18 frames per second)
XCLK_HZ = 20_000_000
# Picture size the sensor is set to and the bytes it sends (2 bytes per pixel)
W, H = 320, 240
LINE_BYTES = W * 2
FRAME_BYTES = LINE_BYTES * H
# PIO state machine for the capture (9 = second state machine of PIO2) and what DMA needs to read its output
SM_ID = 9
_PIO = SM_ID // 4
_IDX = SM_ID % 4
_RX_FIFO = (0x50200000, 0x50300000, 0x50400000)[_PIO] + 0x20 + 4 * _IDX
_RX_DREQ = _PIO * 8 + 4 + _IDX
# SCCB (I2C like) address of the OV7670
ADDR = 0x21

# Sensor settings: (register, value). QVGA, RGB565 full range, automatic exposure/gain/white balance, colour matrix, gamma
INIT = (
    (0x12, 0x14),  # COM7: QVGA size, RGB output
    (0x40, 0xD0),  # COM15: RGB565, full range 00..FF
    (0x3A, 0x04),  # TSLB: automatic window setting
    (0x0C, 0x04),  # COM3: enable down-sampling
    (0x3E, 0x19),  # COM14: scaling on, manual scaling, pixel clock divided by 2
    (0x70, 0x3A), (0x71, 0x35), (0x72, 0x11), (0x73, 0xF1), (0xA2, 0x02),  # scaling factors for QVGA
    (0x17, 0x16), (0x18, 0x04), (0x32, 0x24), (0x19, 0x02), (0x1A, 0x7A), (0x03, 0x0A),  # picture window
    (0x15, 0x00),  # COM10: VSYNC and HREF active high, normal pixel clock
    (0x13, 0xE7),  # COM8: automatic exposure, gain and white balance
    (0x14, 0x38),  # COM9: gain ceiling
    (0x4F, 0x80), (0x50, 0x80), (0x51, 0x00), (0x52, 0x22), (0x53, 0x5E), (0x54, 0x80), (0x58, 0x9E),  # colour matrix
    (0x3D, 0xC0),  # COM13: gamma on, UV adjust on
    (0x41, 0x38),  # COM16: automatic white balance gain, edge enhancement
    (0xB0, 0x84),  # reserved value that fixes the colours
)
# MVFP register: 0x01 is the reset value, 0x20 adds the mirror, 0x10 would flip upside down
REG_MVFP = 0x1E

# The camera clock and the SCCB bus, made by open()
_pwm = None
_i2c = None


# PIO program: wait for the end of VSYNC (a new frame starts), then for every line wait for HREF and read LINE_BYTES bytes, one per rising PCLK edge
# The PIO program cannot see the PIN_ names above, so its pin numbers are written out: VSYNC = GPIO 15, HREF = GPIO 16, PCLK = GPIO 14 (change them here too if you re-wire).
# The byte count minus one is pushed in by capture() as the first word. Every byte goes to the RX FIFO, where DMA collects it.
@rp2.asm_pio(in_shiftdir=rp2.PIO.SHIFT_LEFT, autopush=True, push_thresh=8)
def _grab():
    # y = bytes per line - 1, taken from the first word
    pull(block)
    mov(y, osr)
    # A new frame starts when VSYNC falls
    wait(1, gpio, 15)
    wait(0, gpio, 15)
    # Line loop: wait until HREF is high, load the byte counter
    label("line")
    wait(1, gpio, 16)
    mov(x, y)
    # Byte loop: sample D0..D7 on the rising PCLK edge, then wait for it to fall
    label("byte")
    wait(1, gpio, 14)
    in_(pins, 8)
    wait(0, gpio, 14)
    jmp(x_dec, "byte")
    # Line done: wait for HREF to drop, then the next line
    wait(0, gpio, 16)
    jmp("line")


# Write one sensor register
def write_reg(reg, val):
    _i2c.writeto(ADDR, bytes([reg, val]))


# Read one sensor register (SCCB needs a stop between the address and the read)
def read_reg(reg):
    _i2c.writeto(ADDR, bytes([reg]))
    return _i2c.readfrom(ADDR, 1)[0]


# Start the camera clock, check that the sensor answers and load its settings; raises RuntimeError with a hint when something is wrong
def open():
    global _pwm, _i2c
    # GPIO 21 cannot be the TFT reset and the camera clock at once
    try:
        import spi_display
        if spi_display.PIN_RST == PIN_XCLK:
            raise RuntimeError("Move TFT RST wire to 3V3 and set PIN_RST = None in spi_display.py")
    except ImportError:
        pass
    # Camera data and sync pins are inputs
    for p in range(PIN_D0, PIN_D0 + 8):
        Pin(p, Pin.IN)
    for p in (PIN_PCLK, PIN_HREF, PIN_VSYNC):
        Pin(p, Pin.IN)
    # The sensor needs its clock before it answers on SCCB
    _pwm = PWM(Pin(PIN_XCLK), freq=XCLK_HZ, duty_u16=32768)
    time.sleep_ms(50)
    _i2c = SoftI2C(scl=Pin(PIN_SIOC, Pin.OPEN_DRAIN, Pin.PULL_UP), sda=Pin(PIN_SIOD, Pin.OPEN_DRAIN, Pin.PULL_UP), freq=100_000)
    # The product ID register must read 0x76
    try:
        pid = read_reg(0x0A)
    except OSError:
        close()
        raise RuntimeError("OV7670 does not answer: check SIOC/SIOD, 3V3, GND, RESET to 3V3, PWDN to GND")
    if pid != 0x76:
        close()
        raise RuntimeError("Wrong camera ID 0x%02X (want 0x76)" % pid)
    # Reset the sensor, wait, then load the settings
    write_reg(0x12, 0x80)
    time.sleep_ms(100)
    for reg, val in INIT:
        write_reg(reg, val)
    write_reg(REG_MVFP, 0x01)
    # Let exposure and white balance settle
    time.sleep_ms(300)


# Mirror the picture left to right (on = True) or not
def mirror(on):
    write_reg(REG_MVFP, 0x21 if on else 0x01)


# Start grabbing one frame into buf in the background (PIO + DMA); returns a handle for finish(). The frame starts at the next VSYNC.
def start(buf):
    # State machine on D0..D7 at the full system clock
    sm = rp2.StateMachine(SM_ID, _grab, freq=machine.freq(), in_base=Pin(PIN_D0))
    # First word: bytes per line minus one
    sm.put(LINE_BYTES - 1)
    # DMA moves every captured byte from the FIFO into the buffer
    dma = rp2.DMA()
    ctrl = dma.pack_ctrl(size=0, inc_read=False, inc_write=True, treq_sel=_RX_DREQ)
    dma.config(read=_RX_FIFO, write=buf, count=FRAME_BYTES, ctrl=ctrl)
    dma.active(True)
    sm.active(1)
    return (sm, dma)


# Wait for the frame started by start() (give up after timeout_ms when the camera sends nothing); returns True when the whole frame arrived
def finish(handle, timeout_ms=400):
    sm, dma = handle
    t0 = time.ticks_ms()
    ok = True
    while dma.active():
        if time.ticks_diff(time.ticks_ms(), t0) > timeout_ms:
            ok = False
            dma.active(False)
            break
    sm.active(0)
    dma.close()
    return ok


# Grab one frame into buf (FRAME_BYTES long, RGB565 with the high byte first, ready for the TFT); returns True when the whole frame arrived
def capture(buf, timeout_ms=400):
    return finish(start(buf), timeout_ms)


# Stop the camera clock and release the pins
def close():
    global _pwm, _i2c
    if _pwm is not None:
        _pwm.deinit()
        _pwm = None
    _i2c = None
