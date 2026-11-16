# tetris_view.py - reads the Tetris state from the FPGA and turns it into the text line for the PC (no game rules here: the game runs in the FPGA)
# Register map: fpga/tetris_regs.v in the tetris folder
import binascii
import fpga
from frame import overlay

# Name shown in the menu, bitstream file in the RP2350's flash and the ID the bitstream reports at 0x141
NAME = "Tetris"
FILE = "tetris.hex.bin"
GAME_ID = 2
# First register of the game state, and its length: 25 board, 2 piece mask, x, y, 3 score, 2 lines, level, over, seq/busy
BASE = 0x150
LEN = 37
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
        # Event counter and busy flag before the transfer
        s0 = fpga.read(BASE + LEN - 1)
        # The state itself (consecutive addresses)
        fpga.read_block(BASE, buf)
        # Consistent when the FPGA was idle before, idle after, and finished no event in between
        if s0 == buf[LEN - 1] and not (s0 & 1):
            break
    # State bytes
    return buf


# Turn the state bytes into one text line: F:<board hex> S:<score> L:<lines> V:<level> O:<game over 0/1>
def format_line(buf):
    # Falling piece shape (16-bit mask), column (5-bit two's complement) and row
    mask = buf[25] | (buf[26] << 8)
    x = buf[27] & 31
    if x > 15:
        x -= 32
    y = buf[28] & 31
    # Score, lines, level and game over
    score = buf[29] | (buf[30] << 8) | (buf[31] << 16)
    lines = buf[32] | (buf[33] << 8)
    level = buf[34]
    over = buf[35] & 1
    # Board with the falling piece drawn on it
    frame = overlay(buf[:25], mask, x, y, over)
    # The line the PC display reads
    return "F:%s S:%d L:%d V:%d O:%d" % (binascii.hexlify(frame).decode(), score, lines, level, over)
