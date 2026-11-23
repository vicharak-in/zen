# zink_i2c.py - I2C master over the Zen Link (runs on the RP2350 of the Zen board).
# Replaces machine.I2C(0, ...) for designs whose FPGA side has a zl_i2c_pins block (register LINES at 0x100). The RP2350 drives SCL and SDA of the
# FPGA's I2C slave core through that register, one level change at a time, so the bus speed is set by the Zen Link and not by a clock.
#
#   i2c = ZinkI2C()
#   i2c.scan()                      list of 7-bit addresses that answer
#   i2c.writeto(0x32, b"\xAA")      write bytes to a slave
#   i2c.readfrom(0x32, 1)           read bytes from a slave

import fpga

# Register address of zl_i2c_pins
LINES = 0x100
# Bit masks of the pull-low bits and the level bits
SCL_LOW, SDA_LOW, SCL_IN, SDA_IN = 0x01, 0x02, 0x01, 0x02


class ZinkI2C:
    def __init__(self, init=True):
        """Start the link (fpga.init), check it, and release both lines."""
        if init:
            fpga.init()
        if not fpga.link_ok():
            raise RuntimeError("Zen Link not up: is the Zen 4 bitstream of this example loaded?")
        self._scl = 0
        self._sda = 0
        self._set(0, 0)

    def _set(self, scl_low, sda_low):
        """Drive the lines: 1 pulls a line low, 0 releases it."""
        self._scl, self._sda = scl_low, sda_low
        fpga.write(LINES, (SCL_LOW if scl_low else 0) | (SDA_LOW if sda_low else 0))

    def _sda_level(self):
        """Level of SDA as the slave sees it (0 when somebody pulls it low)."""
        return 1 if (fpga.read(LINES) & SDA_IN) else 0

    def _start(self):
        """START: SDA falls while SCL is high."""
        self._set(0, 0)
        self._set(0, 1)
        self._set(1, 1)

    def _stop(self):
        """STOP: SDA rises while SCL is high."""
        self._set(1, 1)
        self._set(0, 1)
        self._set(0, 0)

    def _write_byte(self, b):
        """Send one byte, return True when the slave acknowledged."""
        for i in range(7, -1, -1):
            self._set(1, 0 if (b >> i) & 1 else 1)
            self._set(0, 0 if (b >> i) & 1 else 1)
            self._set(1, 0 if (b >> i) & 1 else 1)
        # Acknowledge bit: release SDA, raise SCL, read SDA (low = ACK)
        self._set(1, 0)
        self._set(0, 0)
        ack = self._sda_level() == 0
        self._set(1, 0)
        return ack

    def _read_byte(self, ack):
        """Receive one byte, then send ACK (ack True) or NACK."""
        v = 0
        self._set(1, 0)
        for _ in range(8):
            self._set(0, 0)
            bit = self._sda_level()
            self._set(1, 0)
            v = (v << 1) | bit
        self._set(1, 0 if not ack else 1)
        self._set(0, 0 if not ack else 1)
        self._set(1, 0 if not ack else 1)
        return v

    def writeto(self, addr, buf, stop=True):
        """Write bytes to the slave at 7-bit address addr. Raises OSError when a byte is not acknowledged."""
        self._start()
        ok = self._write_byte((addr << 1) | 0)
        if ok:
            for b in buf:
                if not self._write_byte(b):
                    ok = False
                    break
        if stop or not ok:
            self._stop()
        if not ok:
            raise OSError(5)
        return len(buf)

    def readfrom(self, addr, n, stop=True):
        """Read n bytes from the slave at 7-bit address addr."""
        self._start()
        if not self._write_byte((addr << 1) | 1):
            self._stop()
            raise OSError(5)
        out = bytearray()
        for i in range(n):
            out.append(self._read_byte(i < n - 1))
        if stop:
            self._stop()
        return bytes(out)

    def scan(self):
        """Return the 7-bit addresses that acknowledge their address byte."""
        found = []
        for a in range(0x08, 0x78):
            self._start()
            if self._write_byte((a << 1) | 0):
                found.append(a)
            self._stop()
        return found
