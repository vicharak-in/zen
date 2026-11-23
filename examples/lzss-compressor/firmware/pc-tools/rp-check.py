# This checks the Zen Link between the RP2350 and the FPGA: it starts the relay on the RP2350 (which fails if the Zen Link is not up), sends the reset byte 0x00 and reports what the design answers.
# Usage:  python firmware\pc-tools\rp-check.py COM8        (the RP2350's own USB port; the lzss-compressor bitstream or the lzss example of PicoRV32-Zen must be loaded)
import os
import sys

# Make compengine importable when run from any folder.
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import compengine


# This opens the relay, sends the reset byte through the Zen Link and reports what came back.
def main(argv):
    port = argv[0]
    try:
        ser = compengine.open_rp(port)
    except compengine.ToolError as e:
        print("FAIL: %s" % e)
        print("The relay program stops when the Zen Link is down: check that a Zen Link bitstream is loaded (CDONE = 1) and that zink_uart.py and the board's fpga module are on the RP2350.")
        return 1
    try:
        ser.reset_input_buffer()
        ser.write(b"\x00")
        got = ser.read(1)
    finally:
        ser.close()
    print("sent 00\ngot  %s" % (got.hex(" ") or "(nothing)"))
    if got == b"\x00":
        print("PASS: the Zen Link is up and the design answered the reset byte.")
        return 0
    print("FAIL: the Zen Link is up (the relay started) but the design did not answer 00. Check the bitstream (lzss-compressor or the PicoRV32-Zen lzss example), press btn1, and try again.")
    return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
