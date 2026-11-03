# alu_demo.py - drive the zink_alu example from MicroPython on the Zen board.
# Load the FPGA first (python -m mpremote exec "import main"), then:
#   python -m mpremote run examples/zink_alu/mcu/alu_demo.py
import fpga

# Register addresses used by zink_alu_top.
A, B, OP = 0x10, 0x11, 0x12
RESULT, FLAGS = 0x20, 0x21
NAMES = ("ADD", "SUB", "AND", "OR", "XOR", "NOT", "SHL1", "SHR1")


def alu(a, b, op):
    """Send the operands and opcode, return (result, zero, carry, negative, overflow)."""
    fpga.write(A, a)
    fpga.write(B, b)
    fpga.write(OP, op)
    f = fpga.read(FLAGS)
    return fpga.read(RESULT), f & 1, (f >> 1) & 1, (f >> 2) & 1, (f >> 3) & 1


fpga.init()
assert fpga.link_ok(), "link not up: is the FPGA loaded?"
for op in range(8):
    r, z, c, n, v = alu(0xF0, 0x15, op)
    print("%-4s 0xF0, 0x15 -> 0x%02X  zero=%d carry=%d neg=%d ovf=%d" % (NAMES[op], r, z, c, n, v))
