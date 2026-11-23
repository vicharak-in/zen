# usb-to-spi.py - MicroPython for the RP2350 on the Zen 4, ported from the Shrike example: the SPI link and the flash call are replaced by the Zen Link byte port
# (zen_spi.py, copy it to the board too). Bytes read from the USB serial port go out as SPI transfers on the FPGA header pads; the replies are written back to USB.
# usb-to-spi.py -- RP2040 firmware for the USB-to-SPI bridge (run with Thonny).
#
# Acts as the SPI master on the fixed RP2040 <-> FPGA link. It reads one byte at
# a time from the USB serial port and forwards it to the FPGA over SPI; the FPGA
# returns the external slave's reply (one transfer behind) which is written back
# to USB.
#
# Pin config is kept in CONFIG below so it can be adjusted per board variant.

import sys
from zen_spi import ZenSPI

# Zen Link byte port: the FPGA design is loaded with Efinity, not flashed from here
spi = ZenSPI()


def spi_transfer(value):
    """Send one byte to the FPGA and return the byte shifted back."""
    return spi.exchange(value)


# Bridge loop: USB byte in -> SPI -> USB byte out.
while True:
    raw = sys.stdin.buffer.read(1)
    if raw:
        reply = spi_transfer(raw[0])
        sys.stdout.buffer.write(bytes([reply]))
