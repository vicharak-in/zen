# gen_pieces.py - writes the pmask() case lines of tetris_core.v from the Python model, so the hardware shapes cannot differ from it
# Usage: python3 gen_pieces.py <template> <output>   (replaces the line //PMASK_CASES)
import os
import sys

# The Python model lives in model/ (and the frame drawing in mcu/)
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "model"))
from tetris_game import ROT  # noqa: E402


# Build the case lines: key {kind, rot}, value = 16-bit mask with bit (dy * 4 + dx) set for every cell
def cases():
    # Output lines
    out = []
    # Every piece kind and rotation
    for k in range(7):
        for r in range(4):
            # Mask of this orientation
            m = 0
            for dx, dy in ROT[k][r]:
                m |= 1 << (dy * 4 + dx)
            # One case line
            out.append("                5'd%d: pmask = 16'h%04X;   // kind %d, rotation %d" % (k * 4 + r, m, k, r))
    # All lines as one text
    return "\n".join(out)


# Fill the template
if __name__ == "__main__":
    # Template text
    t = open(sys.argv[1]).read()
    # Replace the marker line
    assert t.count("//PMASK_CASES") == 1
    open(sys.argv[2], "w").write(t.replace("//PMASK_CASES", cases()))
