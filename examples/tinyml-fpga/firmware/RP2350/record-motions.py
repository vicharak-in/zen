# record-motions.py - runs on the board: records labeled motion windows from the BMI323 into sensor-data.csv
# Safe to run again: motions that are already saved are skipped, so after a failure it continues with the one that failed.
# To redo a motion that was saved but was bad, put its name in REDO below (or run  sensor_tml.forget("shake")  first).
import time

import sensor_tml as s

# Motions to record again even if they are already saved, e.g. REDO = ["shake"]
REDO = []
# Windows per motion
N = 30

# Open the sensor: SCL = GPIO 21, SDA = GPIO 20
s.setup(21, 20)

# Motions to record: (name, instruction for you)
MOTIONS = [
    ("still", "lay the board flat and do not touch it"),
    ("shake", "shake it hard"),
    ("tilt", "slowly tilt it left and right"),
    ("circle", "move it in big circles"),
]

# This loop records every motion that is not saved yet, with a short pause before each
for name, hint in MOTIONS:
    if name not in REDO and s.count(name) >= N:
        print("skipping '%s': already has %d windows" % (name, s.count(name)))
        continue
    print("\n==== NEXT: %s - %s ====" % (name, hint))
    time.sleep(4)                       # a few seconds to get ready
    s.record(name, N)                   # saved only if all N windows succeed
print("\nall done")
