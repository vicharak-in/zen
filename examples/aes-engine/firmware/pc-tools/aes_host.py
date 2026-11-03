#!/usr/bin/env python3
# aes_host.py - PC side tool for the aes-engine engine (talks to the FPGA UART protocol described in README.md).
#
#   python3 aes_host.py --port COM5 --via rp  selftest
#   python3 aes_host.py --port COM5 --via rp  --key 000102030405060708090a0b0c0d0e0f --mode ecb enc in.bin out.bin
#   python3 aes_host.py --port COM5 --via rp  --div 25 --mode ctr --key <hex> dec in.bin out.bin
#
# --via rp      : through the RP2350 running rp-pipe.py (USB serial of the board); the RP2350 reaches the FPGA over the Zen Link
# File formats: ECB output is PKCS7 padded; CTR output is  IV (16 bytes) + cipher text.
# Needs: pyserial (pip install pyserial). The 'cryptography' package is used only to double check in selftest.

import argparse    # Command line
import os          # Random IV
import sys         # Exit codes
import time        # Small waits

# Clock of the FPGA fabric in Hz (baud = CLOCK / divisor)
CLOCK_HZ = 25_000_000
# Divisor after reset (25 MHz / 217 = 115207 baud)
DEFAULT_DIV = 217
# Blocks per ECB command (16 blocks = 256 bytes, fits the 512 byte receive FIFO with room to spare)
ECB_CHUNK_BLOCKS = 16
# Bytes per CTR command (multiple of 16 so the key stream continues exactly between commands)
CTR_CHUNK = 256


class RpLink:
    """Serial port to the RP2350 running rp-pipe.py (framed)."""

    def __init__(self, port):
        import serial                                   # pyserial
        self.s = serial.Serial(port, 115200, timeout=2) # USB serial, the rate is ignored
        self.buf = b""                                  # Bytes from the FPGA that were not used yet
        self.set_baud(115200)                           # Start from the engine default

    def send(self, data):
        for i in range(0, len(data), 128):              # Frames of at most 128 bytes
            part = data[i:i + 128]
            self.s.write(bytes([len(part)]) + part)     # Length byte, then the payload
        self.s.flush()

    def recv(self, n):
        deadline = time.time() + 3                      # Give up after 3 s
        while len(self.buf) < n:                        # Until enough bytes are here
            if time.time() > deadline:
                raise IOError("timeout: got %d of %d bytes" % (len(self.buf), n))
            h = self.s.read(1)                          # Frame length byte
            if h:
                self.buf += self.s.read(h[0])           # Frame payload
        out, self.buf = self.buf[:n], self.buf[n:]      # Take what was asked for
        return out

    def set_baud(self, baud):
        self.s.write(bytes([0, (baud >> 16) & 255, (baud >> 8) & 255, baud & 255]))  # Baud frame
        self.s.flush()

    def close(self):
        self.s.close()


class Engine:
    """The protocol of aes-top.v, one method per command."""

    def __init__(self, link):
        self.link = link                                # RpLink or a test double

    def version(self):
        self.link.send(b"V")                            # Ask
        r = self.link.recv(4)                           # 'A' 'E' 'S' config
        if r[:3] != b"AES":
            raise IOError("no AES engine answered: %r" % r)
        return r[3]                                     # {MC_PAR, SB_LANES}

    def set_key(self, key):
        assert len(key) == 16
        self.link.send(b"K" + key)                      # Key command
        self._expect(b"K")

    def set_iv(self, iv):
        assert len(iv) == 16
        self.link.send(b"I" + iv)                       # Counter block
        self._expect(b"I")

    def set_div(self, div):
        self.link.send(b"B" + bytes([div]))             # Baud divisor, reply comes at the old rate
        self._expect(b"B")
        self.link.set_baud(CLOCK_HZ // (div if div else DEFAULT_DIV))  # Follow on the PC side
        time.sleep(0.01)                                # Let both sides settle

    def ecb(self, data, decrypt=False):
        assert len(data) % 16 == 0
        out = b""
        step = ECB_CHUNK_BLOCKS * 16
        for i in range(0, len(data), step):             # One command per chunk
            part = data[i:i + step]
            self.link.send((b"D" if decrypt else b"E") + bytes([len(part) // 16]) + part)
            out += self.link.recv(len(part))
        return out

    def ctr(self, data):
        out = b""
        for i in range(0, len(data), CTR_CHUNK):        # One command per chunk
            part = data[i:i + CTR_CHUNK]
            self.link.send(b"C" + bytes([len(part) >> 8, len(part) & 255]) + part)
            out += self.link.recv(len(part))
        return out

    def _expect(self, ch):
        r = self.link.recv(1)                           # One acknowledge byte
        if r != ch:
            raise IOError("expected %r, got %r" % (ch, r))


def pkcs7_pad(b):
    p = 16 - len(b) % 16                                # 1..16 pad bytes
    return b + bytes([p]) * p


def pkcs7_unpad(b):
    p = b[-1]
    if not 1 <= p <= 16 or b[-p:] != bytes([p]) * p:
        raise ValueError("bad padding (wrong key?)")
    return b[:-p]


def selftest(eng):
    """Known answer tests from FIPS-197 and NIST SP 800-38A, plus a random cross check."""
    ok = True
    key = bytes(range(16))
    eng.set_key(key)                                    # FIPS-197 appendix C.1
    pt = bytes.fromhex("00112233445566778899aabbccddeeff")
    ct = bytes.fromhex("69c4e0d86a7b0430d8cdb78070b4c55a")
    ok &= eng.ecb(pt) == ct
    ok &= eng.ecb(ct, decrypt=True) == pt
    print("FIPS-197 ECB      :", "ok" if ok else "FAIL")
    eng.set_key(bytes.fromhex("2b7e151628aed2a6abf7158809cf4f3c"))   # SP 800-38A F.5.1
    eng.set_iv(bytes.fromhex("f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff"))
    p = bytes.fromhex("6bc1bee22e409f96e93d7e117393172a")
    c = bytes.fromhex("874d6191b620e3261bef6864990db6ce")
    r = eng.ctr(p) == c
    print("SP800-38A CTR     :", "ok" if r else "FAIL")
    ok &= r
    try:
        from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes   # Reference
        k, iv, d = os.urandom(16), os.urandom(16), os.urandom(1000)
        eng.set_key(k); eng.set_iv(iv)
        got = eng.ctr(d)
        enc = Cipher(algorithms.AES(k), modes.CTR(iv)).encryptor()
        r = got == enc.update(d) + enc.finalize()
        print("random CTR 1000 B :", "ok" if r else "FAIL"); ok &= r
        d = os.urandom(16 * 40)
        got = eng.ecb(d)
        enc = Cipher(algorithms.AES(k), modes.ECB()).encryptor()
        r = got == enc.update(d) + enc.finalize()
        print("random ECB 40 blk :", "ok" if r else "FAIL"); ok &= r
    except ImportError:
        print("cryptography not installed: random cross check skipped")
    return ok


def main():
    ap = argparse.ArgumentParser(description="aes-engine host tool")
    ap.add_argument("--port", required=True, help="serial port, e.g. COM5 or /dev/ttyACM0")
    ap.add_argument("--via", choices=["rp"], default="rp")
    ap.add_argument("--key", help="32 hex digits")
    ap.add_argument("--mode", choices=["ecb", "ctr"], default="ecb")
    ap.add_argument("--div", type=int, default=0, help="baud divisor (clock / div), 0 keeps 115200; 25 = 1 Mbaud")
    ap.add_argument("action", choices=["selftest", "enc", "dec"])
    ap.add_argument("infile", nargs="?")
    ap.add_argument("outfile", nargs="?")
    a = ap.parse_args()

    link = RpLink(a.port)
    eng = Engine(link)
    cfg = eng.version()
    print("engine found: SB_LANES=%d MC_PAR=%d" % (cfg & 15, cfg >> 4))
    if a.div:
        eng.set_div(a.div)
    if a.action == "selftest":
        good = selftest(eng)
        print("RESULT:", "PASS" if good else "FAIL")
        sys.exit(0 if good else 1)
    if not (a.key and a.infile and a.outfile):
        ap.error("enc/dec need --key, infile and outfile")
    key = bytes.fromhex(a.key)
    data = open(a.infile, "rb").read()
    eng.set_key(key)
    if a.mode == "ecb":
        out = eng.ecb(pkcs7_pad(data)) if a.action == "enc" else pkcs7_unpad(eng.ecb(data, decrypt=True))
    else:
        if a.action == "enc":
            iv = os.urandom(16)
            eng.set_iv(iv)
            out = iv + eng.ctr(data)
        else:
            eng.set_iv(data[:16])
            out = eng.ctr(data[16:])
    open(a.outfile, "wb").write(out)
    print("wrote %d bytes to %s" % (len(out), a.outfile))


if __name__ == "__main__":
    main()
