# uart-to-i2c.py - MicroPython for the RP2350 on the Zen 4: drives the UART -> I2C bridge with a real I2C sensor at address 0x50 wired to header pads R-05 (SDA) and R-06 (SCL).
# Each byte sent on UART1 (GPIO24 TX / GPIO25 RX, already wired to the FPGA) is written to the sensor; the FPGA reads one byte back and returns it on the UART (0xEE means the sensor NACKed).
# SDA and SCL need pull-up resistors to 3.3 V.  Run with:  python -m mpremote run uart-to-i2c.py

from machine import Pin, UART
import time

# UART1 to the FPGA (115200 8N1)
uart = UART(1, baudrate=115200, tx=Pin(24), rx=Pin(25))

# Bytes to write to the sensor (edit to match your sensor's registers)
to_send = [0x00, 0x01, 0x02, 0x03]

while uart.any():
    uart.read()

for v in to_send:
    uart.write(bytes([v]))                       # byte -> FPGA -> I2C write, then I2C read
    t0 = time.ticks_ms()
    got = None
    while time.ticks_diff(time.ticks_ms(), t0) < 200:
        if uart.any():
            got = uart.read(1)[0]
            break
    if got is None:
        print("0x%02X -> no reply" % v)
    elif got == 0xEE:
        print("0x%02X -> 0xEE (NACK or no sensor)" % v)
    else:
        print("0x%02X -> 0x%02X" % (v, got))
