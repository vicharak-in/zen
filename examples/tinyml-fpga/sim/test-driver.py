"""test-driver.py - tests firmware/RP2350/tinyml_zink.py (the RP2350 runtime) on the PC against a fake `fpga` module.
    python3 sim/test-driver.py
Checks, for 25 random networks and for the demo model: the .tml file is parsed and loaded, the read-back check passes, infer() matches the golden model,
quantize() / predict() work with the scale from the file, and the stored self-test pairs pass.
"""

import os
import random
import struct
import sys
import tempfile
import time
import types

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, "..", "tools"))
sys.path.insert(0, os.path.join(HERE, "..", "firmware", "RP2350"))

import fake_fpga                      # noqa: E402
import gen_vectors                    # noqa: E402
import tinyml_model as m              # noqa: E402

# Register a fake `fpga` module and MicroPython's time.ticks_* before the driver is imported
fake = fake_fpga.FakeFPGA()
mod = types.ModuleType("fpga")
for name in ("init", "link_ok", "read", "write", "read_block", "write_block"):
    setattr(mod, name, getattr(fake, name))
sys.modules["fpga"] = mod
time.ticks_ms = lambda: int(time.time() * 1000)
time.ticks_diff = lambda a, b: a - b

import tinyml_zink as drv             # noqa: E402


def check(cond, msg):
    if not cond:
        print("FAIL:", msg)
        sys.exit(1)


def main():
    tmp = tempfile.mkdtemp()
    for seed in range(1, 26):
        layers, x = gen_vectors.random_net(random.Random(seed))
        path = os.path.join(tmp, "m%d.tml" % seed)
        scale = 0.0625
        tests = [x] + [[random.Random(seed * 100 + k).randint(-128, 127) for _ in range(len(x))] for k in range(3)]
        m.export_blob(path, layers, scale, tests)
        check(drv.start() == 0xC1, "config byte")
        drv.load(path)                                                        # parses the file, loads, reads back
        for t in tests:
            check(drv.infer(t) == m.forward(layers, t), "infer mismatch, seed %d" % seed)
        check(drv.selftest(), "selftest, seed %d" % seed)
        fl = [v * scale * 0.9 for v in x]                                     # float features that quantise back to about 0.9 * x
        best, scores = drv.predict(fl)
        q = [max(-128, min(127, int(round(v / struct.unpack("<f", struct.pack("<f", scale))[0])))) for v in fl]
        check(scores == m.forward(layers, q), "predict scores, seed %d" % seed)
        check(scores[best] == max(scores) and best == scores.index(max(scores)), "argmax, seed %d" % seed)
        check(drv.cycles() == m.expected_cycles(layers), "cycles, seed %d" % seed)
    demo = os.path.join(HERE, "..", "firmware", "RP2350", "model-demo.tml")
    if os.path.exists(demo):
        check(drv.demo(demo), "demo model")
    print("RESULT: driver tests passed")


if __name__ == "__main__":
    main()
