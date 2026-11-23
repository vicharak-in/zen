"""fake_fpga.py - a stand-in for MicroPython's `fpga` module that runs on the PC, so firmware/RP2350/tinyml_zink.py can be tested without the board.

It implements the same calls (init, link_ok, read, write, read_block, write_block) on a byte dictionary laid out like the engine's windows.
When CMD = 1 is written it decodes the layer table, biases and weights from those raw bytes (using only the documented layout rules,
not the packer) and computes the network with the golden model, so a wrong layout or a wrong driver shows up as a mismatch.
"""

import os
import struct
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "tools"))
import tinyml_model as m  # noqa: E402


class FakeFPGA:
    def __init__(self):
        self.mem = {}          # address -> byte, for the table, weight, bias, input and output windows and the registers
        self.status = 0        # busy / done / error bits
        self.cycles = 0        # clocks of the last run

    def init(self):
        pass

    def link_ok(self):
        return True

    def write(self, addr, val):
        self.mem[addr] = val & 0xFF
        if addr == 0x0100 and val == 1:
            self._run()

    def read(self, addr):
        if addr == 0x0101:
            return self.status
        if addr == 0x0103:
            return 0xC1
        if 0x0104 <= addr <= 0x0107:
            return (self.cycles >> (8 * (addr - 0x0104))) & 0xFF
        return self.mem.get(addr, 0)

    def write_block(self, addr, data):
        for i, b in enumerate(data):
            self.write(addr + i, b)

    def read_block(self, addr, buf):
        for i in range(len(buf)):
            buf[i] = self.read(addr + i)

    def _run(self):
        """Decode the network from the raw bytes and compute it."""
        nl = self.mem.get(0x0102, 0)
        wptr, bptr, layers = 0, 0, []
        for l in range(nl):
            ind, outd, shift, flags = (self.mem.get(0x0200 + 4 * l + k, 0) for k in range(4))
            w = []
            for _ in range(outd):
                w.append([(self.mem.get(0x2000 + wptr + i, 0) ^ 0x80) - 0x80 for i in range(ind)])   # int8 two's complement
                wptr += ind
            b = []
            for _ in range(outd):
                b.append(struct.unpack("<i", bytes(self.mem.get(0x4000 + bptr + k, 0) for k in range(4)))[0])
                bptr += 4
            layers.append(m.Layer(w, b, shift, flags & 1))
        x = [(self.mem.get(0x0600 + i, 0) ^ 0x80) - 0x80 for i in range(layers[0].in_dim)]
        y = m.forward(layers, x)
        for i, v in enumerate(y):
            self.mem[0x0700 + i] = v & 0xFF
        self.cycles = m.expected_cycles(layers)
        self.status = 0x02     # done
