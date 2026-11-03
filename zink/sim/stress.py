# stress.py - checks accuracy and speed of the fpga link at several delay settings.
# Run on the board with:  python -m mpremote run stress.py
import fpga, utime

# This holds the pulse-delay settings to try, slowest (safest) first.
# One loop is about 20 ns; the FPGA needs a half period of ~130 ns (6 loops or more).
DELAYS = (20, 14, 10, 8, 7, 6, 5, 4, 3)
# This holds how many single-register round trips to run per setting.
N_SINGLE = 2000
# This holds how many block round trips to run per setting.
N_BLOCK = 300
# This holds how many 128-byte frames to time per setting.
N_RATE = 400

fpga.init()

# This holds a simple pseudo-random byte generator state (no random module needed).
seed = 12345

# RAND: return the next pseudo-random byte.
def rand():
    global seed
    seed = (seed * 1103515245 + 12345) & 0xFFFFFFFF
    return (seed >> 16) & 0xFF

# SNAPSHOT: read registers 0..127 slowly, one at a time, as the reference for block reads.
def snapshot():
    fpga.set_pulse_delay(60)
    return bytearray(fpga.read(a) for a in range(128))

# RUN: one full test at the given delay; prints errors and speed.
def run(delay):
    fpga.set_pulse_delay(delay)

    # 1. Single registers: write a random value to SCRATCH, read it back.
    errs = 0
    t0 = utime.ticks_us()
    for _ in range(N_SINGLE):
        v = rand()
        fpga.write(2, v)
        if fpga.read(2) != v:
            errs += 1
    single_us = utime.ticks_diff(utime.ticks_us(), t0) / N_SINGLE

    # 2. Blocks: write 4 random bytes into CTRL, burst-read all 128 registers, compare every byte.
    berr = 0
    # Put SCRATCH back to its reference value first (the single test changed it).
    fpga.write(2, ref[2])
    exp = bytearray(ref)
    buf = bytearray(128)
    for _ in range(N_BLOCK):
        w = bytes([rand(), rand(), rand(), rand()])
        fpga.write_block(0x10, w)
        exp[0x10:0x14] = w
        fpga.read_block(0, buf)
        if buf != exp:
            berr += 1

    # 3. Speed: time 128-byte read and write frames with no checking in the loop.
    t0 = utime.ticks_us()
    for _ in range(N_RATE):
        fpga.read_block(0, buf)
    rd = N_RATE * 128 / utime.ticks_diff(utime.ticks_us(), t0)
    out = bytes(128)
    t0 = utime.ticks_us()
    for _ in range(N_RATE):
        fpga.write_block(0x100, out)
    wr = N_RATE * 128 / utime.ticks_diff(utime.ticks_us(), t0)

    print("delay %2d: single %d err, %.1f us/rw | block %d err | read %.2f MB/s, write %.2f MB/s"
          % (delay, errs, single_us, berr, rd, wr))

print("link ok:", fpga.link_ok())
# Set CTRL to known values, then take the reference.
fpga.write_block(0x10, bytes([1, 2, 3, 4]))
ref = snapshot()
for d in DELAYS:
    try:
        run(d)
    except Exception as e:
        print("delay %2d: exception %r" % (d, e))
# Back to the default (8).
fpga.set_pulse_delay(8)
print("done, delay back to 8")
