# spi-to-usb.py - MicroPython for the RP2350 on the Zen 4, ported from the Shrike example: the SPI link and the flash call are replaced by the Zen Link byte port
# (zen_spi.py, copy it to the board too). Polls the FPGA every 200 ms and prints each new byte the Arduino sent.
# read_arduino.py -- RP2040 firmware to read bytes sent by the Arduino master.
#
# Run this in Thonny (MicroPython interpreter on the Shrike board). It flashes
# the FPGA bitstream, then polls the FPGA over SPI every 200 ms by sending a
# dummy byte. The FPGA returns the last byte it received from the Arduino.
#
# The script prints a live table showing what the Arduino is sending so you can
# verify the full data path: Arduino -> FPGA -> RP2040.

import time
from zen_spi import ZenSPI

# Zen Link byte port: the FPGA design is loaded with Efinity, not flashed from here
spi = ZenSPI()


def spi_read():
    """Send a dummy byte to the FPGA and return the Arduino's last byte."""
    return spi.exchange(0x00)


# Print header.
print()
print("=== Reading bytes from Arduino via FPGA ===")
print()
print("  #  | Arduino Byte")
print("  ---|-------------")

count = 0
prev = None

while True:
    byte = spi_read()

    # Only print when the value changes (avoids flooding the terminal).
    if byte != prev:
        count += 1
        print("  {:>3d} |  0x{:02X}".format(count, byte))
        prev = byte

    time.sleep(0.2)