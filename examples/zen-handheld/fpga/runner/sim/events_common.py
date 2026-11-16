# events_common.py - the event codes of the platformer simulation and how each one changes the Python model (used by the generator and the checker)
# Codes: 0 tick (data: a | b << 1), 1 restart, 2 place the hero, 3 place an enemy, 4 set the coins, 5 set lives, score and game over
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "model"))
sys.path.insert(0, os.path.join(HERE, "..", "..", "mcu"))
from runner_game import Runner  # noqa: E402
from runner_level import NC, NE  # noqa: E402


# Value for event 2: x | y << 11 | vy (5 bits) << 19 | ground << 24 | prev_a << 25
def pack_hero(x, y, vy, ground, prev_a):
    return x | (y << 11) | ((vy & 31) << 19) | (int(ground) << 24) | (int(prev_a) << 25)


# Value for event 3: enemy | x << 2 | goes_left << 13 | alive << 14
def pack_enemy(i, x, left, alive):
    return i | (x << 2) | (int(left) << 13) | (int(alive) << 14)


# Value for event 4: bit k = coin k collected
def pack_coins(flags):
    return sum(1 << k for k, f in enumerate(flags) if f)


# Value for event 5: lives | over << 2 | score << 3
def pack_stats(lives, over, score):
    return lives | (int(over) << 2) | (score << 3)


# Apply one event to the model r
def apply(r, code, data):
    if code == 0:
        r.tick(bool(data & 1), bool(data & 2))
    elif code == 1:
        r.restart()
    elif code == 2:
        r.x, r.y = data & 2047, (data >> 11) & 255
        v = (data >> 19) & 31
        r.vy = v - 32 if v >= 16 else v
        r.ground, r.prev_a = bool((data >> 24) & 1), bool((data >> 25) & 1)
    elif code == 3:
        e = r.enemies[data & 3]
        e.x, e.d, e.alive = (data >> 2) & 2047, (-1 if (data >> 13) & 1 else 1), bool((data >> 14) & 1)
    elif code == 4:
        r.coin_got = [bool((data >> k) & 1) for k in range(NC)]
        r.coins = sum(r.coin_got)
    elif code == 5:
        r.lives, r.over, r.score = data & 3, bool((data >> 2) & 1), (data >> 3) & 0xFFFFFF
