# gen_events.py - writes the random event list for tb_core.v: events_code.hex (one byte per event) and events_data.hex (200 bits per event)
# Event codes: 0 left, 1 right, 2 rotate, 3 hard drop, 4 gravity step, 5 restart,
#              6 load a board, 7 set the line count (level follows), 8 place a piece (kind, rotation, x, y)
import os
import random
import sys

# The Python model lives in model/ (and the frame drawing in mcu/)
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "model"))
from tetris_game import ROT, W, H, FULL  # noqa: E402

# Number of events written (the testbench has the same number in N)
N = 12000
# Seed, so every run tests the same thing
random.seed(20261102)


# Pack rows (list of 20 ints of 10 bits, row 0 first) into the 200-bit board value used by the hardware
def pack_rows(rows):
    # Bit r * 10 + c is cell c of row r
    v = 0
    for r, row in enumerate(rows):
        v |= row << (r * W)
    return v


# A board with nearly full rows at the bottom (holes at random places), empty at the top
def near_full_board():
    # Start empty
    rows = [0] * H
    # How many rows from the bottom are filled
    depth = random.randint(2, 10)
    for r in range(H - depth, H):
        # Most rows are full except one or two holes, some are random
        if random.random() < 0.7:
            row = FULL
            for _ in range(random.randint(1, 2)):
                row &= ~(1 << random.randrange(W))
        else:
            row = random.getrandbits(W)
        rows[r] = row
    # Sometimes put a few cells high up, so spawn can collide and end the game
    if random.random() < 0.1:
        rows[random.randint(0, 3)] = random.getrandbits(W)
    return pack_rows(rows)


# A well: the bottom n rows are full except column c (so a vertical I piece in column c clears n rows)
def well_board(n, c):
    # Empty board with n nearly full rows
    rows = [0] * H
    for r in range(H - n, H):
        rows[r] = FULL & ~(1 << c)
    return pack_rows(rows)


# Value for event 8: place a piece that fits inside the walls and above the floor
def piece_value(kind=None, rot=None):
    # Random kind and rotation unless given
    k = random.randrange(7) if kind is None else kind
    r = random.randrange(4) if rot is None else rot
    # Size of its box
    w = max(dx for dx, _ in ROT[k][r]) + 1
    h = max(dy for _, dy in ROT[k][r]) + 1
    # A position that fits the box
    x = random.randint(0, W - w)
    y = random.randint(0, H - h)
    # Pack as kind | rot << 3 | x << 5 | y << 10
    return k | (r << 3) | (x << 5) | (y << 10), k, r, w, h


# Build the event list
events = []
# Add one event (code, data)
def add(code, data=0):
    events.append((code, data))


# Generate until there are N events
while len(events) < N:
    # What to do next
    p = random.random()
    # Plain play: moves, rotations, gravity and the odd hard drop
    if p < 0.80:
        add(random.choices([0, 1, 2, 3, 4], weights=[20, 20, 22, 4, 34])[0])
    # A nearly full board, then a piece placed to land in it
    elif p < 0.88:
        add(6, near_full_board())
        v, *_ = piece_value()
        add(8, v)
    # A well for a vertical I piece: clears 1 to 4 rows
    elif p < 0.93:
        n = random.randint(1, 4)
        c = random.randrange(W)
        add(6, well_board(n, c))
        # Vertical I piece (kind 0, rotation 1 or 3) in the well column
        rot = random.choice([1, 3])
        w = max(dx for dx, _ in ROT[0][rot]) + 1
        # Column of the I piece cells inside its box
        dxs = [dx for dx, _ in ROT[0][rot]]
        x = c - dxs[0]
        add(8, 0 | (rot << 3) | (x << 5) | (0 << 10))
        add(3)
    # Line count changes: the level and the speed follow
    elif p < 0.95:
        add(7, random.choice([0, 5, 8, 9, 10, 17, 18, 19, 25, 28, 29, 39, 99, 129]))
    # Restart now and then
    elif p < 0.97:
        add(5)
    # Place a random piece
    else:
        v, *_ = piece_value()
        add(8, v)

# Cut to exactly N events and always end with a restart-free state
events = events[:N]

# Write the files for $readmemh
with open("events_code.hex", "w") as f:
    f.write("\n".join("%02x" % c for c, _ in events) + "\n")
with open("events_data.hex", "w") as f:
    f.write("\n".join("%050x" % d for _, d in events) + "\n")
print("wrote", len(events), "events")
