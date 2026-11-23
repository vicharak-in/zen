# render.py - draws every screen of the handheld into the 320 x 240 picture of gfx.py from the raw state bytes the FPGA games report
# No game rules here: it only turns state into pixels. The same code feeds the PC window (option A) and the SPI TFT (option B).
import math
import gfx
import runner_level as RL
import doom_map as DM
from frame import overlay
from pacman_view import cells as pacman_cells
from pacman_maze import W as PW, H as PH

# Colours shared by every screen: 0 background, 1 text, 2 dim text, 3 warning, 4 green
BG = (18, 18, 24)
TEXT = (230, 230, 230)
DIM = (140, 140, 150)
WARN = (240, 110, 110)
GREEN = (120, 220, 140)
ARENA = (8, 8, 14)


# Signed byte
def _s8(v):
    return v - 256 if v > 127 else v


# Side panel text lines at x, y downwards with 12 pixels between lines; returns the next free y
def _lines(x, y, rows, c, step=12):
    for r in rows:
        gfx.text(r, x, y, c)
        y += step
    return y


# The menu: title, the games with the selected one marked, and the hint
def menu(sel, names):
    gfx.palette([BG, TEXT, DIM, WARN, GREEN])
    gfx.text("Zen Handheld", 16, 6, 4, 2)
    # Rows are 19 pixels apart, closer when there are more than ten so the last one stays above the hint line
    step = 19 if len(names) <= 10 else 17
    for i, n in enumerate(names):
        gfx.text(("> " if i == sel else "  ") + n, 16, 30 + i * step, 1 if i == sel else 2, 2)
    gfx.text("A: next game     B: start", 16, 226, 2)


# A short message in the middle of the screen
def notice(s):
    gfx.palette([BG, TEXT, DIM, WARN, GREEN])
    gfx.center(s[:19], 112, 1, 2)


# An error: the text wrapped over several lines
def error(s):
    gfx.palette([BG, TEXT, DIM, WARN, GREEN])
    gfx.text("ERROR", 8, 8, 3, 2)
    for i in range(0, min(len(s), 38 * 12), 38):
        gfx.text(s[i:i + 38], 8, 36 + (i // 38) * 12, 1)


# Tetris: the locked board with the falling piece, score, lines and level
def tetris(buf):
    gfx.palette([BG, TEXT, DIM, WARN, GREEN, (40, 40, 52)])
    mask = buf[25] | (buf[26] << 8)
    x = buf[27] & 31
    if x > 15:
        x -= 32
    y = buf[28] & 31
    over = buf[35] & 1
    board = overlay(buf[:25], mask, x, y, over)
    for r in range(20):
        for c in range(10):
            i = r * 10 + c
            on = (board[i >> 3] >> (i & 7)) & 1
            gfx.rect(8 + c * 11 + 1, 10 + r * 11 + 1, 9, 9, 4 if on else 5)
    score = buf[29] | (buf[30] << 8) | (buf[31] << 16)
    lines = buf[32] | (buf[33] << 8)
    yy = _lines(130, 12, ["Score %d" % score, "Lines %d" % lines, "Level %d" % buf[34]], 1, 16)
    _lines(130, yy + 14, ["A: left", "B: right", "A+B: rotate", "Long press: drop", "Hold A+B 2 s: menu"], 2)
    if over:
        gfx.text("GAME OVER", 130, 150, 3, 2)


# Pac-Man: maze, dots, Pac-Man and three ghosts (cell codes as ASCII digits from pacman_view.cells)
def pacman(buf):
    gfx.palette([BG, TEXT, DIM, WARN, (50, 70, 190), (235, 215, 170), (250, 215, 60), (235, 70, 70), (240, 150, 190), (80, 215, 230), (120, 130, 255)])
    cl = pacman_cells(buf)
    t = 11
    for y in range(PH):
        for x in range(PW):
            c = cl[y * PW + x]
            px, py = 4 + x * t, 4 + y * t
            if c == 49:
                gfx.rect(px + 1, py + 1, t - 2, t - 2, 4)
            elif c == 50:
                gfx.rect(px + 4, py + 4, 2, 2, 5)
            elif c == 51:
                gfx.disc(px + 5, py + 5, 3, 5)
            elif c == 52:
                gfx.disc(px + 5, py + 5, 4, 6)
            elif 53 <= c <= 56:
                gfx.disc(px + 5, py + 5, 4, {53: 7, 54: 8, 55: 9, 56: 10}[c])
    score = buf[62] | (buf[63] << 8) | (buf[64] << 16)
    yy = _lines(222, 12, ["Score", "%d" % score, "Lives %d" % (buf[65] & 3), "Level %d" % (buf[66] + 1)], 1, 14)
    _lines(222, yy + 10, ["A: left", "B: right", "A+B: turn", "around", "Hold A+B", "2 s: menu"], 2)
    if buf[67] & 1:
        gfx.text("GAME", 222, 170, 3, 2)
        gfx.text("OVER", 222, 190, 3, 2)


# Mario Lite: camera x for a hero at x (the view stops at both ends of the level)
def camera_x(x):
    return max(0, min(x - 96, RL.LW * RL.TILE - 320))


# One tile of the level at screen position px, py
def _tile(col, row, px, py):
    mask = RL.COLS[col]
    if not (mask >> row) & 1:
        return
    pipe = False
    for c, h in RL.PIPES:
        if c == col and RL.GROUND_ROW - h <= row < RL.GROUND_ROW:
            pipe = True
    if row >= RL.GROUND_ROW:
        gfx.rect(px, py, 16, 16, 5)
        if not (mask >> (row - 1)) & 1:
            gfx.rect(px, py, 16, 4, 6)
    elif pipe:
        gfx.rect(px, py, 16, 16, 7)
        gfx.rect(px + 3, py, 2, 16, 8)
    else:
        gfx.rect(px, py, 16, 16, 9)
        gfx.frame(px, py, 16, 16, 10)


# Mario Lite: the level in view, flag, coins, beetles and the robot hero
def runner(buf):
    gfx.palette([BG, TEXT, DIM, WARN, (110, 190, 235), (150, 95, 50), (90, 190, 90), (40, 160, 90), (110, 220, 150), (190, 100, 60),
                 (120, 55, 30), (220, 70, 70), (250, 215, 60), (150, 60, 160), (60, 90, 200), (30, 30, 40)])
    hx = buf[0] | ((buf[1] & 7) << 8)
    hy = buf[2]
    flags = buf[3]
    score = buf[4] | (buf[5] << 8) | (buf[6] << 16)
    coin_bits = buf[9] | (buf[10] << 8) | (buf[11] << 16) | (buf[12] << 24)
    oy = 16
    cam = camera_x(hx)
    gfx.rect(0, oy, 320, RL.LH * 16, 4)
    for col in range(cam // 16, min(RL.LW, (cam + 320) // 16 + 2)):
        for row in range(RL.LH):
            _tile(col, row, col * 16 - cam, oy + row * 16)
    # Flag
    fx = RL.GOAL_X - cam
    gfx.rect(fx + 7, oy + 48, 2, 112, 1)
    gfx.poly([(0, 0), (12, 5), (0, 10)], fx + 9, oy + 48, 11)
    # Coins not collected yet
    for k, (c, r) in enumerate(RL.COINS):
        if not (coin_bits >> k) & 1:
            gfx.disc(c * 16 + 8 - cam, oy + r * 16 + 8, 3, 12)
    # Beetles
    for k in range(RL.NE):
        lo, hi = buf[13 + 2 * k], buf[14 + 2 * k]
        if hi & 0x80:
            ex = lo | ((hi & 7) << 8)
            ey = RL.ENEMIES[k][2]
            gfx.disc(ex - cam + 6, oy + ey + 5, 5, 13)
            gfx.rect(ex - cam, oy + ey + 5, 12, 5, 13)
            gfx.rect(ex - cam + 3, oy + ey + 3, 2, 2, 1)
            gfx.rect(ex - cam + 8, oy + ey + 3, 2, 2, 1)
    # Hero: white head with a blue visor line, blue body, red antenna
    x, y = hx - cam, oy + hy
    gfx.rect(x + 1, y + 1, 10, 8, 1)
    gfx.rect(x + 1, y + 1, 10, 2, 14)
    gfx.rect(x + 3, y + 5, 2, 2, 15)
    gfx.rect(x + 7, y + 5, 2, 2, 15)
    gfx.rect(x + 2, y + 9, 8, 3, 14)
    legs = 2 if flags & 1 else 3
    gfx.rect(x + 2, y + 12, 3, legs, 15)
    gfx.rect(x + 7, y + 12, 3, legs, 15)
    gfx.rect(x + 6, y - 2, 1, 3, 11)
    gfx.rect(0, 0, 320, oy, 0)
    gfx.text("SCORE %06d  COINS %d/%d  LIVES %d" % (score, buf[8], RL.NC, buf[7]), 4, 4, 1)
    gfx.text("A: jump (hold = higher)  B: stand still", 4, 212, 2)
    gfx.text("Hold A+B 2 s: menu", 4, 224, 2)
    if flags & 2:
        gfx.text("YOU WIN!" if flags & 4 else "GAME OVER", 100, 100, 1 if flags & 4 else 3, 3)


# Arcade games draw the 160 x 120 world at scale 2 (the whole screen); world rectangle
def _wr(c, x, y, w, h):
    gfx.rect(x * 2, y * 2, w * 2, h * 2, c)


# Arcade palette: 0 playfield, 1 text, 2 dim, 3 warning, then up to 12 colours of the game
def _arena(extra):
    gfx.palette([ARENA, TEXT, DIM, WARN] + list(extra))


# Flappy Bird Lite
def flyer(buf):
    _arena([(60, 170, 100), (250, 215, 60), (20, 20, 30)])
    y = buf[0]
    for k in range(3):
        x = (buf[5 + 3 * k] | ((buf[6 + 3 * k] & 1) << 8)) - 16
        gap = buf[7 + 3 * k]
        _wr(4, x, 0, 16, gap)
        _wr(4, x, gap + 40, 16, 120 - gap - 40)
    _wr(5, 40, y, 8, 8)
    _wr(6, 45, y + 2, 2, 2)
    gfx.text("SCORE %d" % (buf[2] | (buf[3] << 8)), 4, 4, 1)
    if buf[4]:
        gfx.center("GAME OVER", 110, 3, 3)


# Pong Lite
def pong(buf):
    _arena([(250, 215, 60)])
    for y in range(0, 120, 8):
        _wr(2, 79, y, 2, 4)
    _wr(1, 8, buf[0], 4, 24)
    _wr(1, 148, buf[1], 4, 24)
    _wr(4, buf[2], buf[3], 4, 4)
    gfx.text("YOU %d" % buf[6], 40, 4, 1)
    gfx.text("FPGA %d" % buf[7], 210, 4, 1)
    if buf[8]:
        win = buf[6] > buf[7]
        gfx.center("YOU WIN!" if win else "GAME OVER", 110, 1 if win else 3, 3)


# Snake Lite: 16 x 12 grid of 18 pixel cells
def snake(buf):
    _arena([(120, 220, 140), (200, 255, 210), (235, 80, 80)])
    occ = int.from_bytes(bytes(buf[:24]), "little")
    ox, oy, t = 16, 24, 18
    gfx.frame(ox - 1, oy - 1, 16 * t + 2, 12 * t + 2, 2)
    for i in range(192):
        if (occ >> i) & 1:
            gfx.rect(ox + (i & 15) * t + 1, oy + (i >> 4) * t + 1, t - 2, t - 2, 4)
    hx, hy = buf[24] & 15, buf[24] >> 4
    gfx.rect(ox + hx * t + 1, oy + hy * t + 1, t - 2, t - 2, 5)
    fx, fy = buf[25] & 15, buf[25] >> 4
    gfx.disc(ox + fx * t + 9, oy + fy * t + 9, 6, 6)
    gfx.text("LENGTH %d / 64" % buf[27], 16, 8, 1)
    if buf[28] & 3:
        win = buf[28] & 2
        gfx.center("YOU WIN!" if win else "GAME OVER", 110, 1 if win else 3, 3)


# Space Shooter Lite
def shooter(buf):
    _arena([(235, 90, 90), (240, 170, 70), (120, 200, 240), (120, 220, 140)])
    alive = buf[6] | (buf[7] << 8) | (buf[8] << 16)
    fx, fy = buf[9], buf[10]
    for i in range(18):
        if (alive >> i) & 1:
            x, y = fx + (i % 6) * 16, fy + (i // 6) * 14
            _wr(4 + i // 6, x, y, 10, 8)
            _wr(0, x + 2, y + 2, 2, 2)
            _wr(0, x + 6, y + 2, 2, 2)
    _wr(7, buf[0], 108, 12, 8)
    _wr(7, buf[0] + 5, 105, 2, 3)
    for k in range(3):
        if buf[12 + 2 * k] != 255:
            _wr(1, buf[11 + 2 * k], buf[12 + 2 * k], 2, 6)
    if buf[18] != 255:
        _wr(3, buf[17], buf[18], 2, 6)
    gfx.text("SCORE %d  LIVES %d  WAVE %d" % (buf[3] | (buf[4] << 8), buf[1], buf[2] + 1), 4, 4, 1)
    if buf[5]:
        gfx.center("GAME OVER", 110, 3, 3)


# Doom Lite: wall columns the FPGA marched (80 columns of 4 pixels), enemies as red figures, a gun, a crosshair and a small map
def doom(buf):
    walls = [(g, g * 3 // 4, g // 2) for g in (74, 128, 190, 240)]
    foes = [(97, 30, 30), (147, 30, 30), (197, 30, 30)]
    gfx.palette([ARENA, TEXT, (150, 150, 160), WARN, (30, 30, 48), (58, 54, 50)] + walls + foes + [(70, 70, 78), (110, 110, 120), (255, 230, 90)])
    gfx.rect(0, 0, 320, 120, 4)
    gfx.rect(0, 120, 320, 120, 5)
    for c in range(80):
        v = buf[28 + c]
        h, enemy = v & 127, v & 128
        if enemy:
            eh = h * 3 // 2
            gfx.rect(c * 4, 120 - eh // 2 + h // 4, 4, eh, 10 + min(2, h // 40))
        elif h:
            gfx.rect(c * 4, 120 - h, 4, 2 * h, 6 + min(3, h // 31))
    # Gun with a flash when it fires, and the crosshair
    gfx.rect(150, 205, 20, 35, 13)
    gfx.rect(156, 195, 8, 15, 14)
    if buf[7] & 4:
        gfx.disc(160, 192, 8, 15)
    gfx.rect(154, 120, 13, 1, 1)
    gfx.rect(160, 114, 1, 13, 1)
    # Map in the top right corner
    mx, my, t = 268, 4, 3
    gfx.rect(mx, my, 48, 48, 0)
    for r in range(16):
        for c in range(16):
            if DM.WALLS[r * 16 + c]:
                gfx.rect(mx + c * t, my + r * t, t, t, 2)
    left = 0
    for k in range(4):
        ex = buf[8 + 5 * k] | (buf[9 + 5 * k] << 8)
        ey = buf[10 + 5 * k] | (buf[11 + 5 * k] << 8)
        if buf[12 + 5 * k]:
            left += 1
            gfx.rect(mx + ex * t // 4096 - 1, my + ey * t // 4096 - 1, 2, 2, 3)
    px = mx + (buf[0] | (buf[1] << 8)) * t // 4096
    py = my + (buf[2] | (buf[3] << 8)) * t // 4096
    a = (buf[4] | ((buf[5] & 1) << 8)) * 2 * math.pi / 512
    gfx.line(px, py, px + 4 * math.cos(a), py + 4 * math.sin(a), 1)
    gfx.rect(px - 1, py - 1, 2, 2, 1)
    gfx.text("HEALTH %d  ENEMIES %d" % (buf[6], left), 4, 4, 1)
    if buf[7] & 3:
        win = buf[7] & 2
        gfx.center("YOU WIN!" if win else "YOU DIED", 100, 1 if win else 3, 3)


# Chess piece outlines in a 100 x 100 box (y down): polygons, circles (x, y, r) and detail lines per piece type 1..6
PIECE_BASE = [(24, 92), (24, 84), (30, 80), (70, 80), (76, 84), (76, 92)]
PIECES = {
    1: ([[(41, 46), (59, 46), (63, 62), (68, 80), (32, 80), (37, 62)]], [(50, 33, 13)], []),
    2: ([[(30, 80), (34, 58), (44, 44), (34, 44), (24, 50), (21, 42), (34, 28), (40, 14), (48, 21), (58, 17), (67, 32), (73, 54), (70, 80)]], [], []),
    3: ([[(37, 80), (43, 56), (57, 56), (63, 80)], [(50, 15), (63, 30), (65, 43), (57, 57), (43, 57), (35, 43), (37, 30)]], [(50, 12, 4)], [((45, 36), (56, 26))]),
    4: ([[(32, 80), (36, 38), (64, 38), (68, 80)], [(28, 20), (28, 40), (72, 40), (72, 20), (63, 20), (63, 28), (56, 28), (56, 20), (44, 20), (44, 28), (37, 28), (37, 20)]], [], []),
    5: ([[(33, 80), (39, 48), (61, 48), (67, 80)], [(28, 26), (36, 54), (43, 24), (50, 54), (57, 24), (64, 54), (72, 26), (66, 58), (34, 58)]],
        [(28, 21, 4), (43, 17, 4), (57, 17, 4), (72, 21, 4)], []),
    6: ([[(33, 80), (39, 44), (61, 44), (67, 80)], [(35, 56), (35, 42), (44, 32), (56, 32), (65, 42), (65, 56)],
         [(46, 8), (54, 8), (54, 15), (61, 15), (61, 23), (54, 23), (54, 32), (46, 32), (46, 23), (39, 23), (39, 15), (46, 15)]], [], []),
}
CH_NAMES = {1: "pawn", 2: "knight", 3: "bishop", 4: "rook", 5: "queen", 6: "king"}
CHESS_STATUS = ("", "CHECK", "CHECKMATE", "STALEMATE", "DRAW", "DRAW")
# Board position on the screen: squares of 28 pixels, files a-h across, ranks 8 to 1 down
CH_SQ = 28
CH_X, CH_Y = 10, 4


# One piece (code 1..6 white, 9..14 black) in the square with top left (x, y) and size sz; colours: fill 11/12, edge 13/14
def _piece(code, x, y, sz):
    white = code < 8
    fill, edge = (11, 13) if white else (12, 14)
    k = sz / 100.0
    shape = PIECES[code & 7]
    for poly in [PIECE_BASE] + shape[0]:
        pts = [(q[0] * k, q[1] * k) for q in poly]
        gfx.poly(pts, x, y, fill)
        gfx.poly(pts, x, y, edge, False)
    for cx, cy, r in shape[1]:
        gfx.disc(int(x + cx * k), int(y + cy * k), max(1, int(r * k)), fill)
    for a, b in shape[2]:
        gfx.line(x + a[0] * k, y + a[1] * k, x + b[0] * k, y + b[1] * k, edge)
    if code & 7 == 2:
        gfx.disc(int(x + 49 * k), int(y + 30 * k), 1, edge)


# Chess: board with pieces, last move, check, the cursor (piece blue, target green), and a side panel
def chess(buf):
    gfx.palette([BG, TEXT, DIM, WARN, (236, 224, 200), (176, 140, 108), (214, 206, 120), (186, 168, 80), (225, 90, 80), (60, 120, 220),
                 (40, 170, 90), (250, 248, 240), (46, 44, 52), (40, 38, 46), (235, 232, 224)])
    board = [(buf[i >> 1] >> (4 * (i & 1))) & 15 for i in range(64)]
    side = buf[33] & 1
    status = (buf[33] >> 1) & 7
    phase = (buf[33] >> 4) & 3
    mode = (buf[33] >> 6) & 1
    over = buf[33] & 128
    frm, to, promo = buf[34], buf[35], buf[36]
    last = (buf[37], buf[38])
    # Mode choice screen
    if phase == 3:
        gfx.text("Chess", 16, 20, 1, 3)
        gfx.text(("> " if mode == 0 else "  ") + "1 player vs FPGA", 16, 80, 1 if mode == 0 else 2, 2)
        gfx.text(("> " if mode == 1 else "  ") + "2 players", 16, 110, 1 if mode == 1 else 2, 2)
        gfx.text("A: change     B: start", 16, 170, 2)
        gfx.text("In the game: A = next piece / target", 16, 196, 2)
        gfx.text("B = select / play, B on piece = back", 16, 208, 2)
        return
    for sq in range(64):
        f, r = sq & 7, sq >> 3
        light = (f + r) % 2 == 1
        col = (4 if light else 5) if sq not in last else (6 if light else 7)
        gfx.rect(CH_X + f * CH_SQ, CH_Y + (7 - r) * CH_SQ, CH_SQ, CH_SQ, col)
    # King in check or mated
    if status in (1, 2):
        kc = 6 | (side << 3)
        if kc in board:
            ks = board.index(kc)
            gfx.rect(CH_X + (ks & 7) * CH_SQ, CH_Y + (7 - (ks >> 3)) * CH_SQ, CH_SQ, CH_SQ, 8)
    for sq, c in enumerate(board):
        if c:
            _piece(c, CH_X + (sq & 7) * CH_SQ + 2, CH_Y + (7 - (sq >> 3)) * CH_SQ + 1, CH_SQ - 4)
    for sq, color in ((frm, 9), (to, 10)):
        if sq < 64:
            gfx.frame(CH_X + (sq & 7) * CH_SQ, CH_Y + (7 - (sq >> 3)) * CH_SQ, CH_SQ, CH_SQ, color, 3)
    for i in range(8):
        gfx.text("abcdefgh"[i], CH_X + i * CH_SQ + 10, CH_Y + 8 * CH_SQ + 3, 2)
        gfx.text(str(i + 1), 1, CH_Y + (7 - i) * CH_SQ + 10, 2)
    # Panel
    x = CH_X + 8 * CH_SQ + 6
    if over:
        gfx.text("Game over", x, 6, 1)
    else:
        gfx.text("Black" if side else "White", x, 6, 1)
        if mode == 0:
            gfx.text("(FPGA)" if side else "(you)", x, 18, 2)
    y = 36
    if status:
        gfx.text(CHESS_STATUS[status], x, y, 3 if status < 3 else 1)
        y += 12
    if status == 2:
        gfx.text(("Black" if side == 0 else "White") + " wins", x, y, 1)
        y += 12
    if not over and frm < 64:
        pc = board[frm]
        names = "abcdefgh"
        gfx.text(CH_NAMES[pc & 7], x, y + 4, 1)
        gfx.text("%s%d" % (names[frm & 7], (frm >> 3) + 1), x, y + 16, 1)
        if to < 64:
            gfx.text("to %s%d" % (names[to & 7], (to >> 3) + 1), x, y + 28, 1)
            if (pc & 7) == 1 and (to >> 3) in (0, 7):
                gfx.text("=" + CH_NAMES[(5, 4, 3, 2)[promo]], x, y + 40, 1)
    # Captured pieces: what is missing from the start set
    start = {1: 8, 2: 2, 3: 2, 4: 2, 5: 1}
    y = 112
    for colr, label in ((1, "White lost"), (0, "Black lost")):
        gfx.text(label, x, y, 2)
        y += 11
        miss = ""
        for t in (5, 4, 3, 2, 1):
            n = start[t] - sum(1 for c in board if c == t + 8 * (1 - colr))
            miss += ("N" if t == 2 else CH_NAMES[t][0].upper()) * n
        gfx.text(miss[:10] or "-", x, y, 1)
        y += 14
    _lines(x, 172, ["A: next", "B: select", "B again:", " back", "A+B 2 s:", " menu"], 2, 10)


# Which draw function belongs to which game ID (the ID the bitstream reports at 0x141)
GAMES = {2: tetris, 3: pacman, 4: runner, 5: flyer, 6: pong, 7: snake, 8: shooter, 9: doom, 10: chess}


# Draw the screen of a game from its state bytes
def game(gid, buf):
    GAMES[gid](buf)
