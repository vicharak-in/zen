# zen_spi.py - SPI-style byte port over the Zen Link (runs on the RP2350 of the Zen board).
# Replaces the machine.SPI + chip-select pin that the Shrike examples use. The FPGA design must contain zl_byte_port (registers at 0x100..0x102).
#
#   spi = ZenSPI()
#   spi.select(); r = spi.xfer(0xAB); spi.deselect()      one byte, chip select held around it
#   spi.exchange(0xAB)                                     the same in one call
#   spi.reset()                                            reset the design (replaces the Shrike reset pin)
#   spi.write_readinto(tx, rx), spi.write(buf), spi.read(n, tx_byte)    like machine.SPI (select first when the design needs a frame)
#
# One SPI byte is "read DATA, then write DATA": the read returns the byte the design had loaded for the master, the write is the byte the master sends.

import fpga

# Register addresses of zl_byte_port
DATA, CTRL, LAST = 0x100, 0x101, 0x102


class ZenSPI:
    def __init__(self, init=True):
        """Start the link (fpga.init) and check that a Zen Link bitstream is loaded."""
        if init:
            fpga.init()
        if not fpga.link_ok():
            raise RuntimeError("Zen Link not up: is the Zen 4 bitstream of this example loaded?")
        self.deselect()

    def reset(self):
        """Reset the FPGA design (Zen Link control register 0, bit 0), the replacement for the Shrike reset pin."""
        fpga.write(0x10, 1)
        fpga.write(0x10, 0)

    def select(self):
        """Chip select asserted (like cs.value(0))."""
        fpga.write(CTRL, 1)

    def deselect(self):
        """Chip select released (like cs.value(1))."""
        fpga.write(CTRL, 0)

    def xfer(self, b):
        """Send one byte and return the byte that comes back during it."""
        r = fpga.read(DATA)
        fpga.write(DATA, b & 0xFF)
        return r

    def exchange(self, b):
        """Select, send one byte, release, return the reply (the Shrike spi_exchange)."""
        self.select()
        r = self.xfer(b)
        self.deselect()
        return r

    def write_readinto(self, tx, rx):
        """Send the bytes of tx and store the replies in rx (same length)."""
        for i in range(len(tx)):
            rx[i] = self.xfer(tx[i])

    def write(self, buf):
        """Send the bytes of buf, ignoring the replies."""
        for b in buf:
            self.xfer(b)

    def read(self, n, tx=0x00):
        """Read n bytes while sending the byte tx each time."""
        out = bytearray(n)
        for i in range(n):
            out[i] = self.xfer(tx)
        return bytes(out)
