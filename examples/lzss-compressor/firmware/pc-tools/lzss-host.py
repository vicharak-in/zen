# This script sends a file to the board over UART, receives the compressed blocks, and checks the result.
# Usage: python lzss-host.py COM5 input.bin [output.lzb]      (needs: pip install pyserial)
#        python lzss-host.py rp:COM8 input.bin               (through the RP2350 and the Zen Link, for the Zen Link builds)
# It verifies two things: the board's bytes are identical to the Python reference encoder, and they decompress back to the input.
import struct, sys, time
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import compengine
import lzss_ref


# This function reads exactly n bytes from the port or stops with a clear message on timeout.
def read_exact(ser, n):
    # Ask the port for n bytes (the port has a timeout set when it was opened).
    b = ser.read(n)
    # A short read means the board did not answer in time.
    if len(b) != n:
        sys.exit("timeout: expected %d byte(s) from the board, got %d. Is the bitstream loaded? (Zen Link build: use rp:COMx; adapter build: R-05 -> adapter RX, R-06 -> adapter TX, GND)" % (n, len(b)))
    return b


# This is the main program.
def main():
    # Command-line arguments.
    port, src = sys.argv[1], sys.argv[2]
    dst = sys.argv[3] if len(sys.argv) > 3 else src + ".lzb"
    data = open(src, "rb").read()
    # Open the link (USB-serial adapter, or rp:COMx for the RP2350 relay) with a 5 s read timeout.
    ser = compengine.open_link(port, 5)
    # Throw away anything already waiting.
    ser.reset_input_buffer()
    # Reset the board's history: send 0, expect 0 back.
    ser.write(b"\x00")
    if read_exact(ser, 1) != b"\x00":
        sys.exit("unexpected reply to reset")
    # Send the file block by block and collect the replies.
    t0 = time.time()
    stream = bytearray()
    for start in range(0, len(data), lzss_ref.BLOCK):
        blk = data[start:start + lzss_ref.BLOCK]
        # Request: length, then the raw bytes.
        ser.write(bytes([len(blk)]) + blk)
        # Reply: compressed length, then that many bytes.
        n = read_exact(ser, 1)
        stream += n + read_exact(ser, n[0])
    dt = time.time() - t0
    # Check 1: identical to the reference encoder.
    ref = lzss_ref.compress_stream(data)
    same = bytes(stream) == ref
    # Check 2: decompresses back to the original.
    back = lzss_ref.decompress_stream(bytes(stream), len(data)) == data
    # Save the compressed file (same container as lzss_ref.py).
    open(dst, "wb").write(lzss_ref.MAGIC + struct.pack("<I", len(data)) + bytes(stream))
    # Report.
    print("input %d bytes -> board stream %d bytes (+8 header) = %.1f%% in %.1f s" % (len(data), len(stream), 100 * (len(stream) + 8) / max(1, len(data)), dt))
    print("matches Python reference encoder: %s" % same)
    print("decompresses back to the input:   %s" % back)
    print("saved %s" % dst)


# This runs main() when the script is executed directly.
if __name__ == "__main__":
    main()
