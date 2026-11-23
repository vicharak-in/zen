# PORT of the Shrike i2c_to_uart_bridge test script for the RP2350 on the Vicharak Zen 4. No extra hardware or wires are needed.
# - shrike.flash() is gone: load the bitstream with Efinity (the FPGA is not flashed from MicroPython here).
# - UART1 on GPIO24 (TX) / GPIO25 (RX), wired to the FPGA pads GPIOL_00 (rx) and GPIOL_03 (tx).
# - I2C: software I2C on RP2350 GPIO0 (SDA) / GPIO1 (SCL), which are Zen link wires to the FPGA pads GPIOL_04 (sda) and GPIOL_02 (scl). The internal pull-ups of the RP2350
#   pins (and the weak pull-ups of the FPGA pads) are on, so no external resistors are needed. The RP2040 register poke of the Shrike script is gone.

# Board-only self-test : UART <-> I2C bridge (I2C_to_UART bitstream)
# -----------------------------------------------------------------
# Connect ONLY the Shrike-Lite over USB. Load the I2C_to_UART
# bitstream onto the FPGA first, then run this on the RP2040.
#
# The RP2040 plays the "external I2C master" (I2C1) AND the UART peer,
# so no extra hardware is needed. It checks BOTH directions of the
# bidirectional bridge and prints PASS/FAIL to the USB REPL.
#
#   Dir 1 (I2C -> UART): I2C master writes X to the FPGA(0x50);
#                        the FPGA forwards it out on UART; we read it.
#   Dir 2 (UART -> I2C): we send Y on UART; the FPGA buffers it;
#                        we read it back over I2C.
#
# Pins on the Zen 4: UART1 tx=GPIO24 rx=GPIO25 ; software I2C sda=GPIO0 scl=GPIO1

from machine import Pin, UART, SoftI2C
import time
import random

FPGA_ADDR = 0x50

uart = UART(1, baudrate=115200, tx=Pin(24), rx=Pin(25))

# Open-drain pins with the internal pull-ups on (GPIO0 = SDA, GPIO1 = SCL), so no external pull-up resistors are needed for a quick bench test
sda_pin = Pin(0, Pin.OPEN_DRAIN, Pin.PULL_UP)
scl_pin = Pin(1, Pin.OPEN_DRAIN, Pin.PULL_UP)
i2c = SoftI2C(scl=scl_pin, sda=sda_pin, freq=100000)

# quick presence check
try:
    devices = i2c.scan()
    print("I2C scan:", [hex(d) for d in devices])
    if FPGA_ADDR not in devices:
        print("WARNING: FPGA (0x50) not found on I2C. Check the bitstream / pull-ups.")
except Exception as e:
    print("I2C scan failed:", e)

if uart.any():
    uart.read()

vectors = [0x00, 0xFF, 0x55, 0xAA, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80]
vectors += [random.randint(0, 255) for _ in range(20)]

passes = 0
total = 0

print("\n=== UART <-> I2C bidirectional self-test ===\n")

print("-- Direction 1: I2C write -> UART out --")
for v in vectors:
    total += 1
    if uart.any():
        uart.read()
    try:
        i2c.writeto(FPGA_ADDR, bytes([v]))
    except OSError:
        print("  I2C write error for 0x%02X" % v)
        continue
    got = None
    t0 = time.ticks_ms()
    while time.ticks_diff(time.ticks_ms(), t0) < 50:
        if uart.any():
            got = uart.read(1)[0]
            break
    if got == v:
        passes += 1
    else:
        print("  FAIL  sent 0x%02X  got %s" % (v, got))

print("-- Direction 2: UART in -> I2C read --")
for v in vectors:
    total += 1
    uart.write(bytes([v]))
    time.sleep_ms(10)
    try:
        got = i2c.readfrom(FPGA_ADDR, 1)[0]
    except OSError:
        print("  I2C read error")
        continue
    if got == v:
        passes += 1
    else:
        print("  FAIL  sent 0x%02X  got 0x%02X" % (v, got))

print("\nPassed %d / %d" % (passes, total))
print("STATUS: SUCCESS" if passes == total else "STATUS: FAILURE")
