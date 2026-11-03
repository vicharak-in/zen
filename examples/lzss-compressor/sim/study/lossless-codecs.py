# This script holds real lossless codecs (BDI, FPC, text-BDI, LZSS) and checks that every one decompresses back to the exact original bytes.
# Usage: python lossless-codecs.py [file ...]   (two synthetic binary data sets are always added)
import os, random, struct, sys, zlib

# This is the size in bytes of one block for the line-based codecs (BDI, FPC, text-BDI).
LINE = 64


# This class writes a stream of bits (most significant bit first) and packs it into bytes.
class BitWriter:
    # This creates an empty bit list.
    def __init__(self):
        # Each entry is 0 or 1.
        self.bits = []

    # This appends the low n bits of value, most significant first.
    def put(self, value, n):
        # Walk from the top bit down to bit 0.
        for i in range(n - 1, -1, -1):
            # Append that bit.
            self.bits.append((value >> i) & 1)

    # This pads the stream with zero bits to a whole byte and returns the bytes.
    def to_bytes(self):
        # Pad to a multiple of 8 bits.
        b = self.bits + [0] * (-len(self.bits) % 8)
        # Pack 8 bits per byte.
        return bytes(int("".join(map(str, b[i:i + 8])), 2) for i in range(0, len(b), 8))


# This class reads a stream of bits written by BitWriter.
class BitReader:
    # This stores the bytes as a list of bits and starts at position 0.
    def __init__(self, blob):
        # Expand every byte into its 8 bits.
        self.bits = [(byte >> (7 - k)) & 1 for byte in blob for k in range(8)]
        # Current read position.
        self.pos = 0

    # This reads the next n bits as an unsigned integer.
    def get(self, n):
        # Start with zero.
        v = 0
        # Shift in n bits.
        for _ in range(n):
            v = (v << 1) | self.bits[self.pos]
            self.pos += 1
        # Return the value.
        return v


# This function converts an unsigned value to a signed one of the given bit width.
def signed(v, bits):
    # Values with the top bit set are negative.
    return v - (1 << bits) if v >> (bits - 1) else v


# This function reads a 64-byte line as little-endian unsigned integers of the given width in bytes.
def words(line, width):
    # Choose the struct letter for this width.
    fmt = {8: "Q", 4: "I", 2: "H", 1: "B"}[width]
    # Unpack the whole line.
    return list(struct.unpack("<%d%s" % (LINE // width, fmt), line))


# This function splits data into 64-byte lines, zero-padding the last one.
def lines_of(data):
    # Pad to a whole number of lines.
    data = data + b"\0" * (-len(data) % LINE)
    # Cut into lines.
    return [data[i:i + LINE] for i in range(0, len(data), LINE)]


# Every compressed file starts with the original length as 4 bytes, so the decoder knows where to stop.
# This function builds the 4-byte length header.
def header(n):
    # Little-endian 32-bit length.
    return struct.pack("<I", n)


# ---------------------------------------------------------------- text-BDI (byte-wide base + offset)
# This function compresses data: per line, a base byte (the smallest) plus n bits per byte for the offset from it.
def enc_textbdi(data):
    # Output bit stream.
    w = BitWriter()
    # Go through every 64-byte line.
    for line in lines_of(data):
        # Smallest and largest byte.
        lo, hi = min(line), max(line)
        # Bits needed for the largest offset (at least 1).
        n = max(1, (hi - lo).bit_length())
        # Use the packed form only if it is smaller than the raw line.
        if 1 + 8 + 3 + LINE * n < 1 + LINE * 8:
            # Flag 1 = packed, then base, then n-1 in 3 bits, then each offset.
            w.put(1, 1); w.put(lo, 8); w.put(n - 1, 3)
            for b in line:
                w.put(b - lo, n)
        else:
            # Flag 0 = raw line.
            w.put(0, 1)
            for b in line:
                w.put(b, 8)
    # Header plus packed bits.
    return header(len(data)) + w.to_bytes()


# This function decompresses what enc_textbdi produced.
def dec_textbdi(blob):
    # Original length, then the bit reader.
    n = struct.unpack("<I", blob[:4])[0]
    r = BitReader(blob[4:])
    # Rebuild line by line.
    out = bytearray()
    while len(out) < n:
        # Packed or raw?
        if r.get(1):
            lo = r.get(8); k = r.get(3) + 1
            out += bytes(lo + r.get(k) for _ in range(LINE))
        else:
            out += bytes(r.get(8) for _ in range(LINE))
    # Drop the padding.
    return bytes(out[:n])


# ---------------------------------------------------------------- FPC (Frequent Pattern Compression)
# This function picks the cheapest FPC pattern for one 32-bit word. Returns (prefix, data bits, data value).
def fpc_pick(w):
    # Signed view for the sign-extension patterns.
    s = signed(w, 32)
    if w == 0:
        return 0, 0, 0                                   # zero word
    if -8 <= s < 8:
        return 1, 4, w & 0xF                             # 4-bit sign-extended
    if -128 <= s < 128:
        return 2, 8, w & 0xFF                            # 8-bit sign-extended
    if -32768 <= s < 32768:
        return 3, 16, w & 0xFFFF                         # 16-bit sign-extended
    if w & 0xFFFF == 0:
        return 4, 16, w >> 16                            # low half is zero
    lo, hi = w & 0xFFFF, w >> 16
    if -128 <= signed(lo, 16) < 128 and -128 <= signed(hi, 16) < 128:
        return 5, 16, ((hi & 0xFF) << 8) | (lo & 0xFF)   # two halfwords, each a sign-extended byte
    if w == (w & 0xFF) * 0x01010101:
        return 6, 8, w & 0xFF                            # one byte repeated four times
    return 7, 32, w                                      # no pattern: whole word


# This function compresses data with FPC: a 3-bit prefix and the data bits for every 32-bit word.
def enc_fpc(data):
    # Output bit stream.
    w = BitWriter()
    # Every word of every line.
    for line in lines_of(data):
        for word in words(line, 4):
            # Choose the pattern and write prefix + data.
            p, n, v = fpc_pick(word)
            w.put(p, 3); w.put(v, n)
    # Header plus packed bits.
    return header(len(data)) + w.to_bytes()


# This function decompresses what enc_fpc produced.
def dec_fpc(blob):
    # Original length, then the bit reader.
    n = struct.unpack("<I", blob[:4])[0]
    r = BitReader(blob[4:])
    # Rebuild word by word.
    out = bytearray()
    while len(out) < n:
        p = r.get(3)
        if p == 0: word = 0
        elif p == 1: word = signed(r.get(4), 4) & 0xFFFFFFFF
        elif p == 2: word = signed(r.get(8), 8) & 0xFFFFFFFF
        elif p == 3: word = signed(r.get(16), 16) & 0xFFFFFFFF
        elif p == 4: word = r.get(16) << 16
        elif p == 5:
            v = r.get(16)
            word = ((signed(v >> 8, 8) & 0xFFFF) << 16) | (signed(v & 0xFF, 8) & 0xFFFF)
        elif p == 6: word = r.get(8) * 0x01010101
        else: word = r.get(32)
        out += struct.pack("<I", word)
    # Drop the padding.
    return bytes(out[:n])


# ---------------------------------------------------------------- BDI (Base-Delta-Immediate)
# These are the (base width, delta width) pairs in bytes; tags 2..7 select them, 0 = zero line, 1 = repeated 8-byte value, 8 = raw.
BDI_CONFIGS = [(8, 1), (8, 2), (8, 4), (4, 1), (4, 2), (2, 1)]


# This function tries one BDI configuration on a line. Returns (size in bits, base, entries) or None if it does not fit.
def bdi_try(line, bw, dw):
    # Element and delta sizes in bits, and the signed delta limit.
    bb, bd = bw * 8, dw * 8
    lim = 1 << (bd - 1)
    mb = (1 << bb) - 1
    ws = words(line, bw)
    # Explicit base: the first element that does not fit as a small value near zero.
    base = next((x for x in ws if not -lim <= signed(x, bb) < lim), 0)
    entries = []
    for x in ws:
        # Delta from the implicit zero base.
        d0 = signed(x, bb)
        if -lim <= d0 < lim:
            entries.append((0, d0 & ((1 << bd) - 1)))
            continue
        # Delta from the explicit base.
        d1 = signed((x - base) & mb, bb)
        if -lim <= d1 < lim:
            entries.append((1, d1 & ((1 << bd) - 1)))
            continue
        # This element fits neither base: configuration fails.
        return None
    # Size: 4-bit tag + base + one mask bit and one delta per element.
    return 4 + bb + len(ws) * (1 + bd), base, entries


# This function compresses data with BDI, choosing the smallest encoding for each line.
def enc_bdi(data):
    # Output bit stream.
    w = BitWriter()
    for line in lines_of(data):
        # Special case: all zero.
        if not any(line):
            w.put(0, 4); continue
        # Special case: one 8-byte value repeated.
        w8 = words(line, 8)
        if all(x == w8[0] for x in w8):
            w.put(1, 4); w.put(w8[0], 64); continue
        # Try every configuration and remember the smallest.
        best = None
        for idx, (bw, dw) in enumerate(BDI_CONFIGS):
            t = bdi_try(line, bw, dw)
            if t and t[0] < 4 + LINE * 8 and (best is None or t[0] < best[0][0]):
                best = (t, idx, bw, dw)
        if best:
            (size, base, entries), idx, bw, dw = best
            w.put(2 + idx, 4); w.put(base, bw * 8)
            for m, d in entries:
                w.put(m, 1); w.put(d, dw * 8)
        else:
            # Nothing fits: store raw.
            w.put(8, 4)
            for b in line:
                w.put(b, 8)
    # Header plus packed bits.
    return header(len(data)) + w.to_bytes()


# This function decompresses what enc_bdi produced.
def dec_bdi(blob):
    # Original length, then the bit reader.
    n = struct.unpack("<I", blob[:4])[0]
    r = BitReader(blob[4:])
    out = bytearray()
    while len(out) < n:
        tag = r.get(4)
        if tag == 0:
            out += bytes(LINE)
        elif tag == 1:
            out += struct.pack("<Q", r.get(64)) * (LINE // 8)
        elif tag == 8:
            out += bytes(r.get(8) for _ in range(LINE))
        else:
            bw, dw = BDI_CONFIGS[tag - 2]
            bb, bd = bw * 8, dw * 8
            mb = (1 << bb) - 1
            base = r.get(bb)
            fmt = {8: "Q", 4: "I", 2: "H"}[bw]
            for _ in range(LINE // bw):
                m = r.get(1); d = signed(r.get(bd), bd)
                # Value is the delta itself (zero base) or base + delta.
                val = ((base + d) if m else d) & mb
                out += struct.pack("<" + fmt, val)
    # Drop the padding.
    return bytes(out[:n])


# ---------------------------------------------------------------- LZSS (sliding-window dictionary)
# This function builds an LZSS codec pair for a given window size (power of two) and length-field width in bits.
# A literal costs 9 bits (flag + byte); a match costs 1 + log2(window) + length_bits bits and covers MINLEN or more bytes.
def make_lzss(window, len_bits=4, minlen=3):
    # Bits needed to store a distance 1..window.
    off_bits = window.bit_length() - 1
    # Longest match one token can describe.
    maxlen = minlen + (1 << len_bits) - 1

    # This compresses data with greedy matching against the last `window` bytes.
    def enc(data):
        w = BitWriter()
        # Last positions seen for every 3-byte prefix (a short hash chain, limited to 32 candidates).
        chain = {}
        i, n = 0, len(data)
        while i < n:
            best_len, best_d = 0, 0
            if i + minlen <= n:
                # Look at the most recent positions with the same first 3 bytes.
                for j in reversed(chain.get(data[i:i + 3], [])[-32:]):
                    d = i - j
                    if d > window:
                        break
                    # Count how many bytes match (overlap with the current position is allowed).
                    l = 0
                    while l < maxlen and i + l < n and data[i + l - d] == data[i + l]:
                        l += 1
                    if l > best_len:
                        best_len, best_d = l, d
            if best_len >= minlen:
                # Match token: flag 1, distance-1, length-minlen.
                w.put(1, 1); w.put(best_d - 1, off_bits); w.put(best_len - minlen, len_bits)
                step = best_len
            else:
                # Literal token: flag 0 and the byte.
                w.put(0, 1); w.put(data[i], 8)
                step = 1
            # Record every consumed position in the chain so later matches can find it.
            for k in range(i, i + step):
                if k + 3 <= n:
                    chain.setdefault(data[k:k + 3], []).append(k)
            i += step
        return header(n) + w.to_bytes()

    # This decompresses an LZSS stream.
    def dec(blob):
        n = struct.unpack("<I", blob[:4])[0]
        r = BitReader(blob[4:])
        out = bytearray()
        while len(out) < n:
            if r.get(1):
                d = r.get(off_bits) + 1
                l = r.get(len_bits) + minlen
                # Copy byte by byte so overlapping matches (runs) work.
                for _ in range(l):
                    out.append(out[-d])
            else:
                out.append(r.get(8))
        return bytes(out[:n])

    return enc, dec


# ---------------------------------------------------------------- data sets and the test runner
# This function builds 32-bit sensor readings that drift slowly (a good case for BDI and FPC).
def sensor_data():
    # Fixed seed so every run is identical.
    random.seed(1)
    v, out = 2048, []
    for _ in range(4096):
        v = max(0, min(4095, v + random.randint(-6, 6)))
        out.append(v)
    return struct.pack("<%dI" % len(out), *out)


# This function builds 64-bit pointer-like values close to one base address (the classic BDI case).
def pointer_data():
    random.seed(2)
    base = 0x00007F3A12340000
    return struct.pack("<2048Q", *[base + random.randrange(0, 4096, 8) for _ in range(2048)])


# This is the main program: run every codec on every data set, verify the round trip, and print the ratios.
def main():
    # The codecs to test: name -> (encoder, decoder).
    lz256, lz512, lz1k = make_lzss(256), make_lzss(512), make_lzss(1024)
    codecs = [("BDI", (enc_bdi, dec_bdi)), ("FPC", (enc_fpc, dec_fpc)), ("text-BDI", (enc_textbdi, dec_textbdi)),
              ("LZSS-256", lz256), ("LZSS-512", lz512), ("LZSS-1K", lz1k)]
    # Data sets: files from the command line, then the synthetic ones.
    sets = [(os.path.basename(a), open(a, "rb").read()) for a in sys.argv[1:]]
    sets += [("synthetic: int32 sensor", sensor_data()), ("synthetic: int64 pointers", pointer_data())]
    # Table header.
    print("%-28s %8s" % ("data set", "bytes") + "".join("%10s" % c[0] for c in codecs) + "%8s" % "zlib*")
    for name, data in sets:
        row = "%-28s %8d" % (name[-28:], len(data))
        for cname, (enc, dec) in codecs:
            # Compress, decompress, and require the exact original back.
            blob = enc(data)
            assert dec(blob) == data, "ROUND TRIP FAILED: %s on %s" % (cname, name)
            # Ratio includes the 4-byte header.
            row += "%9.1f%%" % (100 * len(blob) / len(data))
        row += "%7.1f%%" % (100 * len(zlib.compress(data, 9)) / len(data))
        print(row)
    # Explain.
    print("\nEvery cell is compressed size / original size (lower is better), header included; every codec decompressed back to the exact input.")
    print("*zlib is shown only as a reference for a heavy compressor.")


# This runs main() when the script is executed directly.
if __name__ == "__main__":
    main()
