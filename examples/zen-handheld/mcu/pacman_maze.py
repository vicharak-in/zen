# pacman_maze.py - the Pac-Man maze and the helpers that read it (no hardware code: runs on the RP2350, on the PC and is used to generate the FPGA maze ROM)
# '#' wall, '.' dot, 'o' power pellet, ' ' empty path

# Maze size in cells
W = 19
H = 21

# Top half of the maze (rows 0 to 9) and the middle row (row 10); the bottom half is the top half mirrored
_TOP = (
    "###################",
    "#........#........#",
    "#o##.###.#.###.##o#",
    "#.................#",
    "#.##.#.#####.#.##.#",
    "#....#...#...#....#",
    "####.### # ###.####",
    "####.#       #.####",
    "####.# ## ## #.####",
    "####.# ## ## #.####",
)
_MID = "#.......   .......#"

# All 21 rows: top half, middle row, mirrored bottom half
ROWS = _TOP + (_MID,) + tuple(reversed(_TOP))

# Where Pac-Man starts (x, y) and where the three ghosts start
PAC_START = (9, 17)
GHOST_START = ((8, 10), (9, 10), (10, 10))
# Corner that ghost 2 runs to when Pac-Man is close
CORNER = (1, 19)

# Direction numbers: 0 up, 1 right, 2 down, 3 left
DX = (0, 1, 0, -1)
DY = (-1, 0, 1, 0)


# True when the cell is a wall or outside the maze
def is_wall(x, y):
    # Outside the maze counts as a wall
    if x < 0 or x >= W or y < 0 or y >= H:
        return True
    # Wall character
    return ROWS[y][x] == "#"


# True when the cell is a power pellet
def is_pellet(x, y):
    return ROWS[y][x] == "o"


# True when the cell starts with a dot (dots and pellets, but not the start cells of Pac-Man and the ghosts)
def has_dot(x, y):
    # Start cells have no dot
    if (x, y) == PAC_START or (x, y) in GHOST_START:
        return False
    return ROWS[y][x] in ".o"
