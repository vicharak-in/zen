# cordic.py - bit-exact model of the FPGA flight engine (flight_engine.v / cordic_core.v).
# Plain integers only, so the same file runs on the PC (reference for the simulation) and on the
# RP2350 MicroPython (software fallback with the identical API and identical results).
# Angles are 16-bit binary angles: 65536 = 360 degrees.  Datapath 20 bit, 3 guard bits (<<3). Vertex ROM is pre-scaled by 1/K^3: every rotation stage scales the whole vector by K (the idle axis through shift-add mulk).
N_IT = 15
NV = 19
ANG = [8192, 4836, 2555, 1297, 651, 326, 163, 81, 41, 20, 10, 5, 3, 1, 1]
ROM = [0, 0, 4036, -660, 0, 0, 660, 0, 0, 0, 734, 0, 0, -550, 0, 0, 0, -3302, -3669, 0, -1284, 3669, 0, -1284, -660, 0, 1101, 660, 0, 1101, -660, 0, -1651, 660, 0, -1651, 0, 2018, -3119, 0, 440, -1284, -1651, 0, -3302, 1651, 0, -3302, -294, 0, -2018, 294, 0, -2018, 0, 367, -3302]
GUARD = 3
W = 20
KSH = (1, 3, 6, 8, 9)          # K = 1.6467602 ~ 1 + 1/2 + 1/8 + 1/64 + 1/256 + 1/512 (shift-add, no multiplier)


def _chk(v):
    assert -(1 << (W - 1)) <= v < (1 << (W - 1)), "datapath overflow"
    return v


def s16(v):
    v &= 0xFFFF
    return v - 65536 if v & 0x8000 else v


def rot(x, y, ang):
    """Rotation mode: rotate (x, y) by ang. Gain K stays in the result."""
    a = (ang + 0x2000) & 0xFFFF
    q = a >> 14
    z = (a & 0x3FFF) - 0x2000
    if q == 1: x, y = -y, x
    elif q == 2: x, y = -x, -y
    elif q == 3: x, y = y, -x
    for i in range(N_IT):
        if z >= 0:
            x, y, z = x - (y >> i), y + (x >> i), z - ANG[i]
        else:
            x, y, z = x + (y >> i), y - (x >> i), z + ANG[i]
        _chk(x); _chk(y)
    return x, y


def vec(x, y):
    """Vectoring mode: returns (K*sqrt(x^2+y^2), atan2(y, x) as 16-bit angle)."""
    zoff = 0
    if x < 0:
        x, y, zoff = -x, -y, 0x8000
    z = 0
    for i in range(N_IT):
        if y >= 0:
            x, y, z = x + (y >> i), y - (x >> i), z + ANG[i]
        else:
            x, y, z = x - (y >> i), y + (x >> i), z - ANG[i]
        _chk(x); _chk(y)
    return x, (z + zoff) & 0xFFFF


def mulk(y):
    return sum(y >> s for s in KSH) + y


def angles(ax, ay, az):
    """Roll and pitch from the accelerometer (int16 raw values): two vectoring passes."""
    xm, roll = vec(az << GUARD, ay << GUARD)
    _, pitch = vec(xm, mulk(-(ax << GUARD)))
    return roll, pitch


def vertices(yaw, roll, pitch):
    """Rotate the plane: yaw about y, then pitch about x, then roll about z. Returns [(x, y, z)] int16."""
    out = []
    for i in range(NV):
        x, y, z = (ROM[3 * i] << GUARD, ROM[3 * i + 1] << GUARD, ROM[3 * i + 2] << GUARD)
        x, z = rot(x, z, yaw);   y = mulk(y)
        y, z = rot(y, z, pitch); x = mulk(x)
        x, y = rot(x, y, roll);  z = mulk(z)
        out.append((x >> GUARD, y >> GUARD, z >> GUARD))
    return out


def run(ax, ay, az, yaw=0, roll_trim=0, pitch_trim=0):
    """Whole engine job: returns (roll_measured, pitch_measured, vertex list), like the FPGA registers."""
    r, p = angles(ax, ay, az)
    return r, p, vertices(yaw, (r - roll_trim) & 0xFFFF, (p - pitch_trim) & 0xFFFF)
