# check_runner.py - replays the events of the hardware log in the Python model and compares every step
# Usage: python3 check_runner.py runner.log
import sys
from events_common import apply, Runner

# Read the hardware log
rows = []
done = False
longest = None
for line in open(sys.argv[1]):
    p = line.split()
    if not p:
        continue
    if p[0] == "E":
        rows.append(p)
    elif p[0] == "DONE":
        done = True
    elif p[0] == "LONGEST":
        longest = int(p[1])
    elif p[0] == "TIMEOUT":
        print("FAIL: the hardware core hung:", line.strip())
        sys.exit(1)
if not done:
    print("FAIL: the simulation did not finish")
    sys.exit(1)

# The event list the testbench used
codes = [int(l, 16) for l in open("events_code.hex") if l.strip()]
datas = [int(l, 16) for l in open("events_data.hex") if l.strip()]
assert len(codes) == len(rows), (len(codes), len(rows))

# Statistics, so we know the test really exercised the rules
stats = {"jumps": 0, "stomps": 0, "enemy_hits": 0, "pit_deaths": 0, "coins": 0, "wins": 0, "game_overs": 0,
         "head_bumps": 0, "wall_stops": 0, "landings": 0, "respawns": 0, "restarts": 0}

# The model starts like the hardware after reset
r = Runner()
for n, (code, data, e) in enumerate(zip(codes, datas, rows)):
    before = (r.lives, r.over, r.score, r.coins, sum(1 for x in r.enemies if x.alive), r.x, r.y, r.vy, r.ground, r.won)
    apply(r, code, data)
    if code == 0 and not before[1]:
        alive_b, alive_a = before[4], sum(1 for x in r.enemies if x.alive)
        if r.vy < 0 and before[7] >= 0 and before[8]:
            stats["jumps"] += 1
        if alive_a < alive_b:
            stats["stomps"] += 1
        if r.lives < before[0]:
            if r.y == 146 and r.x == 32:
                stats["respawns"] += 1
            if before[6] >= 150 or r.over and before[6] >= 150:
                stats["pit_deaths"] += 1
            else:
                stats["enemy_hits"] += 1
        stats["coins"] += r.coins - before[3]
        if r.won and not before[9]:
            stats["wins"] += 1
        if r.over and not before[1] and not r.won:
            stats["game_overs"] += 1
        if r.vy == 0 and before[7] < 0:
            stats["head_bumps"] += 1
        if r.ground and not before[8]:
            stats["landings"] += 1
    if code == 1:
        stats["restarts"] += 1
    v = [int(x) for x in e[3:19]]
    got = (v[0], v[1], v[2], v[3], v[4], tuple(v[5:9]), v[9], v[10], v[11], v[12], v[13], v[14], v[15], int(e[19], 16))
    want = (r.x, r.y, r.vy, int(r.ground), int(r.prev_a),
            tuple(x.x for x in r.enemies), sum((1 << i) for i, x in enumerate(r.enemies) if x.d < 0),
            sum((1 << i) for i, x in enumerate(r.enemies) if x.alive), r.score, r.lives, r.coins, int(r.over), int(r.won),
            sum(1 << k for k, f in enumerate(r.coin_got) if f))
    if got != want:
        print("FAIL at event %d (code %d, data %x)" % (n, code, data))
        print("  hardware:", got)
        print("  python  :", want)
        sys.exit(1)
print("PASS: %d events identical (longest tick %s clocks)" % (len(rows), longest))
print("stats:", stats)
