# digits-board.py - MicroPython, runs on the RP2350: classify real handwritten-digit images on the FPGA and score the accuracy.
# The model (model-digits.tml) and the unseen test images (digits-test.bin) were made on the PC by train_digits.py.
#   mpremote exec "import digits_board; digits_board.run()"          score all test images
#   mpremote exec "import digits_board; digits_board.show(5)"        print 5 images as text with the FPGA's answer

import struct
import time

import tinyml_zink as tml

# Characters from dark to bright, used to print an image
SHADES = " .:-=+*#%@"
# Image side length in pixels
SIDE = 8
# Bytes per record in digits-test.bin: 64 pixels and one label
REC = SIDE * SIDE + 1


def _pixels(raw):
    """Bytes (two's complement int8, here always 0..127) to a list of ints."""
    return [b - 256 if b > 127 else b for b in raw]


def _open():
    """Check the link, load the digits model into the FPGA, and open the test file; returns (file, number of images)."""
    print("engine config 0x%02X" % tml.start())
    tml.load("model-digits.tml")
    f = open("digits-test.bin", "rb")
    n = struct.unpack("<H", f.read(2))[0]
    return f, n


def _argmax(v):
    """Index of the largest value."""
    best = 0
    for i in range(1, len(v)):
        if v[i] > v[best]:
            best = i
    return best


def run():
    """Send every test image to the FPGA, count how many it classifies correctly, and report speed."""
    f, n = _open()
    right = 0
    wrong = []
    t0 = time.ticks_ms()
    for k in range(n):
        rec = f.read(REC)
        guess = _argmax(tml.infer(_pixels(rec[:SIDE * SIDE])))
        if guess == rec[SIDE * SIDE]:
            right += 1
        else:
            wrong.append((k, rec[SIDE * SIDE], guess))
    dt = time.ticks_diff(time.ticks_ms(), t0)
    f.close()
    print("FPGA classified %d of %d images correctly = %.1f%%" % (right, n, 100.0 * right / n))
    print("%d ms total = %.2f ms per image end to end; FPGA compute per image: %.1f us (%d clocks)" % (dt, dt / n, tml.cycles() / 50.0, tml.cycles()))
    for k, lab, guess in wrong[:10]:
        print("  image %d: label %d, FPGA said %d" % (k, lab, guess))
    return right, n


def show(count=5):
    """Print the first `count` test images as text, with the true label and the FPGA's answer."""
    f, n = _open()
    for k in range(min(count, n)):
        rec = f.read(REC)
        px = _pixels(rec[:SIDE * SIDE])
        out = tml.infer(px)
        for r in range(SIDE):
            print("".join(SHADES[min(9, px[r * SIDE + c] * 10 // 128)] * 2 for c in range(SIDE)))
        print("label %d, FPGA says %d   scores %s\n" % (rec[SIDE * SIDE], _argmax(out), out))
    f.close()
