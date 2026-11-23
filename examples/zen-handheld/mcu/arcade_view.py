# arcade_view.py - shared part of the views of the four arcade games (Flyer, Pong, Snake, Guard)
# No game rules here: the games run in the FPGA. Register map of each game: <game>/<game>_regs.v (state from 0x150, then {seq, busy})
import binascii
import fpga

# First register of the game state
BASE = 0x150
# Time between frames (ms)
FRAME_MS = 33
# Tries to get a consistent reading before the last one is used anyway
TRIES = 5


# Read the whole game state (n state bytes and the tick counter) in one transfer; retry if the FPGA changed it while we were reading
def read_state(n):
    # Buffer for the state bytes and the {seq, busy} byte
    buf = bytearray(n + 1)
    # A few attempts
    for _ in range(TRIES):
        # Tick counter and busy flag before the transfer
        s0 = fpga.read(BASE + n)
        # The state itself (consecutive addresses)
        fpga.read_block(BASE, buf)
        # Consistent when the FPGA was idle before, idle after, and finished no tick in between
        if s0 == buf[n] and not (s0 & 1):
            break
    return buf


# The line the display reads: G:<game id>:<the n state bytes as hex>; the display knows the game and draws it
def format_line(gid, n, buf):
    return "G:%d:%s" % (gid, binascii.hexlify(bytes(buf[:n])).decode())
