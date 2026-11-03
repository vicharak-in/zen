"""tinyml_model.py - bit-exact golden model, packer and post-training quantiser for the tinyml-fpga int8 MLP engine.

The hardware (rtl/tml-engine.v) computes, per layer:
    acc[o] = bias[o] + sum_i( weight[o][i] * x[i] )                 x, weight: int8     bias, acc: int32
    y[o]   = saturate_int8( relu?( (acc[o] + (1 << (shift-1))) >> shift ) )      (no rounding add when shift == 0)
forward() below does exactly that with Python integers, so RTL simulation and the board must match it byte for byte.
"""

import struct


class Layer:
    """One dense layer: w is out_dim rows of in_dim int8 values, b is out_dim int32 biases."""

    def __init__(self, w, b, shift, relu):
        self.w = [list(r) for r in w]          # weights, out-major: w[o][i]
        self.b = list(b)                       # biases
        self.shift = int(shift)                # requantisation right shift (0..31)
        self.relu = bool(relu)                 # apply ReLU before saturation
        self.out_dim = len(self.w)             # number of output neurons
        self.in_dim = len(self.w[0])           # number of inputs
        assert len(self.b) == self.out_dim
        assert all(len(r) == self.in_dim for r in self.w)
        assert 1 <= self.in_dim <= 255 and 1 <= self.out_dim <= 255
        assert 0 <= self.shift <= 31
        assert all(-128 <= v <= 127 for r in self.w for v in r)
        assert all(-(2 ** 31) <= v < 2 ** 31 for v in self.b)


def requant(acc, shift, relu):
    """Rounding right shift, optional ReLU, saturate to int8 - the same steps as the S_REQ state."""
    half = (1 << (shift - 1)) if shift else 0           # round half up
    r = (acc + half) >> shift                           # Python >> on negative ints is arithmetic, like >>> in Verilog
    if relu and r < 0:
        r = 0                                           # ReLU
    return max(-128, min(127, r))                       # saturate


def forward_layer(layer, x):
    """Run one layer on an int8 vector, return the int8 output vector."""
    assert len(x) == layer.in_dim
    out = []
    for o in range(layer.out_dim):
        acc = layer.b[o] + sum(w * v for w, v in zip(layer.w[o], x))   # int32 accumulate (never overflows for in_dim <= 255)
        out.append(requant(acc, layer.shift, layer.relu))
    return out


def forward(layers, x):
    """Run all layers; returns the final int8 vector."""
    for layer in layers:
        x = forward_layer(layer, x)
    return x


def pack(layers):
    """Pack a network into the three byte blobs the engine loads: (layer table, biases, weights)."""
    assert 1 <= len(layers) <= 16
    for a, b in zip(layers, layers[1:]):
        assert a.out_dim == b.in_dim, "layer sizes do not chain"
    tbl = bytearray()
    bias = bytearray()
    wts = bytearray()
    for L in layers:
        tbl += bytes([L.in_dim, L.out_dim, L.shift, 1 if L.relu else 0])      # in_dim, out_dim, shift, flags
        for v in L.b:
            bias += struct.pack("<i", v)                                      # int32 little endian
        for row in L.w:
            wts += bytes(v & 0xFF for v in row)                               # int8 two's complement, out-major
    return bytes(tbl), bytes(bias), bytes(wts)


def expected_cycles(layers):
    """Clocks the engine needs for one run (one MAC per clock): table 5 + neurons * (in + 9) + 1 per layer, plus 4 to drain the requantisation pipeline."""
    return sum(5 + L.out_dim * (L.in_dim + 9) + 1 for L in layers) + 4


def macs(layers):
    """Multiply-accumulates in one inference."""
    return sum(L.in_dim * L.out_dim for L in layers)


def quantize_mlp(Ws, bs, calib_x):
    """Post-training quantisation of a float MLP (needs numpy).
    Ws[l]: (out, in) float array, bs[l]: (out,) float array, calib_x: (N, in) float samples used to pick scales.
    ReLU after every layer except the last. Returns (layers, input_scale): quantise inputs with
    xq = clip(round(x / input_scale), -128, 127). Scales are chosen so that the requantisation is a pure right shift."""
    import numpy as np
    s_in = float(np.max(np.abs(calib_x))) / 127.0 or 1.0          # input scale
    input_scale = s_in
    h = np.asarray(calib_x, dtype=np.float64)                     # float activations flowing through the network
    layers = []
    for l, (W, b) in enumerate(zip(Ws, bs)):
        W = np.asarray(W, dtype=np.float64)
        b = np.asarray(b, dtype=np.float64)
        last = (l == len(Ws) - 1)
        s_w = float(np.max(np.abs(W))) / 127.0 or 1.0             # weight scale
        Wq = np.clip(np.round(W / s_w), -128, 127).astype(int)    # int8 weights
        bq = np.round(b / (s_in * s_w)).astype(np.int64)          # bias lives in the accumulator scale s_in * s_w
        h = h @ W.T + b                                           # float reference output of this layer
        if not last:
            h = np.maximum(h, 0.0)                                # ReLU
        peak = float(np.max(np.abs(h))) or 1.0                    # largest magnitude seen
        need = peak / 127.0 / (s_in * s_w)                        # accumulator units per output step
        shift = 0
        while (1 << shift) < need and shift < 30:                 # smallest shift so the peak still fits in int8
            shift += 1
        layers.append(Layer(Wq.tolist(), [int(v) for v in bq], shift, not last))
        s_in = s_in * s_w * (1 << shift)                          # scale of this layer's int8 output
    return layers, input_scale


def quantize_input(x, input_scale):
    """Float vector -> int8 list for the first layer."""
    return [max(-128, min(127, int(round(v / input_scale)))) for v in x]


BLOB_HEADER = "<4sBBBBfHHH"   # magic, nlayers, in_len, out_len, ntests, input_scale (float32), table bytes, bias bytes, weight bytes (18 bytes)


def export_blob(path, layers, input_scale, tests=None):
    """Write the compact model file the RP2350 loads (.tml): header, layer table, biases, weights, then optional self-test pairs.
    input_scale: the float the board divides live sensor values by to make int8 inputs.
    tests: optional list of int8 input vectors; each is stored with its golden output so the board can self-check against the FPGA."""
    import struct as _s
    tbl, bias, wts = pack(layers)
    tests = tests or []
    head = _s.pack(BLOB_HEADER, b"TML1", len(layers), layers[0].in_dim, layers[-1].out_dim, len(tests), input_scale, len(tbl), len(bias), len(wts))
    body = b"".join(bytes(v & 255 for v in x) + bytes(v & 255 for v in forward(layers, x)) for x in tests)
    with open(path, "wb") as f:
        f.write(head + tbl + bias + wts + body)


def write_hex(outdir, layers, x):
    """Write the .hex files that sim/tb-tinyml.v reads (cfg, tbl, bias, w, in, exp); returns the golden output."""
    import os
    y = forward(layers, x)
    tbl, bias, wts = pack(layers)
    cyc = expected_cycles(layers)
    cfg = bytes([len(layers), len(x), len(y), len(wts) & 255, len(wts) >> 8, len(bias) & 255, len(bias) >> 8, len(tbl)]) + cyc.to_bytes(4, "little")
    os.makedirs(outdir, exist_ok=True)
    for name, blob in (("cfg", cfg), ("tbl", tbl), ("bias", bias), ("w", wts),
                       ("in", bytes(v & 255 for v in x)), ("exp", bytes(v & 255 for v in y))):
        with open(os.path.join(outdir, name + ".hex"), "w") as f:
            f.write("".join("%02x\n" % v for v in blob))
    return y
