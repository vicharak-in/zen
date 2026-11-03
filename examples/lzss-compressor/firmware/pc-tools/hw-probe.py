# This checks which engine is on the FPGA by sending one tiny decode request through the RP2350 (relay mode) and printing what comes back.
# Usage:  python firmware\pc-tools\hw-probe.py COM8        (through the RP2350 and the Zen Link)
import os
import sys

# Make compengine and lzss_ref importable when run from any folder.
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import compengine
import lzss_ref


# This sends reset, one compress request and one decode request and reports each reply.
def main(argv):
    port = argv[0]
    text = b"hello hello hello hello"
    block = lzss_ref.encode_block(text, 0, len(text))
    try:
        ser = compengine.open_rp(port)
    except compengine.ToolError as e:
        print("FAIL: %s" % e)
        return 1
    try:
        ser.reset_input_buffer()
        ser.write(b"\x00")
        r = ser.read(1)
        print("reset            reply: %s   (expected 00)" % (r.hex() or "nothing"))
        ser.write(bytes([len(text)]) + text)
        n = ser.read(1)
        comp = ser.read(n[0]) if n else b""
        print("compress request reply: %s %s   (expected %02x %s)" % (n.hex() or "nothing", comp.hex(), len(block), block.hex()))
        ser.write(b"\x00")
        ser.read(1)
        ser.write(bytes([0x80 | len(block)]) + block)
        n = ser.read(1)
        raw = ser.read(n[0]) if n else b""
        print("decode request   reply: %s %s   (expected %02x %s)" % (n.hex() or "nothing", raw.hex(), len(text), text.hex()))
    finally:
        ser.close()
    if raw == text:
        print("PASS: the FPGA has the compressor AND decompressor. `decompress FILE.lzb --rp COM8` should work.")
        return 0
    if not n:
        print("RESULT: the FPGA ignored the decode request: it is the OLD compress-only build. Copy outflow\\lzss-compressor.hex.bin to the board again (see the steps) and run `import main`.")
    else:
        print("RESULT: the FPGA answered the decode request with the wrong data: a real decoder problem; paste this output.")
    return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
