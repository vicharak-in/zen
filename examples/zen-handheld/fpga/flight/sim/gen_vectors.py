import random, cordic as c
random.seed(7)
T = []
T.append((0, 0, 16384, 0, 0, 0))                 # flat
T.append((0, 0, -16384, 0, 0, 0))                # upside down
T.append((8000, -5000, 14000, 5000, 0, 0))
T.append((-12000, 9000, 6000, 40000, 100, 200))
for _ in range(16):
    T.append(tuple([random.randint(-16384, 16384) for _ in range(3)] + [random.randint(0, 65535) for _ in range(3)]))
with open('vec.hex', 'w') as f:
    for ax, ay, az, yaw, rt, pt in T:
        r, p, vs = c.run(ax, ay, az, yaw, rt, pt)
        words = [ax, ay, az, yaw, rt, pt, r, p] + [w for v in vs for w in v]
        f.write(' '.join('%04x' % (w & 0xFFFF) for w in words) + '\n')
print(len(T), 'tests,', 8 + 3 * c.NV, 'words each')
