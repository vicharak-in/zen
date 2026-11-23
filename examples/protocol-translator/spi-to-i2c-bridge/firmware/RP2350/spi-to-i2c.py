# spi-to-i2c.py - MicroPython for the RP2350 on the Zen 4: drives the SPI -> I2C bridge with a real I2C sensor at address 0x50 wired to header pads R-05 (SDA) and R-06 (SCL).
# SPI needs no wires: GPIO2 (SCK), GPIO3 (MOSI), GPIO0 (MISO), GPIO1 (CS) are Zen link wires to the FPGA. Each command byte is written to the sensor, then one byte is read back
# and returned by a second SPI transfer (0xEE means the sensor NACKed). SDA and SCL need pull-up resistors to 3.3 V.
# Run with:  python -m mpremote run spi-to-i2c.py

from machine import Pin, SPI
import time

# SPI0, mode 0, 1 MHz, on the Zen link wires; chip select is a plain GPIO
spi = SPI(0, baudrate=1000000, polarity=0, phase=0, sck=Pin(2), mosi=Pin(3), miso=Pin(0))
cs = Pin(1, Pin.OUT, value=1)

tx = bytearray(1)   # one byte to send
rx = bytearray(1)   # one byte received

# Bytes to write to the sensor (edit to match your sensor's registers)
to_send = [0x00, 0x01, 0x02, 0x03]

for v in to_send:
    tx[0] = v
    cs.value(0)
    spi.write(tx)               # command byte -> FPGA -> I2C write, then I2C read
    cs.value(1)
    time.sleep_ms(20)           # wait for the I2C transfers
    tx[0] = 0x00
    cs.value(0)
    spi.write_readinto(tx, rx)  # clock the reply out
    cs.value(1)
    if rx[0] == 0xEE:
        print("0x%02X -> 0xEE (NACK or no sensor)" % v)
    else:
        print("0x%02X -> 0x%02X" % (v, rx[0]))
