# gen_level.py - fills the generated parts of runner_core.v from mcu/runner_level.py
# Usage: python3 gen_level.py runner_core.v.template ../runner_core.v
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "mcu"))
import runner_level as L  # noqa: E402

src, dst = sys.argv[1], sys.argv[2]
text = open(src).read()

# Constants: start, goal, number of coins
consts = "\n".join([
    "    localparam [10:0] START_X = 11'd%d;" % L.START_X,
    "    localparam [7:0]  START_Y = 8'd%d;" % L.START_Y,
    "    localparam [10:0] GOAL_X  = 11'd%d;" % L.GOAL_X,
    "    localparam [43:0] EX_INIT = {%s};" % ", ".join("11'd%d" % e[0] for e in reversed(L.ENEMIES)),
])
# One case line per column
cols = "\n".join("                8'd%d: colmask = 13'h%04X;" % (c, m) for c, m in enumerate(L.COLS))
# Enemy limits
enemies = "\n".join("            2'd%d: begin e_lo = 11'd%d; e_hi = 11'd%d; e_y = 8'd%d; end" % (i, lo, hi, y) for i, (lo, hi, y) in enumerate(L.ENEMIES))
# Coin cells
coins = "\n".join("            5'd%d: begin c_c = 7'd%d; c_r = 4'd%d; end" % (i, c, r) for i, (c, r) in enumerate(L.COINS))
for marker, body in (("//NC_VAL", str(L.NC)), ("//CONSTS", consts), ("//COLS_CASE", cols), ("//ENEMY_CASES", enemies), ("//COIN_CASES", coins)):
    assert marker in text, marker
    text = text.replace(marker, body)
open(dst, "w").write(text)
print("level written: %d columns, %d enemies, %d coins" % (L.LW, L.NE, L.NC))
