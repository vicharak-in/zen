# pacman_view.py - reads the Pac-Man state from the FPGA, draws the maze with dots, Pac-Man and ghosts, and makes the text line for the PC
# No game rules here: the game runs in the FPGA. Register map: pacman/pacman_regs.v
import fpga
from pacman_maze import W, H, is_wall, is_pellet, has_dot

# Name shown in the menu, bitstream file in the RP2350's flash and the ID the bitstream reports at 0x141
NAME = "Pac-Man"
FILE = "pacman.hex.bin"
GAME_ID = 3
# First register of the game state, and its length: 50 dots, Pac-Man x y dir, 3 ghosts x y fright, 3 score, lives, level, over, seq/busy
BASE = 0x150
LEN = 69
# Time between frames (ms)
FRAME_MS = 33
# Tries to get a consistent reading before the last one is used anyway
TRIES = 5

# Cell codes as ASCII digits: path '0', wall '1', dot '2', pellet '3', Pac-Man '4', ghosts '5' '6' '7', frightened ghost '8'
# The empty maze (walls only), built once
EMPTY = bytearray(W * H)
for _i in range(W * H):
    EMPTY[_i] = 49 if is_wall(_i % W, _i // W) else 48
# The cells that start with a dot, and the character each shows while its dot is there
DOT_CELLS = []
for _i in range(W * H):
    if has_dot(_i % W, _i // W):
        DOT_CELLS.append(_i)
DOT_CHAR = bytearray(W * H)
for _i in DOT_CELLS:
    DOT_CHAR[_i] = 51 if is_pellet(_i % W, _i // W) else 50


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


# The 399 cell characters: maze, dots still there, ghosts, then Pac-Man on top
def cells(buf):
    # Start from the empty maze
    out = bytearray(EMPTY)
    # Dots that are still on the board
    for i in DOT_CELLS:
        if (buf[i >> 3] >> (i & 7)) & 1:
            out[i] = DOT_CHAR[i]
    # Ghosts (frightened ones are '8')
    for k in range(3):
        o = 53 + 3 * k
        out[buf[o + 1] * W + buf[o]] = 56 if buf[o + 2] & 1 else 53 + k
    # Pac-Man
    out[buf[51] * W + buf[50]] = 52
    return out


# Turn the state bytes into one text line: P:<399 cell digits> S:<score> L:<lives> V:<level> O:<game over 0/1>
def format_line(buf):
    # Score, lives, level and game over
    score = buf[62] | (buf[63] << 8) | (buf[64] << 16)
    return "P:%s S:%d L:%d V:%d O:%d" % (cells(buf).decode(), score, buf[65] & 3, buf[66], buf[67] & 1)
