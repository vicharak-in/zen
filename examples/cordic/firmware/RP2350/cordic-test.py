import math, time
from zen_spi import ZenSPI
s = ZenSPI()
def q(mode, a, b=0):
    if mode == "cos": p = (int(a*64) & 0x3F)
    elif mode == "sin": p = (int(a*64) & 0x3F) | 0x40
    elif mode == "tan": p = (int(a*64) & 0x3F) | 0xC0
    else: p = ((a & 7) << 3) | (b & 7) | 0x80
    s.exchange(p); time.sleep_us(15); r = s.exchange(0)
    if r & 0x80: r -= 256
    return r if mode == "mul" else r/64
for d in (10, 20, 30, 45):
    x = math.radians(d)
    print(d, "deg  cos %.3f/%.3f  sin %.3f/%.3f  tan %.3f/%.3f" % (q("cos",x), math.cos(x), q("sin",x), math.sin(x), q("tan",x), math.tan(x)))
for a, b in ((2,3), (-4,3), (-2,-2), (3,3)):
    print("mul", a, b, "=", q("mul", a, b), "expect", a*b)
