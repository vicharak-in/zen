# loader.py - loads a bitstream file from the RP2350's flash into the Trion FPGA (passive SPI configuration, sent by a PIO state machine)
# load("pacman.hex.bin") configures the FPGA and returns True when CDONE went high
import machine
import rp2
import utime

# Timing of the configuration sequence (microseconds) and trailing clocks after the file
T_CRESET_US = 10
T_DMIN_US = 10
DUMMY_BYTES = 10
# Wait for CDONE (polled every 200 us, up to 100 ms) and the short pause after it before the link pins are used (ms)
CDONE_TRIES = 500
SETTLE_MS = 5

# Configuration pins of the Zen board: clock 1 (CCK), data in 0 (CDI), unused data out 3
PIN_CCK, PIN_CDI, PIN_MISO = 1, 0, 3
# PIO state machine used for the fast path (8 = first state machine of PIO2) and its clock: 4 PIO cycles per bit, so 75 MHz = 18.75 Mbit/s
SM_ID = 8
SM_FREQ = 75_000_000
# Slave-select strap (low = passive mode), the done flag from the FPGA and the FPGA reset
ss = machine.Pin(2, machine.Pin.OUT, value=0)
cdone = machine.Pin(4, machine.Pin.IN, machine.Pin.PULL_UP)
creset = machine.Pin(5, machine.Pin.OUT, value=1)
# File read buffer, made once so every load reuses it
_buf = bytearray(4096)
_mv = memoryview(_buf)


# PIO program: shifts one data bit out on CDI (side-set drives CCK low), then raises CCK; the data is stable before the rising edge (SPI mode 0, MSB first)
@rp2.asm_pio(out_init=rp2.PIO.OUT_LOW, sideset_init=rp2.PIO.OUT_LOW, out_shiftdir=rp2.PIO.SHIFT_LEFT, autopull=True, pull_thresh=8)
def _cfg_clock():
    # Data bit out, clock low, hold 2 cycles
    out(pins, 1).side(0)[1]
    # Clock high, hold 2 cycles
    nop().side(1)[1]


# Send the whole file with the PIO state machine; returns the number of bytes sent
def _send_pio(name):
    # State machine on CDI (data) with CCK as side-set pin
    sm = rp2.StateMachine(SM_ID, _cfg_clock, freq=SM_FREQ, out_base=machine.Pin(PIN_CDI), sideset_base=machine.Pin(PIN_CCK))
    sm.active(1)
    n = 0
    with open(name, 'rb') as f:
        while True:
            # Read up to 4 KB and push it into the FIFO (blocks while the FIFO is full)
            k = f.readinto(_buf)
            if not k:
                break
            sm.put(_mv[:k], 24)
            n += k
    # Extra clocks let the FPGA finish starting up
    sm.put(bytes(DUMMY_BYTES), 24)
    # Wait until the FIFO is empty and the last byte has been shifted out
    while sm.tx_fifo():
        pass
    utime.sleep_us(10)
    sm.active(0)
    return n


# Same job with the slow software SPI; used only when the PIO path is not available
def _send_soft(name):
    # The Zen Link driver takes GPIO 0-3 over after fpga.init(), so claim the pins again for every load
    spi = machine.SoftSPI(baudrate=16_000_000, polarity=0, phase=0,
                          sck=machine.Pin(PIN_CCK), mosi=machine.Pin(PIN_CDI), miso=machine.Pin(PIN_MISO))
    n = 0
    with open(name, 'rb') as f:
        while True:
            k = f.readinto(_buf)
            if not k:
                break
            spi.write(_mv[:k])
            n += k
    spi.write(bytes(DUMMY_BYTES))
    return n


# Send the file to the FPGA; returns True when CDONE is high afterwards
def load(name):
    t0 = utime.ticks_ms()
    # Strap low = passive mode, then a reset pulse latches the mode
    ss.init(machine.Pin.OUT, value=0)
    ss.value(0)
    creset.value(0)
    utime.sleep_us(T_CRESET_US)
    creset.value(1)
    utime.sleep_us(T_DMIN_US)
    # Fast path first; any problem with the state machine falls back to the software SPI (the reset pulse is repeated for a clean start)
    try:
        n = _send_pio(name)
        how = "pio"
    except Exception as e:
        print("N:pio failed (%s), using soft spi" % e)
        creset.value(0)
        utime.sleep_us(T_CRESET_US)
        creset.value(1)
        utime.sleep_us(T_DMIN_US)
        n = _send_soft(name)
        how = "soft"
    # Leave the clock and data pins low, as the software SPI did
    machine.Pin(PIN_CCK, machine.Pin.OUT, value=0)
    machine.Pin(PIN_CDI, machine.Pin.OUT, value=0)
    # CDONE can take a few ms to rise after the last clocks
    for _ in range(CDONE_TRIES):
        if cdone.value():
            break
        utime.sleep_us(200)
    # Short pause before the link pins are used (the caller also retries the link a few times)
    utime.sleep_ms(SETTLE_MS)
    print("N:loaded %s, %d bytes, CDONE = %d, %s, %d ms" % (name, n, cdone.value(), how, utime.ticks_diff(utime.ticks_ms(), t0)))
    return cdone.value() == 1
