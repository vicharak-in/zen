# tinyml_zink.py - MicroPython runtime for tinyml-fpga (runs on the RP2350 of the Zen board). Everything at run time happens here:
# read the compact model file (.tml, made on the PC by demo-mlp.py) from flash, load it into the FPGA, quantise live sensor values,
# start the network, read the result and pick the answer. The FPGA does the maths; the PC only trained and compacted the model.
#
#   mpremote cp firmware/RP2350/tinyml_zink.py firmware/RP2350/model-demo.tml :      copy to the board (after loading the tinyml-fpga bitstream)
#   mpremote exec "import tinyml_zink; tinyml_zink.demo()"
#
# In your own program:
#   import tinyml_zink as tml
#   tml.start()                         # check the link
#   tml.load("model-demo.tml")          # flash -> FPGA RAMs
#   best, scores = tml.predict(features)    # float features in, class index and int8 scores out
#
# Register map (see rtl/tml-zink.v):
#   0x0100 CMD (W: 1 = run)   0x0101 STATUS (R: bit0 busy, bit1 done, bit2 error)   0x0102 NLAYERS   0x0103 CONFIG   0x0104..0x0107 CYCLES (R)
#   0x0200 LAYER TABLE   0x0600 INPUT   0x0700 OUTPUT (R)   0x2000 WEIGHTS   0x4000 BIASES
# Every window is plain memory: one write_block / read_block of consecutive addresses moves a whole tensor.
#
# .tml file: 18 byte header "<4sBBBBfHHH" = b"TML1", nlayers, in_len, out_len, ntests, input_scale (float32), table/bias/weight byte counts,
# then the table, biases, weights, and ntests pairs of (int8 input, int8 expected output).

import fpga
import struct
import time

# Register and window addresses
CMD, STATUS, NLAYERS, CONFIG, CYCLES = 0x0100, 0x0101, 0x0102, 0x0103, 0x0104
TABLE, INPUT, OUTPUT, WEIGHTS, BIASES = 0x0200, 0x0600, 0x0700, 0x2000, 0x4000
# Status bits
BUSY, DONE, ERR = 1, 2, 4
# Bytes per link frame (the link allows up to 128)
CHUNK = 32
# Polls before giving up on a run
MAX_POLLS = 2000

# State of the loaded model, set by load()
_in_len = 0
_out_len = 0
_inv_scale = 1.0
_tests = []


def _write(addr, data):
    """Write a bytes object to consecutive addresses, one frame per CHUNK bytes."""
    for i in range(0, len(data), CHUNK):
        fpga.write_block(addr + i, data[i:i + CHUNK])


def _read(addr, n):
    """Read n bytes from consecutive addresses."""
    out = bytearray()
    for i in range(0, n, CHUNK):
        buf = bytearray(min(CHUNK, n - i))
        fpga.read_block(addr + i, buf)
        out += buf
    return bytes(out)


def _signed(data):
    """Bytes (two's complement) to a list of signed ints."""
    return [v - 256 if v > 127 else v for v in data]


def start():
    """Check the link and that the TinyML engine is the design that is loaded; returns the CONFIG byte (0xC1 for the default build)."""
    fpga.init()
    if not fpga.link_ok():
        raise RuntimeError("Zen Link not up: is the tinyml-fpga bitstream loaded?")
    return fpga.read(CONFIG)


def load(path, verify=True):
    """Read a .tml model file from the board's flash and load it into the FPGA RAMs; optionally read everything back to check the link."""
    global _in_len, _out_len, _inv_scale, _tests
    with open(path, "rb") as f:
        magic, nl, il, ol, nt, scale, tl, bl, wl = struct.unpack("<4sBBBBfHHH", f.read(18))
        if magic != b"TML1":
            raise ValueError("%s is not a .tml model file" % path)
        tbl = f.read(tl)
        bias = f.read(bl)
        wts = f.read(wl)
        tests = [(f.read(il), f.read(ol)) for _ in range(nt)]
    _write(TABLE, tbl)
    _write(BIASES, bias)
    _write(WEIGHTS, wts)
    fpga.write(NLAYERS, nl)
    if verify and (_read(TABLE, tl) != tbl or _read(BIASES, bl) != bias or _read(WEIGHTS, wl) != wts):
        raise RuntimeError("model read-back mismatch: check the link")
    _in_len, _out_len, _inv_scale, _tests = il, ol, 1.0 / scale, tests


def infer(x):
    """Run one inference on a list of int8 values (-128..127); returns the output as a list of int8 values."""
    if len(x) != _in_len:
        raise ValueError("expected %d inputs, got %d" % (_in_len, len(x)))
    _write(INPUT, bytes(v & 0xFF for v in x))
    fpga.write(CMD, 1)                                    # RUN
    for _ in range(MAX_POLLS):
        s = fpga.read(STATUS)
        if s & ERR:
            raise RuntimeError("TinyML engine error, status 0x%02X" % s)
        if s & DONE:
            break
    else:
        raise RuntimeError("TinyML engine timeout")
    return _signed(_read(OUTPUT, _out_len))


def quantize(x):
    """Live float sensor values -> int8 inputs, using the scale stored in the model file."""
    return [max(-128, min(127, int(round(v * _inv_scale)))) for v in x]


def predict(x):
    """Float features in; returns (index of the largest output, the int8 scores)."""
    scores = infer(quantize(x))
    best = 0
    for i in range(1, len(scores)):
        if scores[i] > scores[best]:
            best = i
    return best, scores


def cycles():
    """FPGA clocks used by the last run (50 MHz clock: divide by 50 for microseconds)."""
    c = _read(CYCLES, 4)
    return c[0] | (c[1] << 8) | (c[2] << 16) | (c[3] << 24)


def selftest():
    """Run the test pairs stored in the model file and compare the FPGA output with the golden outputs made on the PC."""
    ok = len(_tests) > 0
    for x, y in _tests:
        ok = ok and (infer(_signed(x)) == _signed(y))
    print("TinyML self-test:", "PASS" if ok else "FAIL", "(%d vectors, %d clocks per run)" % (len(_tests), cycles()))
    return ok


def bench(n=50):
    """Time n inferences end to end (link transfers included) and report the FPGA-only time from the cycle counter."""
    t0 = time.ticks_ms()
    for i in range(n):
        infer(_signed(_tests[i % len(_tests)][0]))
    dt = time.ticks_diff(time.ticks_ms(), t0)
    print("%d inferences in %d ms = %.1f ms each end to end; FPGA compute only: %.1f us" % (n, dt, dt / n, cycles() / 50.0))


def demo(path="model-demo.tml"):
    """Check the link, load the demo model from flash, self-test it and print a short benchmark."""
    print("engine config 0x%02X" % start())
    load(path)
    ok = selftest()
    bench()
    return ok
