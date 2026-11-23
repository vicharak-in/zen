# runner_view.py - reads the Mario Lite state from the FPGA and makes the text line for the display
# No game rules here: the game runs in the FPGA. Register map: runner/runner_regs.v
import binascii
import fpga

# Name shown in the menu, bitstream file in the RP2350's flash and the ID the bitstream reports at 0x141
NAME = "Mario Lite"
FILE = "runner.hex.bin"
GAME_ID = 4
# First register of the game state, and its length: hero x (2), y, flags, score (3), lives, coins, coin flags (4), 4 enemies (2 each), seq/busy
BASE = 0x150
LEN = 22
# Time between frames (ms)
FRAME_MS = 33
# Tries to get a consistent reading before the last one is used anyway
TRIES = 5


# Read the whole game state in one transfer; retry if the FPGA changed it while we were reading
def read_state():
    # Buffer for the state bytes
    buf = bytearray(LEN)
    # A few attempts
    for _ in range(TRIES):
        # Tick counter and busy flag before the transfer
        s0 = fpga.read(BASE + LEN - 1)
        # The state itself (consecutive addresses)
        fpga.read_block(BASE, buf)
        # Consistent when the FPGA was idle before, idle after, and finished no tick in between
        if s0 == buf[LEN - 1] and not (s0 & 1):
            break
    # State bytes
    return buf


# The line the display reads: R:<the 21 state bytes as hex>; the display knows the level and draws it
def format_line(buf):
    return "R:%s" % binascii.hexlify(bytes(buf[:LEN - 1])).decode()
