# PORT of the Shrike i2c_to_spi_bridge test script for the RP2350 on the Vicharak Zen 4. One jumper is needed: header pad R-05 (spi_mosi) to R-06 (spi_miso).
# - shrike.flash() is gone: load the bitstream with Efinity (the FPGA is not flashed from MicroPython here).
# - I2C: software I2C on RP2350 GPIO0 (SDA) / GPIO1 (SCL), which are Zen link wires to the FPGA pads GPIOL_04 (sda) and GPIOL_02 (scl), with the internal pull-ups on. No wires for I2C.
# - SPI loopback: the FPGA SPI master reads back its own output through the jumper R-05 to R-06, so each byte written comes back on the next read.
# - The wait for the reply has a timeout, so a missing jumper ends the test with FAIL instead of hanging.

"""
i2c_spi_protocol_bridge.py

MicroPython test application for the FPGA-based
I2C to SPI Protocol Bridge.

The script sends 100 sequential bytes to the FPGA
over I2C and reads back one byte after each
transaction.

Current Test Configuration:
- FPGA configured as I2C slave
- FPGA configured as SPI master
- SPI loopback by a jumper from MOSI to MISO
- Expected response: the byte that was sent

Pin Mapping (Zen 4):
GPIO0 -> FPGA SDA (pad GPIOL_04)
GPIO1 -> FPGA SCL (pad GPIOL_02)
Jumper: header pad R-05 (spi_mosi) to R-06 (spi_miso)

I2C Address:
0x32
"""

from machine import SoftI2C, Pin
import time

# Open-drain pins with the internal pull-ups on (GPIO0 = SDA, GPIO1 = SCL)
sda_pin = Pin(0, Pin.OPEN_DRAIN, Pin.PULL_UP)
scl_pin = Pin(1, Pin.OPEN_DRAIN, Pin.PULL_UP)
i2c = SoftI2C(scl=scl_pin, sda=sda_pin, freq=100000)

passed = 0
failed = 0

print()
print("100 BYTE I2C-SPI BRIDGE TEST")
print("--------------------------------")

for value in range(100):

    tx = bytes([value])

    i2c.writeto(0x32, tx)

    t0 = time.ticks_ms()
    while True:

        rx = i2c.readfrom(0x32, 1)

        # 0xFF indicates response not ready
        if rx != b'\xFF':
            break

        # Give up after one second (jumper missing or bridge not answering)
        if time.ticks_diff(time.ticks_ms(), t0) > 1000:
            break

    received = rx[0]

    if received == value:

        passed += 1

        print(
            "PASS",
            value,
            "TX=",
            hex(value),
            "RX=",
            hex(received)
        )

    else:

        failed += 1

        print(
            "FAIL",
            value,
            "TX=",
            hex(value),
            "RX=",
            hex(received)
        )

print("--------------------------------")
print("SUMMARY")
print("Passed :", passed)
print("Failed :", failed)

if failed == 0:
    print("SUCCESS")
else:
    print("FAILURE")
