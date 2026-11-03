# multiplication.py - MicroPython for the RP2350 on the Zen 4, ported from the Shrike example: the SPI pins and the reset pin are replaced by the Zen Link byte port
# (zen_spi.py, copy it to the board too). Pushes 2 and 5, multiplies them on the FPGA and reads the result back.
"""
This code pushes 2 numbers in stack of FPGA, multiply them on FPGA
and get back the result over SPI.
"""

import time
from zen_spi import ZenSPI

# Zen Link byte port: the FPGA design is loaded with Efinity, not flashed from here
spi = ZenSPI()
spi.reset()
time.sleep(0.1)


def spi_exchange(byte_to_send):
    return spi.exchange(byte_to_send)


mul = [0x12, # Push 2
       0x15, # Push 5
       0x33, # Pop A (A = 5)
       0x34, # Pop B (A = 2)
       0xC2, # C = A * B (C = 5 * 2)
       0x32, # Push C
       0x20, # Pop
       0x00, # Stall
       ]

while True:    
    for val in mul:
        resp = spi_exchange(val)
        print(f"Sent 0x{val:02X}, Received 0x{resp:02X}")
        time.sleep(0.01)
        
    break