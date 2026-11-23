# This module is the Python reference for the board's LZSS format: an encoder that matches the C code byte for byte, and a decoder.
# It is also a command-line tool:  python lzss_ref.py compress in.bin out.lzb   |   python lzss_ref.py decompress in.lzb out.bin
#
# Stream format: for every 64-byte block of the input, one length byte C followed by C bytes of bits (most significant bit first,
# zero-padded). A token is: literal = 0 + 8 bits;  match = 1 + 9 bits (distance-1) + 4 bits (length-3). The history window (512 bytes)
# carries over from block to block; a match never runs past the end of its own block.
import struct, sys

# Window size in bytes, field widths, and match limits (must equal the constants in lzss.c).
WINDOW, OFF_BITS, LEN_BITS, MIN_LEN, MAX_LEN, BLOCK = 512, 9, 4, 3, 18, 64
# File container used by the command-line tool: magic, then the original length, then the block stream.
MAGIC = b"LZB1"


# This function encodes one block, using data[start:end] and everything before it as history.
# data: the whole input.  start/end: the block range.  Returns the packed bytes for this block.
def encode_block(data, start, end):
    # Collect the output as a list of bits.
    bits = []
    # Append the low n bits of v, most significant first.
    def put(v, n):
        bits.extend((v >> i) & 1 for i in range(n - 1, -1, -1))
    # Walk through the block.
    p = start
    while p < end:
        # Farthest distance (limited by the data so far and the window) and longest length (not past the block end).
        maxd, maxl = min(p, WINDOW), min(end - p, MAX_LEN)
        best_len = best_d = 0
        # Search only when a match could be long enough.
        if maxl >= MIN_LEN:
            # Try every distance, nearest first.
            for d in range(1, maxd + 1):
                # Count matching bytes (overlap allowed).
                l = 0
                while l < maxl and data[p + l - d] == data[p + l]:
                    l += 1
                # Strictly longer wins, so the nearest distance wins ties (same as the C code).
                if l > best_len:
                    best_len, best_d = l, d
                # Stop at the longest possible match.
                if best_len == maxl:
                    break
        if best_len >= MIN_LEN:
            # Match token.
            put(1, 1); put(best_d - 1, OFF_BITS); put(best_len - MIN_LEN, LEN_BITS)
            p += best_len
        else:
            # Literal token.
            put(0, 1); put(data[p], 8)
            p += 1
    # Pad to a whole byte with zero bits and pack.
    bits += [0] * (-len(bits) % 8)
    return bytes(int("".join(map(str, bits[i:i + 8])), 2) for i in range(0, len(bits), 8))


# This function compresses a whole byte string into the block stream.
def compress_stream(data):
    # Output stream.
    out = bytearray()
    # One block at a time.
    for start in range(0, len(data), BLOCK):
        blk = encode_block(data, start, min(start + BLOCK, len(data)))
        out.append(len(blk)); out += blk
    return bytes(out)


# This function decodes a block stream back to the original bytes. total: the original length (the last block may be short).
def decompress_stream(blob, total):
    # Rebuild the data here; matches copy from earlier output.
    out = bytearray()
    pos = 0
    while len(out) < total:
        # Length of this block's compressed bytes, then the bytes, as a bit string.
        n = blob[pos]; chunk = blob[pos + 1:pos + 1 + n]; pos += 1 + n
        bits = "".join(format(b, "08b") for b in chunk)
        q = 0
        # Raw length of this block: 64 bytes, or what is left for the last block.
        goal = len(out) + min(BLOCK, total - len(out))
        # Read a field of n bits.
        def get(k):
            nonlocal q
            v = int(bits[q:q + k], 2); q += k
            return v
        while len(out) < goal:
            if get(1):
                d = get(OFF_BITS) + 1; l = get(LEN_BITS) + MIN_LEN
                # Copy byte by byte so overlapping matches work.
                for _ in range(l):
                    out.append(out[-d])
            else:
                out.append(get(8))
    return bytes(out)


# This is the command-line entry point.
if __name__ == "__main__":
    mode, src, dst = sys.argv[1:4]
    raw = open(src, "rb").read()
    if mode == "compress":
        open(dst, "wb").write(MAGIC + struct.pack("<I", len(raw)) + compress_stream(raw))
    else:
        total = struct.unpack("<I", raw[4:8])[0]
        open(dst, "wb").write(decompress_stream(raw[8:], total))
