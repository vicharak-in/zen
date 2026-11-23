# gen_events.py - writes the random event list for tb_runner_core.v: events_code.hex and events_data.hex
# The generator runs the Python model alongside, so it can create the interesting situations on purpose:
# falling onto an enemy, walking into one, standing next to a coin, the flag, a pit edge, the last life
import random
from events_common import apply, Runner, pack_hero, pack_enemy, pack_coins, pack_stats, NC
from runner_level import ENEMIES, COINS, GOAL_X, PITS, TILE, START_Y, GROUND_Y, LW

# Number of events (the testbench has the same number in N)
N = 20000
# Same events every run
random.seed(20261103)

# The model that follows the events, and the list of events
r = Runner()
events = []


# Add one event: apply it to the model and remember it
def add(code, data=0):
    events.append((code, data))
    apply(r, code, data)


# A tick with the buttons given
def tick(a, b=False):
    add(0, int(a) | (int(b) << 1))


# Build the event list
while len(events) < N:
    q = random.random()
    # Plain play: A pressed now and then, B rarely
    if q < 0.70:
        tick(random.random() < 0.35, random.random() < 0.08)
    # A short stretch of play with a simple bot (jump at pits, walls and enemies), so the hero gets far
    elif q < 0.80:
        for _ in range(random.randint(10, 60)):
            near = False
            for dx in range(1, 21):
                c = (r.x + 11 + dx) // TILE
                if c < LW and (r.x + 11 + dx) // TILE < LW:
                    from runner_level import solid
                    if solid(c, 9):
                        near = True
            for dx in range(1, 7):
                c = (r.x + 11 + dx) // TILE
                from runner_level import solid
                if not solid(c, 10):
                    near = True
            for e in r.enemies:
                if e.alive and 0 < e.x - (r.x + 12) < 40 and r.y > e.y - 30:
                    near = True
            tick(near and not (r.ground and r.prev_a))
    # Place the hero at a random spot
    elif q < 0.84:
        add(2, pack_hero(random.randrange(0, LW * TILE - 12), random.randrange(0, 200), random.randint(-12, 10),
                         random.random() < 0.5, random.random() < 0.5))
    # Hero standing on the ground somewhere
    elif q < 0.87:
        add(2, pack_hero(random.randrange(0, LW * TILE - 12), START_Y, 0, True, random.random() < 0.3))
    # Falling onto an enemy
    elif q < 0.91:
        i = random.randrange(len(ENEMIES))
        e = r.enemies[i]
        add(3, pack_enemy(i, random.randint(ENEMIES[i][0], ENEMIES[i][1]), random.random() < 0.5, True))
        add(2, pack_hero(e.x + random.randint(-9, 9), e.y - 14 - random.randint(0, 12), random.randint(1, 10), False, False))
        tick(random.random() < 0.3)
    # Walking into an enemy from the side, sometimes with one life left
    elif q < 0.93:
        i = random.randrange(len(ENEMIES))
        e = r.enemies[i]
        if random.random() < 0.5:
            add(5, pack_stats(random.choice([1, 2, 3]), False, random.randrange(5000)))
        add(2, pack_hero(e.x - random.randint(2, 14), e.y - random.randint(0, 10), 0, True, True))
        tick(False)
    # Falling onto an enemy so that the feet end up exactly 11, 12 or 13 pixels into it (the stomp limit is 12)
    elif q < 0.94:
        i = random.randrange(len(ENEMIES))
        e = r.enemies[i]
        add(3, pack_enemy(i, random.randint(ENEMIES[i][0], ENEMIES[i][1]), random.random() < 0.5, True))
        depth = random.choice([11, 12, 13])
        vy0 = random.randint(0, 8)
        add(2, pack_hero(e.x, e.y - 14 + depth - (vy0 + 1), vy0, False, False))
        tick(random.random() < 0.3)
    # At the top of the screen, rising: the ceiling stops the hero
    elif q < 0.945:
        add(2, pack_hero(random.randrange(0, LW * TILE - 12), random.randint(0, 6), random.randint(-12, -1), False, True))
        tick(True)
    # Next to a coin
    elif q < 0.95:
        c, row = random.choice(COINS)
        add(2, pack_hero(c * TILE + random.randint(-11, 15), row * TILE + random.randint(-13, 15), random.randint(-3, 3), False, False))
        tick(random.random() < 0.3, random.random() < 0.5)
    # Collected coins set at random
    elif q < 0.96:
        add(4, pack_coins([random.random() < 0.5 for _ in range(NC)]))
    # At the flag
    elif q < 0.97:
        add(2, pack_hero(GOAL_X - random.randint(0, 6), START_Y, 0, True, False))
        tick(False)
    # At the edge of a pit
    elif q < 0.985:
        p = random.choice(PITS)
        add(2, pack_hero(p * TILE - random.randint(8, 30), START_Y, 0, True, False))
        for _ in range(random.randint(1, 12)):
            tick(random.random() < 0.2)
    # Last life and a fall into a pit
    elif q < 0.99:
        add(5, pack_stats(1, False, random.randrange(1000)))
        add(2, pack_hero(random.choice(PITS) * TILE + 2, 190, 5, False, False))
        tick(False)
    # New game, sometimes after game over
    else:
        add(1)

with open("events_code.hex", "w") as f:
    f.write("\n".join("%02x" % c for c, d in events[:N]) + "\n")
with open("events_data.hex", "w") as f:
    f.write("\n".join("%016x" % d for c, d in events[:N]) + "\n")
print("wrote %d events" % N)
