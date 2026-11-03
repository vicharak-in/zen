"""
cocotb test for the zink_alu example.

The MCU is modelled by LinkMaster (from the base zink testbench). Every ALU op is checked
against a Python reference: directed corner cases first, then random operands.
"""

import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from test_zen_link import LinkMaster, CLK_NS

# Register addresses (see docs/PROTOCOL.md).
A_REG, B_REG, OP_REG = 0x10, 0x11, 0x12
RESULT_REG, FLAGS_REG = 0x20, 0x21
OPS = ["ADD", "SUB", "AND", "OR", "XOR", "NOT", "SHL1", "SHR1"]


def alu_model(a, b, op):
    """Python reference: returns (result, zero, carry, negative, overflow)."""
    if op == 0:
        r = a + b
        ov = (~(a ^ b) & (a ^ r)) & 0x80
        c = r >> 8
    elif op == 1:
        r = a - b
        ov = ((a ^ b) & (a ^ r)) & 0x80
        c = 1 if a < b else 0
    elif op == 2:
        r, c, ov = a & b, 0, 0
    elif op == 3:
        r, c, ov = a | b, 0, 0
    elif op == 4:
        r, c, ov = a ^ b, 0, 0
    elif op == 5:
        r, c, ov = ~a, 0, 0
    elif op == 6:
        r, c, ov = a << 1, a >> 7, 0
    else:
        r, c, ov = a >> 1, a & 1, 0
    r &= 0xFF
    return r, int(r == 0), c, r >> 7, int(bool(ov))


async def setup(dut):
    """Start the clock, idle the link, let the design settle."""
    cocotb.start_soon(Clock(dut.clk, CLK_NS, unit="ns").start())
    dut.m_clk.value = 0
    dut.m_csn.value = 1
    dut.m_d.value = 0
    dut.m_oe.value = 0
    await ClockCycles(dut.clk, 10)
    return LinkMaster(dut)


async def run_op(m, a, b, op):
    """Write A, B, op over the link, read back result and flags."""
    await m.write(A_REG, [a])
    await m.write(B_REG, [b])
    await m.write(OP_REG, [op])
    res = (await m.read(RESULT_REG, 1))[0]
    fl = (await m.read(FLAGS_REG, 1))[0]
    return res, fl & 1, (fl >> 1) & 1, (fl >> 2) & 1, (fl >> 3) & 1


async def check(m, a, b, op):
    """Run one op and compare with the model."""
    got = await run_op(m, a, b, op)
    exp = alu_model(a, b, op)
    assert got == exp, f"{OPS[op]} a={a:#04x} b={b:#04x}: got {got} expected {exp}"


@cocotb.test()
async def test_directed(dut):
    """Corner cases for every op."""
    m = await setup(dut)
    corners = [(0, 0), (1, 1), (0xFF, 1), (0x7F, 1), (0x80, 1), (0x80, 0x80), (0xFF, 0xFF), (0x55, 0xAA), (3, 5)]
    for op in range(8):
        for a, b in corners:
            await check(m, a, b, op)


@cocotb.test()
async def test_random(dut):
    """Random operands on every op."""
    m = await setup(dut)
    rng = random.Random(42)
    for _ in range(120):
        await check(m, rng.randrange(256), rng.randrange(256), rng.randrange(8))


@cocotb.test()
async def test_leds(dut):
    """led1 = zero flag, led2 = carry flag (active low pins)."""
    m = await setup(dut)
    # 5 - 5 = 0: zero set, carry clear.
    await run_op(m, 5, 5, 1)
    assert dut.led1.value == 0 and dut.led2.value == 1
    # 0xFF + 1 = 0 with carry: both on.
    await run_op(m, 0xFF, 1, 0)
    assert dut.led1.value == 0 and dut.led2.value == 0
    # 1 + 1 = 2: both off.
    await run_op(m, 1, 1, 0)
    assert dut.led1.value == 1 and dut.led2.value == 1


@cocotb.test()
async def test_burst_write(dut):
    """One frame writes A, B and op together (auto-increment 0x10..0x12)."""
    m = await setup(dut)
    await m.write(A_REG, [0x12, 0x34, 0])
    assert (await m.read(RESULT_REG, 2)) == [0x46, 0x00]
