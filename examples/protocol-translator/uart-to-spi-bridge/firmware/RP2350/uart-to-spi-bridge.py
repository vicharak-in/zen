# PORT of the Shrike uart_to_spi_bridge test script for the RP2350 on the Vicharak Zen 4.
# - shrike.flash() is gone: load the bitstream with Efinity (the FPGA is not flashed from MicroPython here).
# - The UART is set to UART1 on GPIO24 (TX) / GPIO25 (RX), wired to the FPGA pads GPIOL_00 (rx) and GPIOL_03 (tx).
# - SPI loopback: one jumper between header pads R-05 (mosi, GPIOR_05) and R-06 (miso, GPIOR_06). sclk = GPIOR_00, cs = GPIOR_01 are left unconnected.
# - Anything that pokes RP2040 registers with mem32 (I2C slave emulation) uses RP2040 addresses and needs the RP2350 addresses before it can work.

"""

File Name : uart-to-spi-bridge.py

Description:
MicroPython test program for the UART-to-SPI Bridge.

Sends 100 bytes to the FPGA through UART and
verifies that the same bytes are returned through
the SPI loopback path.

Pin Mapping:

UART:
FPGA GPIO14 (RX) -> UART TX 
FPGA GPIO15 (TX) -> UART RX 

SPI:
FPGA GPIO10 -> SCLK
FPGA GPIO11 -> CS
FPGA GPIO12 -> MOSI
FPGA GPIO13 -> MISO

Test Setup:

* RP2040 UART0 used as UART host
* GP16 connected to FPGA GPIO14 (RX)
* GP17 connected to FPGA GPIO15 (TX)
* FPGA GPIO12 (MOSI) connected to FPGA GPIO13 (MISO) using external jumper

Clock:
SPI Clock = 1 MHz

Baud Rate:
115200

Expected:
TX Byte = RX Byte

---

"""


from machine import UART, Pin
import time

uart = UART(1,
    baudrate=115200,
    tx=Pin(24),
    rx=Pin(25)
)

print("UART-SPI LOOPBACK TEST")
print("--------------------------------")

errors = 0

for i in range(100):

    tx_byte = i & 0xFF

    print("Sending  : 0x{:02X}".format(tx_byte))

    uart.write(bytes([tx_byte]))

    time.sleep_ms(100)

    if uart.any():

        rx = uart.read()

        if rx is not None and len(rx) > 0:

            rx_byte = rx[0]

            print("Received : 0x{:02X}".format(rx_byte))

            if rx_byte != tx_byte:
                errors += 1
                print("ERROR")

        else:
            errors += 1
            print("READ ERROR")

    else:
        errors += 1
        print("NO RESPONSE")

print("--------------------------------")
print("Test Complete")
print("Errors =", errors)

if errors == 0:
    print("PASS")
else:
    print("FAIL")

