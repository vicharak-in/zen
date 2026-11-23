# chess_engine.py - the computer's search for Chess on the Zen 4: the RP2350 runs the search loop, the FPGA lists the legal moves
# The FPGA (chess/chess_core.v) holds the rules: for any position written to it, it hands back every legal move in a fixed order
# (castling, en passant, promotion and the king-safety test are all done in hardware). This file keeps the position stack and the
# alpha-beta search, plays moves on a copy (make) and scores leaves by material, like model/chess_game.py (which it is checked against).
# Register map (user bus): 0x180..0x19F scratch board, 0x1A0..0x1A5 scratch details, 0x1A8 go / status, 0x1A9 next, 0x1AC play, 0x1AD..0x1AF move
import time

# Directions N, NE, E, SE, S, SW, W, NW as (file step, rank step) and knight jumps (for the check test at positions without moves)
DF = (0, 1, 1, 1, 0, -1, -1, -1)
DR = (1, 1, 0, -1, -1, -1, 0, 1)
KN = ((1, 2), (2, 1), (2, -1), (1, -2), (-1, -2), (-2, -1), (-2, 1), (-1, 2))
# Piece values: none, pawn, knight, bishop, rook, queen, king
VALUE = (0, 100, 320, 330, 500, 900, 0)
# Promotion pieces in the order the generator tries them: queen, rook, bishop, knight
PROMO = (5, 4, 3, 2)
# Castling rights kept after a move from or to these squares
MASK = {4: 12, 0: 13, 7: 14, 60: 3, 56: 7, 63: 11}
MATE = 30000
INF = 32000
# Raised inside the search when the time budget is used up (MicroPython has no built-in TimeoutError)
class SearchTimeout(Exception):
    pass


# Registers of the move service
A_BOARD = 0x180
A_STAT = 0x1A8
A_NEXT = 0x1A9
A_UNLOCK = 0x1A7
A_PLAY = 0x1AC
A_MOVE = 0x1AD
# Registers of the game state
A_STATE = 0x150
STATE_N = 40


# A position: board (64 piece codes, a1 = 0), side to move, castling rights, en passant target square (-1 none), king squares, material (white minus black)
class Pos:
    def __init__(self, b, side, castle, ep, ksq, mat):
        self.b, self.side, self.castle, self.ep, self.ksq, self.mat = b, side, castle, ep, ksq, mat


# The position the FPGA reports in its 40 state bytes (board nibbles, castling, en passant file, side to move)
def from_state(buf):
    b = [0] * 64
    for i in range(32):
        b[2 * i] = buf[i] & 15
        b[2 * i + 1] = buf[i] >> 4
    castle = buf[32] & 15
    side = buf[33] & 1
    # The en passant target is on the third rank when black is to move, on the sixth when white is
    ep = ((16 if side else 40) + (buf[32] >> 5)) if (buf[32] & 16) else -1
    ksq = [b.index(6), b.index(14)]
    mat = 0
    for pc in b:
        v = VALUE[pc & 7]
        mat += -v if pc & 8 else v
    return Pos(b, side, castle, ep, ksq, mat)


# Is square sq attacked by pieces of colour by (0 white, 1 black)
def attacked(b, sq, by):
    f, r = sq & 7, sq >> 3
    for d in range(8):
        for k in range(1, 8):
            nf, nr = f + DF[d] * k, r + DR[d] * k
            if not (0 <= nf < 8 and 0 <= nr < 8):
                break
            c = b[nr * 8 + nf]
            if c == 0:
                continue
            if (c >> 3) == by:
                t = c & 7
                if t == 5 or (t == 4 and d % 2 == 0) or (t == 3 and d % 2 == 1) or (k == 1 and t == 6):
                    return True
                if k == 1 and t == 1 and ((by == 0 and d in (3, 5)) or (by == 1 and d in (1, 7))):
                    return True
            break
    for df, dr in KN:
        nf, nr = f + df, r + dr
        if 0 <= nf < 8 and 0 <= nr < 8 and b[nr * 8 + nf] == (2 | (by << 3)):
            return True
    return False


# Play move (frm, to, promo) on a copy of the position (no legality test: the FPGA only lists legal moves)
def make(p, frm, to, promo):
    b = p.b[:]
    ksq = p.ksq[:]
    pc, tc = b[frm], b[to]
    color, t = pc >> 3, pc & 7
    gain = VALUE[tc & 7]
    newp = pc
    if t == 1 and p.ep == to and tc == 0 and (frm & 7) != (to & 7):
        gain = 100
        b[to - 8 if color == 0 else to + 8] = 0
    if t == 1 and (to >> 3) in (0, 7):
        newp = PROMO[promo] | (color << 3)
        gain += VALUE[PROMO[promo]] - 100
    b[frm] = 0
    b[to] = newp
    if t == 6 and abs(to - frm) == 2:
        if to > frm:
            b[frm + 1], b[frm + 3] = b[frm + 3], 0
        else:
            b[frm - 1], b[frm - 4] = b[frm - 4], 0
    if t == 6:
        ksq[color] = to
    ep = (frm + to) // 2 if t == 1 and abs(to - frm) == 16 else -1
    castle = p.castle & MASK.get(frm, 15) & MASK.get(to, 15)
    return Pos(b, 1 - p.side, castle, ep, ksq, p.mat + (-gain if color else gain))


# The searcher: legal moves come from the FPGA over the Zen Link (fpga module), everything else is computed here
class Engine:
    def __init__(self, fpga, depth=3, budget_ms=20000):
        self.fpga = fpga
        self.depth = depth
        self.budget = budget_ms
        self.nodes = 0
        self.gens = 0
        self.deadline = 0

    # Write a position into the FPGA (it borrows the game position for this; think() writes the real one back before the move is played)
    def load(self, p):
        f = self.fpga
        # Board bytes (two squares each), then castling/en passant/side, en passant square, king squares and material
        buf = bytearray(38)
        for i in range(32):
            buf[i] = p.b[2 * i] | (p.b[2 * i + 1] << 4)
        buf[32] = p.castle | ((1 << 4) if p.ep >= 0 else 0) | (p.side << 5)
        buf[33] = p.ep if p.ep >= 0 else 0
        buf[34] = p.ksq[0]
        buf[35] = p.ksq[1]
        buf[36] = p.mat & 255
        buf[37] = (p.mat >> 8) & 255
        f.write_block(A_BOARD, buf)

    # All legal moves of a position, in the generator's order, from the FPGA
    def legal(self, p):
        f = self.fpga
        # A move left over from an aborted list would block the new request: step through it first
        lo = bytearray(4)
        f.read_block(A_STAT, lo)
        if lo[0] & 1:
            self.drain()
        self.load(p)
        f.write(A_STAT, 1)
        self.gens += 1
        moves = []
        st = bytearray(4)
        while True:
            f.read_block(A_STAT, st)
            if st[0] & 16:
                raise OSError("chess: position upload failed")
            if st[0] & 1:
                moves.append((st[1], st[2], st[3]))
                f.write(A_NEXT, 1)
            elif st[0] & 2:
                return moves
            if time.ticks_diff(time.ticks_ms(), self.deadline) > 0:
                raise SearchTimeout

    # After an aborted search the FPGA may hold a move: step through the rest of its list so it is ready for the next request
    def drain(self):
        st = bytearray(4)
        for _ in range(300):
            self.fpga.read_block(A_STAT, st)
            if st[0] & 2:
                return
            if st[0] & 1:
                self.fpga.write(A_NEXT, 1)

    # Negamax with alpha-beta: score from the side to move's point of view, material at the leaves
    def search(self, p, depth, ply, alpha, beta):
        self.nodes += 1
        if depth == 0:
            return p.mat if p.side == 0 else -p.mat
        moves = self.legal(p)
        if not moves:
            return -(MATE - ply) if attacked(p.b, p.ksq[p.side], 1 - p.side) else 0
        # Captures first: they cut the search short more often
        moves.sort(key=lambda m: -(p.b[m[1]] & 7))
        best = -INF
        for m in moves:
            v = -self.search(make(p, m[0], m[1], m[2]), depth - 1, ply + 1, -beta, -alpha)
            if v > best:
                best = v
                if v > alpha:
                    alpha = v
                    if alpha >= beta:
                        break
        return best

    # Best move of the position: deeper and deeper until the time budget is used (the last finished depth counts); ties are broken by noise
    def best_move(self, p, rnd=None):
        self.deadline = time.ticks_add(time.ticks_ms(), self.budget)
        self.nodes = 0
        self.gens = 0
        try:
            root = self.legal(p)
        except SearchTimeout:
            self.drain()
            raise RuntimeError("Chess: the FPGA does not list moves - is the new chess bitstream loaded? (recompile fpga/chess and deploy)")
        if not root:
            return None, 0
        # Fallback if even depth 1 does not finish: the first legal move
        best_m, best_v = root[0], 0
        for depth in range(1, self.depth + 1):
            try:
                cur_m, cur_v = None, -INF
                for m in root:
                    # Full window at the root so every move has its exact value (ties are then chosen by noise)
                    v = -self.search(make(p, m[0], m[1], m[2]), depth - 1, 1, -INF, INF)
                    if rnd:
                        v += rnd() & 3
                    if v > cur_v:
                        cur_m, cur_v = m, v
            except SearchTimeout:
                self.drain()
                break
            best_m, best_v = cur_m, cur_v
        return best_m, best_v

    # Is the FPGA waiting for the computer's move (flag bit 2 of the status)
    def waiting(self):
        st = bytearray(4)
        self.fpga.read_block(A_STAT, st)
        return bool(st[0] & 4)

    # One turn of the computer: read the game, search, send the move
    def think(self, rnd=None):
        if not self.waiting():
            return False
        buf = bytearray(STATE_N + 1)
        self.fpga.read_block(A_STATE, buf)
        root = from_state(buf)
        m = None
        try:
            m, v = self.best_move(root, rnd)
        finally:
            # The search used the game position as scratch: put the real one back, whatever happened
            self.load(root)
        if m is None:
            self.fpga.write(A_UNLOCK, 1)
            return False
        self.fpga.write_block(A_MOVE, bytes(m))
        self.fpga.write(A_PLAY, 1)
        return True
