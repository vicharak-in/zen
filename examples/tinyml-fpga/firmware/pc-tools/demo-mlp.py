"""demo-mlp.py - the whole TinyML-for-FPGA flow on a toy problem, end to end:
    1. make a small dataset (3 classes of 8 sensor features)         3. quantise to int8 + power-of-two requantisation shifts
    2. train a float MLP 8 -> 16 -> 3 with plain numpy               4. check the int8 model against the float one
    5. export for the board (firmware/RP2350/model-demo.tml, one compact file) and for the Verilog testbench (sim/build/demo/*.hex)

This file runs on the PC (it is the only part that trains). Everything after it runs on the RP2350.
    python3 firmware/pc-tools/demo-mlp.py
    then: cd sim/build/demo && vvp ../tb.vvp        (run ./sim/run-sim.sh once first so tb.vvp exists)
    and on the board: mpremote cp firmware/RP2350/tinyml_zink.py firmware/RP2350/model-demo.tml :   then   import tinyml_zink; tinyml_zink.demo()
"""

import os

import numpy as np

import tinyml_model as m

HERE = os.path.dirname(os.path.abspath(__file__))
# Folder with the files that go to the RP2350 (models, labels, test images)
FW = os.path.join(HERE, "..", "RP2350")


def make_data(rng, n_per_class=200):
    """3 Gaussian blobs in 8 dimensions: a stand-in for features from a sensor (vibration bands, ECG beat features, ...)."""
    centers = rng.normal(0.0, 2.0, (3, 8))
    X = np.concatenate([centers[c] + rng.normal(0.0, 1.0, (n_per_class, 8)) for c in range(3)])
    y = np.repeat(np.arange(3), n_per_class)
    idx = rng.permutation(len(y))
    return X[idx], y[idx]


def train(X, y, rng, hidden=16, epochs=600, lr=0.2):
    """Full-batch gradient descent on softmax cross-entropy; returns (W1, b1, W2, b2) with W shaped (out, in)."""
    W1 = rng.normal(0, 0.5, (hidden, X.shape[1])); b1 = np.zeros(hidden)
    W2 = rng.normal(0, 0.5, (3, hidden));          b2 = np.zeros(3)
    Y = np.eye(3)[y]
    for _ in range(epochs):
        H = np.maximum(X @ W1.T + b1, 0.0)                    # forward: hidden layer
        Z = H @ W2.T + b2                                     # forward: logits
        P = np.exp(Z - Z.max(1, keepdims=True)); P /= P.sum(1, keepdims=True)
        dZ = (P - Y) / len(X)                                 # backward
        dW2 = dZ.T @ H; db2 = dZ.sum(0)
        dH = (dZ @ W2) * (H > 0)
        dW1 = dH.T @ X; db1 = dH.sum(0)
        W1 -= lr * dW1; b1 -= lr * db1; W2 -= lr * dW2; b2 -= lr * db2
    return W1, b1, W2, b2


def main():
    rng = np.random.default_rng(1)
    X, y = make_data(rng)
    Xtr, ytr, Xte, yte = X[:400], y[:400], X[400:], y[400:]
    W1, b1, W2, b2 = train(Xtr, ytr, rng)

    def float_pred(A):
        return np.argmax(np.maximum(A @ W1.T + b1, 0.0) @ W2.T + b2, axis=1)

    layers, s_in = m.quantize_mlp([W1, W2], [b1, b2], Xtr)           # step 3
    xq = [m.quantize_input(v, s_in) for v in Xte]                     # int8 test inputs
    iq = np.array([int(np.argmax(m.forward(layers, v))) for v in xq])  # int8 predictions, bit-exact with the FPGA
    fp = float_pred(Xte)
    print("float accuracy : %.3f" % np.mean(fp == yte))
    print("int8  accuracy : %.3f" % np.mean(iq == yte))
    print("int8 agrees with float on %.1f%% of test samples" % (100 * np.mean(iq == fp)))
    print("shifts per layer:", [L.shift for L in layers], " MACs per inference:", m.macs(layers),
          " clocks per inference:", m.expected_cycles(layers), "(%.1f us at 50 MHz)" % (m.expected_cycles(layers) / 50.0))

    m.export_blob(os.path.join(FW, "model-demo.tml"), layers, s_in, tests=xq[:8])               # step 5, board: one compact file
    m.write_hex(os.path.join(HERE, "..", "..", "sim", "build", "demo"), layers, xq[0])                 # step 5, testbench
    print("wrote firmware/RP2350/model-demo.tml and sim/build/demo/*.hex")


if __name__ == "__main__":
    main()
