"""train_digits.py - real-data test for tinyml-fpga: handwritten digits (8x8 pixel images, 10 classes) from scikit-learn, no download needed.
Network 64 -> 32 -> 10 (2368 weights, 42 neurons, fits the default build). Runs on the PC:
    python3 firmware/pc-tools/train_digits.py          (needs numpy and scikit-learn)
Writes firmware/RP2350/model-digits.tml (the model, with 8 self-test pairs) and firmware/RP2350/digits-test.bin (all unseen test images, int8, with labels).
On the board:  mpremote cp firmware/RP2350/tinyml_zink.py firmware/RP2350/model-digits.tml firmware/RP2350/digits-test.bin firmware/RP2350/digits-board.py :
               mpremote exec "import digits_board; digits_board.run()"
"""

import os
import struct

import numpy as np

import tinyml_model as m

HERE = os.path.dirname(os.path.abspath(__file__))
# Folder with the files that go to the RP2350 (models, labels, test images)
FW = os.path.join(HERE, "..", "RP2350")


def train(X, y, rng, hidden=32, epochs=1500, lr=0.5):
    """Full-batch gradient descent on softmax cross-entropy; returns (W1, b1, W2, b2) with W shaped (out, in)."""
    n_out = int(y.max()) + 1
    W1 = rng.normal(0, 0.2, (hidden, X.shape[1])); b1 = np.zeros(hidden)
    W2 = rng.normal(0, 0.2, (n_out, hidden));      b2 = np.zeros(n_out)
    Y = np.eye(n_out)[y]
    for _ in range(epochs):
        H = np.maximum(X @ W1.T + b1, 0.0)                    # forward: hidden layer with ReLU
        Z = H @ W2.T + b2                                     # forward: scores
        P = np.exp(Z - Z.max(1, keepdims=True)); P /= P.sum(1, keepdims=True)
        dZ = (P - Y) / len(X)                                 # backward
        dW2 = dZ.T @ H; db2 = dZ.sum(0)
        dH = (dZ @ W2) * (H > 0)
        dW1 = dH.T @ X; db1 = dH.sum(0)
        W1 -= lr * dW1; b1 -= lr * db1; W2 -= lr * dW2; b2 -= lr * db2
    return W1, b1, W2, b2


def main():
    from sklearn.datasets import load_digits                 # imported here so train-sensor.py can reuse train() without scikit-learn
    d = load_digits()
    X = d.data / 16.0                                        # pixels 0..16 -> 0..1
    y = d.target
    rng = np.random.default_rng(7)
    idx = rng.permutation(len(y))
    X, y = X[idx], y[idx]
    ntr = 1437
    Xtr, ytr, Xte, yte = X[:ntr], y[:ntr], X[ntr:], y[ntr:]
    W1, b1, W2, b2 = train(Xtr, ytr, rng)

    fp = np.argmax(np.maximum(Xte @ W1.T + b1, 0.0) @ W2.T + b2, axis=1)
    layers, s_in = m.quantize_mlp([W1, W2], [b1, b2], Xtr)
    xq = [m.quantize_input(v, s_in) for v in Xte]
    iq = np.array([int(np.argmax(m.forward(layers, v))) for v in xq])   # bit-exact with the FPGA
    print("test images       :", len(yte))
    print("float accuracy    : %.3f" % np.mean(fp == yte))
    print("int8 accuracy     : %.3f   (this is what the FPGA must reproduce)" % np.mean(iq == yte))
    print("shifts: %s  MACs: %d  clocks/inference: %d (%.1f us at 50 MHz)" % ([L.shift for L in layers], m.macs(layers), m.expected_cycles(layers), m.expected_cycles(layers) / 50.0))

    m.export_blob(os.path.join(FW, "model-digits.tml"), layers, s_in, tests=xq[:8])
    with open(os.path.join(FW, "digits-test.bin"), "wb") as f:           # count (u16), then per image: 64 int8 pixels + 1 label byte
        f.write(struct.pack("<H", len(yte)))
        for v, lab in zip(xq, yte):
            f.write(bytes(p & 255 for p in v) + bytes([int(lab)]))
    print("wrote firmware/RP2350/model-digits.tml and firmware/RP2350/digits-test.bin (%d bytes)" % os.path.getsize(os.path.join(FW, "digits-test.bin")))


if __name__ == "__main__":
    main()
