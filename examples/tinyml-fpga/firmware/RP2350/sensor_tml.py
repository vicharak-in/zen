# sensor_tml.py - MicroPython, on the RP2350: turn live BMI323 motion into a tinyml-fpga classification on the FPGA.
#   1. check wiring:   import sensor_tml as s; s.check(scl=?, sda=?)
#   2. record data:    s.setup(scl, sda); s.record("still", 30); s.record("shake", 30); ...       (30 one-second windows per motion)
#   3. on the PC:      mpremote cp :sensor-data.csv sensor-data.csv ; python3 firmware/pc-tools/train-sensor.py
#   4. back on board:  mpremote cp firmware/RP2350/model-sensor.tml firmware/RP2350/labels.txt : ; s.live()
# Feature vector (24 numbers per 1 s window): for each of the 6 axes the mean, the mean absolute deviation, the minimum and the maximum.

import time

import bmi323
import tinyml_zink as tml

# Samples per window (the sensor runs at 50 Hz, so 50 samples = 1 second)
WINDOW = 50
# Microseconds between samples
PERIOD_US = 20000
# The sensor object, set by setup()
_imu = None


def check(scl, sda):
    """Wiring test: scan the bus, read the chip id and print a few live readings. Tilt and shake the board while it runs."""
    i2c = bmi323.make_i2c(scl, sda)
    found = bmi323.scan(i2c)
    if not found:
        print("nothing answers: check 3.3V, GND, SCL, SDA (and the pull-ups)")
        return
    imu = bmi323.BMI323(i2c, 0x68 if 0x68 in found else found[0])
    for _ in range(10):
        r = imu.read()
        print("acc g %.2f %.2f %.2f   gyro dps %.0f %.0f %.0f" % r if r else "invalid sample (0x8000)")
        time.sleep_ms(300)


def setup(scl, sda, addr=None):
    """Open the sensor for recording and live use; finds the address (0x68 or 0x69) by itself unless one is given."""
    global _imu
    i2c = bmi323.make_i2c(scl, sda)
    if addr is None:
        found = [a for a in i2c.scan() if a in (0x68, 0x69)]
        if not found:
            raise OSError("no BMI323 on the bus: check wiring (scan found %s)" % [hex(a) for a in i2c.scan()])
        addr = found[0]
    print("BMI323 at", hex(addr))
    _imu = bmi323.BMI323(i2c, addr)


def window():
    """Collect one second of samples at 50 Hz; returns a list of 6 lists (one per axis). Raises OSError if the sensor gave invalid samples."""
    cols = [[] for _ in range(6)]
    bad = 0
    nxt = time.ticks_us()
    for _ in range(WINDOW):
        s = _imu.read()
        if s is None:
            bad += 1                                           # chip said 'no valid sample': skip it
        else:
            for a in range(6):
                cols[a].append(s[a])
        nxt = time.ticks_add(nxt, PERIOD_US)
        while time.ticks_diff(nxt, time.ticks_us()) > 0:
            pass
    if bad > 5:
        raise OSError("sensor gave %d invalid samples in one window" % bad)
    return cols


def features(cols):
    """24 numbers from one window: mean, mean absolute deviation, min, max of every axis."""
    f = []
    for a in range(6):
        k = 1.0 if a < 3 else 0.01                             # gyro in units of 100 deg/s so all axes have a similar size
        c = [v * k for v in cols[a]]
        m = sum(c) / len(c)
        f += [m, sum(abs(v - m) for v in c) / len(c), min(c), max(c)]
    return f


def count(label, path="sensor-data.csv"):
    """How many windows of this motion are already saved in the CSV file (0 if the file does not exist)."""
    try:
        with open(path) as f:
            return sum(1 for line in f if line.startswith(label + ","))
    except OSError:
        return 0


def forget(label, path="sensor-data.csv"):
    """Delete every saved window of one motion (the rest of the file is kept)."""
    try:
        keep = [line for line in open(path) if not line.startswith(label + ",")]
    except OSError:
        return
    with open(path, "w") as f:
        for line in keep:
            f.write(line)


def record(label, n=30, path="sensor-data.csv"):
    """Record n one-second windows of the motion called `label`. The windows are saved only when all n are done, replacing any older
    recording of the same motion, so a failed or interrupted run never leaves half a motion behind and other motions stay untouched."""
    import os
    print("recording '%s' x%d: start the motion now" % (label, n))
    time.sleep_ms(2000)
    lines = []
    for k in range(n):
        lines.append(label + "," + ",".join("%.4f" % v for v in features(window())) + "\n")
        print(k + 1, end=" ")
    forget(label, path)                                      # replace the old recording of this motion
    with open(path, "a") as out:
        for line in lines:
            out.write(line)
    print("\nsaved %d windows of '%s' (file now has %d windows of it)" % (len(lines), label, count(label, path)))


def live(model="model-sensor.tml", labels="labels.txt"):
    """Classify motion forever (Ctrl+C to stop): one answer per second, computed on the FPGA."""
    names = [l.strip() for l in open(labels) if l.strip()]
    print("engine config 0x%02X" % tml.start())
    tml.load(model)
    while True:
        t0 = time.ticks_us()
        f = features(window())
        t1 = time.ticks_us()
        best, scores = tml.predict(f)
        t2 = time.ticks_us()
        print("%-10s scores %s   (features %d ms, FPGA %d us incl. link, %d clocks)" % (names[best], scores, time.ticks_diff(t1, t0) // 1000, time.ticks_diff(t2, t1), tml.cycles()))
