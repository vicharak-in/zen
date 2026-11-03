"""gen_vectors.py - make one random (or edge-case) network plus input and the golden output, as .hex files for the Verilog testbench.

    python3 gen_vectors.py --seed 7 --out build/case_7          random network
    python3 gen_vectors.py --edge 1 --out build/edge1           all weights and inputs -128: positive saturation
    python3 gen_vectors.py --edge 2 --out build/edge2           weights +127, inputs -128: negative saturation, with and without ReLU

Files written (one byte per line, hex, for $readmemh): cfg.hex tbl.hex bias.hex w.hex in.hex exp.hex
cfg.hex = nlayers, in_len, out_len, wlen_lo, wlen_hi, blen_lo, blen_hi, tlen, cycles (4 bytes, little endian)
"""

import argparse
import random

import tinyml_model as m

W_MAX = 4096     # weight RAM bytes of the default build
B_MAX = 1024     # bias RAM bytes of the default build


def random_net(rng):
    """Random layer sizes, weight amplitudes, shifts and ReLU flags that fit the default RAM sizes."""
    while True:
        nl = rng.randint(1, 5)
        big = rng.random() < 0.3
        dims = [rng.randint(1, 48 if big else 20) for _ in range(nl + 1)]
        nw = sum(dims[i] * dims[i + 1] for i in range(nl))
        nb = sum(dims[1:]) * 4
        if nw <= W_MAX and nb <= B_MAX:
            break
    layers = []
    for l in range(nl):
        amp = rng.choice([4, 32, 128])                                           # weight amplitude: small, medium, full range
        w = [[rng.randint(-amp, amp - 1) for _ in range(dims[l])] for _ in range(dims[l + 1])]
        b = [rng.choice([0, rng.randint(-2000, 2000), rng.randint(-(2 ** 20), 2 ** 20)]) for _ in range(dims[l + 1])]
        layers.append(m.Layer(w, b, rng.randint(0, 14), rng.random() < 0.7))
    x = [rng.randint(-128, 127) for _ in range(dims[0])]
    return layers, x


def edge_net(kind):
    """Extreme-value networks for the saturation paths."""
    if kind == 1:
        layers = [m.Layer([[-128] * 5 for _ in range(4)], [0, 5, -5, 100000], 0, False)]   # (-128)*(-128)*5 = 81920 -> saturates to +127
        x = [-128] * 5
    else:
        layers = [m.Layer([[127] * 9 for _ in range(3)], [0, 7, -300], 2, False),            # large negative -> -128
                  m.Layer([[127, -128, 5], [1, 1, 1]], [-(2 ** 30), 0], 0, True)]             # huge negative bias with ReLU -> 0, other row saturates
        x = [-128] * 9
    return layers, x


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--seed", type=int, default=1)
    ap.add_argument("--edge", type=int, default=0)
    ap.add_argument("--out", default=".")
    a = ap.parse_args()
    layers, x = edge_net(a.edge) if a.edge else random_net(random.Random(a.seed))
    y = m.write_hex(a.out, layers, x)
    print("layers=%d in=%d out=%d weights=%d bytes cycles=%d" % (len(layers), len(x), len(y), len(m.pack(layers)[2]), m.expected_cycles(layers)))


if __name__ == "__main__":
    main()
