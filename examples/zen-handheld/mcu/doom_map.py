# doom_map.py - the map and the lookup tables of Doom Lite, shared by the rules model, the Verilog generator and the PC display
# The map is 16 x 16 tiles; '#' is a wall, 'P' the player start, 'E' an enemy start, '.' floor. A tile is 4096 units, so a position is x * 4096 + fraction.
import math

ROWS = (
    "################",
    "#P.............#",
    "#.####..####...#",
    "#.#........#.E.#",
    "#.#..####..#...#",
    "#....#..#......#",
    "###..#..#..###.#",
    "#......E.......#",
    "#.####..####...#",
    "#.#..........#.#",
    "#.#..####....#.#",
    "#..E.#..#......#",
    "#.##.#..#.####.#",
    "#..........E...#",
    "#..............#",
    "################",
)
TILE = 4096
# Wall bit of tile (row, col) at index row * 16 + col
WALLS = [ch == "#" for r in ROWS for ch in r]
assert len(ROWS) == 16 and all(len(r) == 16 for r in ROWS)
# Start positions in units (tile centres)
PLAYER = [((c * 16 + 8) * 256, (r * 16 + 8) * 256) for r, row in enumerate(ROWS) for c, ch in enumerate(row) if ch == "P"][0]
ENEMIES = [((c * 16 + 8) * 256, (r * 16 + 8) * 256) for r, row in enumerate(ROWS) for c, ch in enumerate(row) if ch == "E"]
NE = len(ENEMIES)
# Quarter wave of the sine: T[i] = round(256 sin(i pi / 256)), i = 0..128 (an angle is 0..511 for a full circle)
SINT = [round(256 * math.sin(i * math.pi / 256)) for i in range(129)]
# Wall height on screen in pixels from the corrected distance d (1/16 tile units): 1920 / d, at most 120
RECIP = [min(120, 1920 // max(d, 1)) for d in range(256)]


# Sine of an angle index (full circle = 512), 256 = one: signed
def sin_idx(a):
    a &= 511
    q, i = a >> 7, a & 127
    v = SINT[i] if q in (0, 2) else SINT[128 - i]
    return v if q < 2 else -v


# Cosine is the sine a quarter turn later
def cos_idx(a):
    return sin_idx(a + 128)
