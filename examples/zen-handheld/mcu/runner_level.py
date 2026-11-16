# runner_level.py - the level of the platformer ("Mario Lite"): tiles, enemies, coins, goal and start (used by the model, the board and sim/gen_level.py)
# Units: tiles are 16 x 16 pixels; the level is LW columns wide and LH rows high; the origin is the top left corner.
LW = 96
LH = 12
TILE = 16
# Hero box (pixels) and enemy box (pixels)
HERO_W, HERO_H = 12, 14
ENEMY_W, ENEMY_H = 12, 10
# Hero start (top left of the box, pixels) and the x where the flag stands
START_X = 32
START_Y = 146
GOAL_X = 92 * TILE
# Rows of the ground and the first ground row (pixels)
GROUND_ROW = 10
GROUND_Y = GROUND_ROW * TILE

# Pits: columns with no ground
PITS = (20, 21, 47, 48, 49, 70, 71)
# Pipes: (column, height in tiles); they stand on the ground
PIPES = ((14, 2), (33, 3), (60, 2), (76, 3))
# Floating bricks: (first column, last column, row)
BRICKS = ((24, 28, 7), (38, 41, 6), (52, 55, 7))
# Stairs near the end: (column, height in tiles)
STAIRS = ((82, 1), (83, 2), (84, 3), (85, 4))

# Walking enemies: (left limit x, right limit x, top y of the box), all stand on the ground
ENEMIES = ((240, 290, GROUND_Y - ENEMY_H), (690, 730, GROUND_Y - ENEMY_H),
           (1000, 1100, GROUND_Y - ENEMY_H), (1240, 1290, GROUND_Y - ENEMY_H))
NE = len(ENEMIES)

# Coins: tile cells (column, row), all in the air
COINS = ((8, 9), (9, 9), (10, 9), (25, 6), (26, 6), (27, 6), (20, 8), (21, 8), (39, 5), (40, 5),
         (48, 8), (53, 6), (54, 6), (65, 5), (66, 5), (71, 8), (79, 7), (88, 9), (89, 9), (90, 9))
NC = len(COINS)


# Build the 12-bit mask of every column: bit r is 1 when the tile in row r is solid
def _build():
    cols = [0] * LW
    # Ground, two rows deep, except the pits
    for c in range(LW):
        if c not in PITS:
            cols[c] |= (1 << GROUND_ROW) | (1 << (GROUND_ROW + 1))
    # Pipes
    for c, h in PIPES:
        for r in range(GROUND_ROW - h, GROUND_ROW):
            cols[c] |= 1 << r
    # Bricks
    for c0, c1, r in BRICKS:
        for c in range(c0, c1 + 1):
            cols[c] |= 1 << r
    # Stairs
    for c, h in STAIRS:
        for r in range(GROUND_ROW - h, GROUND_ROW):
            cols[c] |= 1 << r
    return tuple(cols)


COLS = _build()


# True when the tile at (col, row) is solid: past the left or right end of the level counts as a wall, above or below as air
def solid(col, row):
    if col < 0 or col >= LW:
        return True
    if row < 0 or row >= LH:
        return False
    return bool((COLS[col] >> row) & 1)
