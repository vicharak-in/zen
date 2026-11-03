# i2c-led.py - MicroPython for the RP2350 on the Zen 4: type "on" or "off" to switch LED 1 through the FPGA's I2C slave (address 0x32).
# Ported from the Shrike example: the I2C wires are replaced by the Zen Link (zink_i2c.py, copy it to the board too), which drives SCL and SDA inside the FPGA,
# and the separate reset pin is gone (press btn1 on the Zen to reset the slave, or call fpga.write(0x10, 1); it also resets itself at power-on).

from zink_i2c import ZinkI2C
import time

# I2C master over the Zen Link (bit-banged through the FPGA, so the speed is set by the link)
i2c = ZinkI2C()

# Slave device I2C address (7-bit)
SLAVE_ADDR = 0x32

def write_byte(addr, value):
    """Write a single 8-bit value to an I2C slave."""
    i2c.writeto(addr, bytes([value]))

print("Devices found:", [hex(a) for a in i2c.scan()])
print("Type 'on' to send 0xAA or 'off' to send 0xFF")

while True:
    cmd = input("Enter command (on/off): ").strip().lower()
    if cmd == "on":
        write_byte(SLAVE_ADDR, 0xAA)
        print("Sent 0xAA (LED ON)")
    elif cmd == "off":
        write_byte(SLAVE_ADDR, 0xFF)
        print("Sent 0xFF (LED OFF)")
    else:
        print("Invalid command, type 'on' or 'off'")
    time.sleep(0.1)
