# flight.py - flight simulator app of the Zen handheld: GY-91 tilt -> FPGA CORDIC engine -> red plane in a blue sky with clouds on the TFT
# Used by sink_tft.py (menu entry "Flight"): begin(disp) / step(bits) / end(). It needs cordic.py next to it.
# Standalone test without any bitstream (software CORDIC on the RP2350):  import flight; flight.test()
import time
from math import sqrt
import cordic

# ---------------------------------------------------------------- wiring / tuning (change here)
SDA, SCL = 22, 23                       # GY-91 on I2C1
PIN_SCK, PIN_MOSI, PIN_DC, PIN_CS, PIN_RST = 18, 19, 20, 17, None   # TFT (PIN_RST = None if tied to 3V3)
BAUD = 20_000_000                       # raise to 40_000_000 for ~2x frame rate if the picture stays clean
MADCTL = 0x28                           # landscape; try 0xE8 / 0x68 / 0xA8 if the picture is rotated or mirrored
RB_SWAP = False                         # True if the plane looks blue and the sky red
AXES = (0, 1, 2)                        # which sensor axis is (ax forward, ay right, az up)
SIGN = (1, 1, 1)                        # flip a sign if tilting the board moves the plane the wrong way
W, H = 320, 240                        # the screen
VW, VH = 200, 136                       # the flight window that is redrawn and sent every frame (smaller = faster)
VX, VY = (W - VW) // 2, (H - VH) // 2
FOCUS = 190                             # perspective strength
DIST = 3 * 16384 + 16384 // 2           # camera distance behind the plane (16384 = 1.0)
N_CLOUDS = 4
VIEW_C, VIEW_S = 0.8192, 0.5736         # camera looks down 35 degrees from above and behind


def rgb(r, g, b):
    if RB_SWAP: r, b = b, r
    v = ((r & 0xF8) << 8) | ((g & 0xFC) << 3) | (b >> 3)
    return bytes((v >> 8, v & 255))


# ---------------------------------------------------------------- plane faces (vertex indices from gen.py)
FACES = ((0, 3, 1), (0, 2, 3), (0, 1, 4), (0, 4, 2), (3, 1, 5), (2, 3, 5), (1, 4, 5), (4, 2, 5),
         (8, 6, 10), (9, 11, 7), (16, 14, 5), (17, 5, 15), (13, 12, 18))


# ---------------------------------------------------------------- engine back ends (same API)
class SoftEngine:
    """CORDIC on the RP2350 (reference model, identical results to the FPGA)."""
    def run(self, ax, ay, az, yaw, rt, pt):
        return cordic.run(ax, ay, az, yaw, rt, pt)
    def buttons(self):
        return 0


class FpgaEngine:
    """CORDIC on the FPGA: write raw IMU values, start, read angles and rotated vertices over the Zen Link."""
    def __init__(self):
        import fpga
        self.f = fpga
        self.out = bytearray(6 * cordic.NV)
        self.inb = bytearray(12)
    def run(self, ax, ay, az, yaw, rt, pt):
        f = self.f
        b = self.inb
        for i, v in enumerate((ax, ay, az, yaw, rt, pt)):
            b[2 * i] = v & 255
            b[2 * i + 1] = (v >> 8) & 255
        f.write_block(0x100, b)
        f.write(0x10C, 1)
        for _ in range(200):                      # job takes ~50 us; the link is slower than that
            if not (f.read(0x20) & 1):
                break
        t = bytearray(4)
        f.read_block(0x110, t)
        f.read_block(0x200, self.out)
        o = self.out
        vs = []
        for i in range(cordic.NV):
            k = 6 * i
            vs.append((cordic.s16(o[k] | o[k + 1] << 8), cordic.s16(o[k + 2] | o[k + 3] << 8),
                       cordic.s16(o[k + 4] | o[k + 5] << 8)))
        return t[0] | t[1] << 8, t[2] | t[3] << 8, vs
    def buttons(self):
        return self.f.read(0x140)


# ---------------------------------------------------------------- GY-91 accelerometer (MPU-9250 at 0x68)
class Imu:
    def __init__(self):
        from machine import I2C, Pin
        try:
            self.i2c = I2C(1, sda=Pin(SDA), scl=Pin(SCL), freq=400000)
        except Exception:
            from machine import SoftI2C
            self.i2c = SoftI2C(sda=Pin(SDA), scl=Pin(SCL), freq=400000)
        self.i2c.writeto_mem(0x68, 0x6B, b'\x01')    # wake, PLL clock
        self.i2c.writeto_mem(0x68, 0x1C, b'\x00')    # +-2 g
        self.i2c.writeto_mem(0x68, 0x1D, b'\x04')    # accel low-pass about 20 Hz
        time.sleep_ms(50)
        self.a = [0, 0, 16384]
    def read(self):
        d = self.i2c.readfrom_mem(0x68, 0x3B, 6)
        raw = [cordic.s16(d[0] << 8 | d[1]), cordic.s16(d[2] << 8 | d[3]), cordic.s16(d[4] << 8 | d[5])]
        v = [raw[AXES[i]] * SIGN[i] for i in range(3)]
        a = self.a
        for i in range(3):                           # light smoothing (1/2 weight)
            a[i] += (v[i] - a[i]) >> 1
        return a[0], a[1], a[2]


# ---------------------------------------------------------------- renderer (works on the RP2350 and on a PC)
class Scene:
    def __init__(self, seed=1):
        self.fb = bytearray(VW * VH * 2)
        self.sky = rgb(60, 130, 215)                 # solid blue sky: the window blends into the rest of the screen
        self.seed = seed
        self.clouds = [self._new_cloud(True) for _ in range(N_CLOUDS)]
        self.white = rgb(250, 250, 255)
        self.shade = rgb(205, 218, 240)
        self.red = [rgb(int(240 * k), int(25 * k), int(25 * k)) for k in (0.35, 0.45, 0.55, 0.65, 0.75, 0.85, 0.95, 1.0)]

    @staticmethod
    def skyrow(rows):
        return rgb(60, 130, 215) * (W * rows)

    def rnd(self):                                   # tiny LCG: no 'random' module needed
        self.seed = (self.seed * 1103515245 + 12345) & 0x7FFFFFFF
        return (self.seed >> 8) / 8388608.0

    def _new_cloud(self, anywhere=False):
        z = 1.2 + self.rnd() * 6.0 if anywhere else 7.0 + self.rnd() * 1.5
        return [(self.rnd() - 0.5) * 9.0, (self.rnd() - 0.5) * 5.0, z, 0.5 + self.rnd() * 0.7]

    def step_clouds(self, speed, dx, dy):
        for c in self.clouds:
            c[2] -= speed
            c[0] += dx
            c[1] += dy
            if c[2] < 0.5:
                c[:] = self._new_cloud()

    def hspan(self, y, x0, x1, col):
        if y < 0 or y >= VH: return
        if x0 < 0: x0 = 0
        if x1 > VW - 1: x1 = VW - 1
        if x1 < x0: return
        o = (y * VW + x0) * 2
        self.fb[o:o + (x1 - x0 + 1) * 2] = col * (x1 - x0 + 1)

    def disc(self, cx, cy, r, col):
        for dy in range(-r, r + 1):
            h = int(sqrt(r * r - dy * dy))
            self.hspan(cy + dy, cx - h, cx + h, col)

    def draw_cloud(self, c):
        z = c[2]
        s = FOCUS / (z * 1.0)
        cx = VW // 2 + int(c[0] * s)
        cy = VH // 2 + int(c[1] * s)
        r = int(c[3] * s * 0.55)
        if r < 2 or r > 160 or cx < -3 * r or cx > VW + 3 * r or cy < -2 * r or cy > VH + 2 * r:
            return
        for ox, oy, k in ((-1.1, 0.25, 0.8), (1.1, 0.25, 0.75), (0, 0.35, 0.7), (-0.55, -0.15, 0.85), (0.5, -0.2, 0.9)):
            self.disc(cx + int(ox * r), cy + int(oy * r), max(2, int(r * k)), self.white)

    def tri(self, a, b, c, col):
        if a[1] > b[1]: a, b = b, a
        if b[1] > c[1]: b, c = c, b
        if a[1] > b[1]: a, b = b, a
        x0, y0 = a; x1, y1 = b; x2, y2 = c
        if y2 == y0: return
        for y in range(max(y0, 0), min(y2, VH - 1) + 1):
            xa = x0 + (x2 - x0) * (y - y0) // (y2 - y0)
            if y < y1:
                xb = x0 + (x1 - x0) * (y - y0) // (y1 - y0) if y1 != y0 else x1
            else:
                xb = x1 + (x2 - x1) * (y - y1) // (y2 - y1) if y2 != y1 else x1
            if xa > xb: xa, xb = xb, xa
            self.hspan(y, xa, xb, col)

    def draw_plane(self, vs, ox, oy, dist):
        pts = []
        vw = []
        for x, y, z in vs:                           # fixed camera tilt (plain integers, same on PC and MCU)
            vw.append((x, int(y * VIEW_C + z * VIEW_S), int(z * VIEW_C - y * VIEW_S)))
        vs = vw
        for x, y, z in vs:
            zc = z + dist
            pts.append((VW // 2 + ox + x * FOCUS // zc, VH // 2 + oy - y * FOCUS // zc, zc))
        order = []
        for f in FACES:
            order.append((-(pts[f[0]][2] + pts[f[1]][2] + pts[f[2]][2]), f))
        order.sort()
        for _, f in order:
            a, b, c = f
            va, vb, vc = vs[a], vs[b], vs[c]
            ux, uy, uz = vb[0] - va[0], vb[1] - va[1], vb[2] - va[2]
            wx, wy, wz = vc[0] - va[0], vc[1] - va[1], vc[2] - va[2]
            nx, ny, nz = uy * wz - uz * wy, uz * wx - ux * wz, ux * wy - uy * wx
            ln = sqrt(nx * nx + ny * ny + nz * nz) or 1.0
            lit = abs(0.35 * nx + 0.85 * ny - 0.4 * nz) / ln          # light from above-left-behind
            self.tri(pts[a][:2], pts[b][:2], pts[c][:2], self.red[min(7, int(lit * 8))])

    def frame(self, vs, ox, oy, dist):
        fb = self.fb
        row = self.sky * VW
        n = len(row)
        fb[0:n] = row                                # sky: one row, then doubled until the buffer is full
        while n < len(fb):
            m = min(n, len(fb) - n)
            fb[n:n + m] = fb[0:m]
            n += m
        for c in sorted(self.clouds, key=lambda c: -c[2]):
            self.draw_cloud(c)
        self.draw_plane(vs, ox, oy, dist)
        return self.fb


# ---------------------------------------------------------------- ILI9341 (self-contained, no other module needed)
# ---------------------------------------------------------------- game logic
DEG = 65536 / 360.0


def pose(roll_deg, pitch_deg):
    """Tilt -> flight: bank slides the plane sideways and yaws it into the turn, nose-down tilt flies it forward."""
    ox = int(max(-60, min(60, -roll_deg * 1.6)))
    oy = int(max(-40, min(40, pitch_deg * 1.1)))
    dist = int(DIST + max(-20000, min(30000, pitch_deg * 700)))
    yaw = int(-roll_deg * 0.35 * DEG) & 0xFFFF
    return ox, oy, dist, yaw


class Flight:
    def __init__(self, disp, use_fpga):
        self.disp = disp
        self.eng = FpgaEngine() if use_fpga else SoftEngine()
        self.imu = Imu()
        self.scene = Scene()
        self.yaw = 0
        self.prev = 3
        self.tr = self.tp = 0
        # paint the whole screen sky blue once; afterwards only the window is sent
        band = Scene.skyrow(16)
        for y in range(0, H, 16):
            disp.blit(band, 0, y, W, 16)
        self.n, self.t0 = 0, time.ticks_ms()
        # level calibration: hold the board flat for the first half second
        sr = sp = 0
        for _ in range(16):
            r, p, _v = self.eng.run(*self.imu.read(), 0, 0, 0)
            sr += cordic.s16(r); sp += cordic.s16(p)
            time.sleep_ms(30)
        self.rt, self.pt = (sr // 16) & 0xFFFF, (sp // 16) & 0xFFFF

    def step(self, bits=0):
        if bits & 2 and not self.prev & 2:           # A: level again
            self.rt, self.pt = self.last_r, self.last_p
        self.prev = bits
        ax, ay, az = self.imu.read()
        r, p, vs = self.eng.run(ax, ay, az, self.yaw, self.rt, self.pt)
        self.last_r, self.last_p = r, p
        roll = cordic.s16(r - self.rt) / DEG
        pitch = cordic.s16(p - self.pt) / DEG
        ox, oy, dist, self.yaw = pose(roll, pitch)
        self.scene.step_clouds(0.045 + max(0.0, pitch) * 0.002, -roll * 0.0009, pitch * 0.0007)
        t1 = time.ticks_ms()
        fb = self.scene.frame(vs, ox, oy, dist)
        t2 = time.ticks_ms()
        self.disp.blit(fb, VX, VY, VW, VH)
        self.tr, self.tp = time.ticks_diff(t2, t1), time.ticks_diff(time.ticks_ms(), t2)
        self.n += 1
        if self.n % 20 == 0:
            now = time.ticks_ms()
            print("flight %.1f fps  draw %d ms  send %d ms  roll %5.1f  pitch %5.1f" % (20000.0 / time.ticks_diff(now, self.t0), self.tr, self.tp, roll, pitch))
            self.t0 = now


fl = None


def begin(disp, use_fpga=True):
    """Start the app (the flight bitstream must already be loaded when use_fpga is True)."""
    global fl
    import gc
    gc.collect()
    fl = Flight(disp, use_fpga)


def step(bits):
    fl.step(bits)


def end():
    global fl
    fl = None
    import gc
    gc.collect()


def test(use_fpga=False):
    """Run on its own from the REPL (software CORDIC, no bitstream); stop with Ctrl-C."""
    import spi_display
    begin(spi_display.Display("ili9341_240x320", 90), use_fpga)
    while True:
        step(0)
