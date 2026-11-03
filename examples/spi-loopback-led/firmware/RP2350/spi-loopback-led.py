# spi-loopback-led.py - MicroPython for the RP2350 on the Zen 4: sends 0xAB and 0xFF to the FPGA and prints the byte that comes back.
# Ported from the Shrike example. The SPI pins and the reset pin are gone: the bytes go through the Zen Link (zen_spi.py, copy it to the board too)
# and the FPGA resets itself at power-on (btn1 on the Zen resets it as well). Load spi-loopback-led into the FPGA first.

import time
from zen_spi import ZenSPI

spi = ZenSPI()

def spi_exchange(byte_to_send):
    """Select the FPGA, send one byte, release, return the byte that came back."""
    return spi.exchange(byte_to_send)

print("Starting Zen Link loopback...")

while True:
    for val in [0xAB, 0xFF]:
        resp = spi_exchange(val)
        print("Sent 0x{:02X}, Received 0x{:02X}".format(val, resp))
        time.sleep(1)
