# check_core.py - replays the events of the hardware log in the Python model and compares every step
# Usage: python3 check_core.py core.log
# Compared after every event: piece kind, rotation, x, y, game over, score, lines, level and the 200-cell frame
import os
import sys

# The Python model lives in model/ (and the frame drawing in mcu/)
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "model"))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "mcu"))
import tetris_game  # noqa: E402
from tetris_game import Game, W, H  # noqa: E402
from frame import overlay  # noqa: E402

# Read the hardware log
kinds = []
events = []
done = False
for line in open(sys.argv[1]):
    p = line.split()
    if not p:
        continue
    if p[0] == "K":
        kinds.append(int(p[1]))
    elif p[0] == "E":
        events.append(p)
    elif p[0] == "DONE":
        done = True
    elif p[0] == "TIMEOUT":
        print("FAIL: the hardware core hung:", line.strip())
        sys.exit(1)
if not done:
    print("FAIL: the simulation did not finish")
    sys.exit(1)

# The event list the testbench used
codes = [int(l, 16) for l in open("events_code.hex") if l.strip()]
datas = [int(l, 16) for l in open("events_data.hex") if l.strip()]
assert len(codes) == len(events), (len(codes), len(events))

# The Python model takes its piece kinds from the hardware log, in spawn order
pos = 0
def next_kind(self):
    global pos
    k = kinds[pos]
    pos += 1
    return k
Game._next_kind = next_kind

# Statistics, so we know the test really exercised the rules
stats = {"clear1": 0, "clear2": 0, "clear3": 0, "clear4": 0, "over": 0, "levelups": 0, "restarts": 0}
# Bag check: kinds since the last restart must form permutations of 0..6, seven at a time
bag_start = 0
bag_ok = True

# Start the model (its first piece takes the first logged kind)
g = Game()
for n, (code, data, e) in enumerate(zip(codes, datas, events)):
    before_lines = g.lines
    before_level = g.level
    before_over = g.over
    if code == 0:
        g.act("left")
    elif code == 1:
        g.act("right")
    elif code == 2:
        g.act("rotate")
    elif code == 3:
        g.act("drop")
    elif code == 4:
        g.fall()
    elif code == 5:
        # Check the bag of the finished game, then start a new one
        seg = kinds[bag_start:pos]
        for s in range(0, len(seg) - len(seg) % 7, 7):
            if sorted(seg[s:s + 7]) != list(range(7)):
                bag_ok = False
        bag_start = pos
        g = Game()
        stats["restarts"] += 1
    elif code == 6:
        g.rows = [(data >> (r * W)) & ((1 << W) - 1) for r in range(H)]
    elif code == 7:
        g.lines = data & 0xFFFF
        g.level = g.lines // 10
    else:
        g.kind = data & 7
        g.rot = (data >> 3) & 3
        g.x = (data >> 5) & 31
        g.y = (data >> 10) & 31
    # Statistics
    d = g.lines - before_lines
    if code in (2, 3, 4) and 1 <= d <= 4 and g.lines > before_lines:
        stats["clear%d" % d] += 1
    if g.level > before_level and code in (3, 4):
        stats["levelups"] += 1
    if g.over and not before_over:
        stats["over"] += 1
    # Hardware values of this event
    kind, rot, x, y, over, score, lines, level = (int(v) for v in e[3:11])
    board = int(e[11], 16).to_bytes(25, "little")
    mask = int(e[12], 16)
    # The MCU draws the piece onto the board: this checks that step too
    frame = overlay(board, mask, x, y, over)
    packed = 0
    for r in range(H):
        packed |= g.rows[r] << (r * W)
    got = (kind, rot, x, y, int(over), score, lines, level, frame, board)
    want = (g.kind, g.rot, g.x, g.y, int(g.over), g.score, g.lines, g.level, g.frame_bytes(), packed.to_bytes(25, "little"))
    if got != want:
        print("FAIL at event %d (code %d)" % (n, code))
        print("  hardware:", got[:8], got[8].hex(), got[9].hex())
        print("  python  :", want[:8], want[8].hex(), want[9].hex())
        sys.exit(1)

# The whole bag history must be permutations, and the model must have used exactly the logged kinds
seg = kinds[bag_start:pos]
for s in range(0, len(seg) - len(seg) % 7, 7):
    if sorted(seg[s:s + 7]) != list(range(7)):
        bag_ok = False
if not bag_ok:
    print("FAIL: 7-bag order broken")
    sys.exit(1)
if pos != len(kinds):
    print("FAIL: hardware spawned %d pieces, model used %d" % (len(kinds), pos))
    sys.exit(1)
print("PASS: %d events identical, %d pieces, bag ok" % (len(events), len(kinds)))
print("stats:", stats)
