# chess_view.py - Chess on the Zen 4: the game, the rules and the legal-move generator run in the FPGA; this file reads the state for the display
# and, on the computer's turn, runs the search (chess_engine.py) that asks the FPGA for the legal moves of every position it looks at.
# Register map: chess/chess_regs.v (40 state bytes from 0x150, then {seq, busy}); move service at 0x180..0x1AF (see chess_engine.py)
import fpga
import arcade_view
import chess_engine
import random

# Name shown in the menu, bitstream file in the RP2350's flash and the ID the bitstream reports at 0x141
NAME = "Chess"
FILE = "chess.hex.bin"
GAME_ID = 10
# State bytes of this game and the time between frames (ms)
N = 40
FRAME_MS = arcade_view.FRAME_MS
# Plies the computer looks ahead at most, and the time it may take for one move (ms): deeper searches are tried while the time lasts
DEPTH = 3
BUDGET_MS = 20000
# The searcher (made when the game starts) and the generator for the tie-break noise
engine = None


# Read a consistent state (see arcade_view)
def read_state():
    return arcade_view.read_state(N)


# The text line for the PC display
def format_line(buf):
    return arcade_view.format_line(GAME_ID, N, buf)


# Random number for breaking ties between equal moves (getrandbits needs the number of bits)
def rnd():
    return random.getrandbits(8)


# Called by the launcher after every frame: when the FPGA waits for the computer, search and send the move
def think(buf):
    global engine
    if engine is None:
        engine = chess_engine.Engine(fpga, DEPTH, BUDGET_MS)
    # The state byte 33 holds side to move (bit 0), the mode (bit 6, 0 = against the computer) and game over (bit 7)
    if (buf[33] & 1) and not (buf[33] & 0x40) and not (buf[33] & 0x80):
        engine.think(rnd)
