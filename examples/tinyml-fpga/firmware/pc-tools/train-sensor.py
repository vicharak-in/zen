"""train-sensor.py - PC side of the sensor test: train a motion classifier from the windows recorded on the board.
    mpremote cp :sensor-data.csv firmware/pc-tools/sensor-data.csv        (copy the recording off the board)
    python3 firmware/pc-tools/train-sensor.py
Writes firmware/RP2350/model-sensor.tml and firmware/RP2350/labels.txt. Network: 24 features -> 32 -> number of motions.
"""

import os

import numpy as np

import tinyml_model as m
from train_digits import train

HERE = os.path.dirname(os.path.abspath(__file__))
# Folder with the files that go to the RP2350 (models, labels, test images)
FW = os.path.join(HERE, "..", "RP2350")


def main(csv=os.path.join(HERE, "sensor-data.csv")):
    names, rows, labs = [], [], []
    bad = 0
    for line in open(csv):
        p = line.strip().split(",")
        if len(p) != 25:
            continue
        if float(p[1]) == -4.0 and float(p[2]) == 0.0:      # all-invalid window (raw 0x8000 on the accelerometer): ignore
            bad += 1
            continue
        if p[0] not in names:
            names.append(p[0])
        labs.append(names.index(p[0]))
        rows.append([float(v) for v in p[1:]])
    if bad:
        print("ignored %d invalid windows (sensor returned no data)" % bad)
    X, y = np.array(rows), np.array(labs)
    mu, sd = 0.0, 1.0
    rng = np.random.default_rng(3)
    idx = rng.permutation(len(y))
    X, y = X[idx], y[idx]
    ntr = int(0.75 * len(y))
    Xtr, ytr, Xte, yte = X[:ntr], y[:ntr], X[ntr:], y[ntr:]
    print("motions:", names, " windows:", len(y), " train/test: %d/%d" % (len(ytr), len(yte)))
    W1, b1, W2, b2 = train(Xtr, ytr, rng, hidden=32, epochs=3000, lr=0.2)
    fp = np.argmax(np.maximum(Xte @ W1.T + b1, 0.0) @ W2.T + b2, axis=1)
    layers, s_in = m.quantize_mlp([W1, W2], [b1, b2], Xtr)
    iq = np.array([int(np.argmax(m.forward(layers, m.quantize_input(v, s_in)))) for v in Xte])
    print("float accuracy on unseen windows: %.3f" % np.mean(fp == yte))
    print("int8  accuracy on unseen windows: %.3f" % np.mean(iq == yte))
    tests = [m.quantize_input(v, s_in) for v in Xte[:8]]
    m.export_blob(os.path.join(FW, "model-sensor.tml"), layers, s_in, tests=tests)
    open(os.path.join(FW, "labels.txt"), "w").write("\n".join(names) + "\n")
    print("wrote firmware/RP2350/model-sensor.tml and firmware/RP2350/labels.txt")


if __name__ == "__main__":
    main()
