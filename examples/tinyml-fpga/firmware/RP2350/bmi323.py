# bmi323.py - MicroPython driver for the Bosch BMI323 6-axis IMU over I2C (accelerometer + gyroscope, raw readings only).
# Register facts (checked against the Linux kernel driver, drivers/iio/imu/bmi323): CHIP_ID 0x00 (low byte 0x43), ACC_DATA X/Y/Z 0x03..0x05,
# GYR_DATA X/Y/Z 0x06..0x08, ACC_CONF 0x20, GYR_CONF 0x21, CMD 0x7E (0xDEAF = soft reset). Registers are 16 bit little endian and every
# I2C read returns 2 dummy bytes first.

import time
from machine import Pin, SoftI2C

# Register addresses
CHIP_ID, ERR_REG, STATUS, ACC_DATA, GYR_DATA, ACC_CONF, GYR_CONF, CMD = 0x00, 0x01, 0x02, 0x03, 0x06, 0x20, 0x21, 0x7E
# CONF word = mode<<12 | avg<<8 | range<<4 | odr. mode 7 = high performance, odr 7 = 50 Hz
ACC_CONF_4G_50HZ = 0x7017        # accelerometer: +-4 g (code 1), 50 Hz
GYR_CONF_500DPS_50HZ = 0x7027    # gyroscope: +-500 deg/s (code 2), 50 Hz
# Scale factors: raw int16 -> g and raw int16 -> deg/s
ACC_G_PER_LSB = 4.0 / 32768
GYR_DPS_PER_LSB = 500.0 / 32768


def make_i2c(scl, sda, freq=400000):
    """Software I2C on any two GPIO numbers (no need to match the RP2350 hardware I2C pin groups)."""
    return SoftI2C(scl=Pin(scl), sda=Pin(sda), freq=freq)


def scan(i2c):
    """Print the I2C addresses that answer. The BMI323 should show up as 0x68 (SDO low) or 0x69 (SDO high)."""
    found = i2c.scan()
    print("I2C devices:", [hex(a) for a in found])
    return found


class BMI323:
    """One sensor on an I2C bus."""

    def __init__(self, i2c, addr=0x68):
        self.i2c = i2c
        self.addr = addr
        self.i2c.readfrom_mem(addr, CHIP_ID, 4)                  # first read after power-up can be ignored by the chip, so do a throw-away one
        cid = self._rd(CHIP_ID, 1)[0]
        if cid & 0xFF != 0x43:
            raise OSError("not a BMI323: chip id word 0x%04X (expected 0x..43)" % cid)
        for attempt in range(5):                                 # start the sensor, and start again if it does not deliver real samples
            self.i2c.writeto_mem(addr, CMD, b"\xAF\xDE")         # soft reset (0xDEAF little endian)
            time.sleep_ms(100)
            self._wr(ACC_CONF, ACC_CONF_4G_50HZ)                 # enable accelerometer
            self._wr(GYR_CONF, GYR_CONF_500DPS_50HZ)             # enable gyroscope
            time.sleep_ms(200)                                   # the gyroscope needs some time before its first sample
            good = 0
            for _ in range(10):                                  # count valid readings over about 0.3 s
                if self.read() is not None:
                    good += 1
                time.sleep_ms(30)
            if good >= 8:
                return
        raise OSError("BMI323 does not deliver valid samples (raw 0x8000): power-cycle the sensor and check 3.3V")

    def _rd(self, reg, nwords):
        """Read nwords 16 bit registers starting at reg; returns a list of unsigned 16 bit values."""
        raw = self.i2c.readfrom_mem(self.addr, reg, 2 + 2 * nwords)   # 2 dummy bytes, then the data
        return [raw[2 + 2 * i] | (raw[3 + 2 * i] << 8) for i in range(nwords)]

    def _wr(self, reg, val):
        """Write one 16 bit register."""
        self.i2c.writeto_mem(self.addr, reg, bytes((val & 0xFF, val >> 8)))

    def read(self):
        """One burst read: returns (ax, ay, az, gx, gy, gz) with acceleration in g and rotation in deg/s, or None if the chip reports
        'no valid sample' (raw value 0x8000) on any axis."""
        w = self._rd(ACC_DATA, 6)
        if 0x8000 in w:
            return None
        s = [v - 65536 if v > 32767 else v for v in w]
        return (s[0] * ACC_G_PER_LSB, s[1] * ACC_G_PER_LSB, s[2] * ACC_G_PER_LSB,
                s[3] * GYR_DPS_PER_LSB, s[4] * GYR_DPS_PER_LSB, s[5] * GYR_DPS_PER_LSB)
