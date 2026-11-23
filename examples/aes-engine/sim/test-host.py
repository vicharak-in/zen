# test-host.py - tests firmware/pc-tools/aes_host.py against a Python model of the FPGA protocol (no hardware, no Verilog).
# The model implements the same command set as aes-top.v using the 'cryptography' package.
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "firmware", "pc-tools"))
from aes_host import Engine, selftest, pkcs7_pad, pkcs7_unpad
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes


class ModelLink:
    """Stands in for the serial link: parses commands like the RTL parser and queues the reply bytes."""

    def __init__(self):
        self.inb = b""       # Bytes from the host, not parsed yet
        self.outb = b""      # Reply bytes waiting for the host
        self.key = None
        self.ctr = 0         # 128 bit counter

    def send(self, d):
        self.inb += d
        while self._step():  # Parse as many complete commands as possible
            pass

    def recv(self, n):
        if len(self.outb) < n:
            raise IOError("model: short read")
        o, self.outb = self.outb[:n], self.outb[n:]
        return o

    def set_baud(self, b):
        pass

    def _aes(self, data, enc=True):
        c = Cipher(algorithms.AES(self.key), modes.ECB())
        x = c.encryptor() if enc else c.decryptor()
        return x.update(data) + x.finalize()

    def _step(self):
        b = self.inb
        if not b:
            return False
        c = b[:1]
        if c == b"V" : self.outb += b"AES\x01"; self.inb = b[1:]; return True
        if c == b"K" and len(b) >= 17: self.key = b[1:17]; self.outb += b"K"; self.inb = b[17:]; return True
        if c == b"I" and len(b) >= 17: self.ctr = int.from_bytes(b[1:17], "big"); self.outb += b"I"; self.inb = b[17:]; return True
        if c == b"B" and len(b) >= 2: self.outb += b"B"; self.inb = b[2:]; return True
        if c in (b"E", b"D") and len(b) >= 2 and len(b) >= 2 + 16 * b[1]:
            n = b[1]; self.outb += self._aes(b[2:2 + 16 * n], c == b"E"); self.inb = b[2 + 16 * n:]; return True
        if c == b"C" and len(b) >= 3 and len(b) >= 3 + (b[1] * 256 + b[2]):
            n = b[1] * 256 + b[2]; d = b[3:3 + n]; ks = b""
            for _ in range((n + 15) // 16):                      # One counter value per started block
                ks += self._aes(self.ctr.to_bytes(16, "big")); self.ctr = (self.ctr + 1) % (1 << 128)
            self.outb += bytes(x ^ y for x, y in zip(d, ks)); self.inb = b[3 + n:]; return True
        return False


eng = Engine(ModelLink())
assert eng.version() == 1
assert selftest(eng), "selftest failed"
# Round trips with odd lengths for both modes
k = os.urandom(16)
eng.set_key(k)
for n in (0, 1, 15, 16, 17, 255, 256, 257, 1000):
    d = os.urandom(n)
    e = eng.ecb(pkcs7_pad(d))
    assert pkcs7_unpad(eng.ecb(e, decrypt=True)) == d, n
    iv = os.urandom(16)
    eng.set_iv(iv); c = eng.ctr(d)
    eng.set_iv(iv); assert eng.ctr(c) == d, n
    ref = Cipher(algorithms.AES(k), modes.CTR(iv)).encryptor()
    assert c == ref.update(d) + ref.finalize(), n
print("HOST TESTS PASSED")
