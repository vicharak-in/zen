"""
cocotb test for the zink_pwm example.

The MCU is modelled by LinkMaster (from the base zink testbench). After each write the test
counts, over exactly one 256-clock PWM period, how many clocks each LED pin is on (pin low).
That count must equal the duty value.
"""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge
from test_zen_link import LinkMaster, CLK_NS

# Register addresses (see docs/PROTOCOL.md).
DUTY1_REG, DUTY2_REG = 0x10, 0x11


async def setup(dut):
    """Start the clock, idle the link, let the design settle."""
    cocotb.start_soon(Clock(dut.clk, CLK_NS, unit="ns").start())
    dut.m_clk.value = 0
    dut.m_csn.value = 1
    dut.m_d.value = 0
    dut.m_oe.value = 0
    await ClockCycles(dut.clk, 10)
    return LinkMaster(dut)


async def on_clocks(dut):
    """Count clocks in one 256-clock period where led1 / led2 are on (pin low)."""
    on1 = on2 = 0
    for _ in range(256):
        await RisingEdge(dut.clk)
        on1 += int(dut.led1.value == 0)
        on2 += int(dut.led2.value == 0)
    return on1, on2


@cocotb.test()
async def test_duty_counts(dut):
    """Every duty value gives exactly that many on-clocks per period, on both channels."""
    m = await setup(dut)
    for duty in (0, 1, 64, 128, 200, 255):
        await m.write(DUTY1_REG, [duty])
        await m.write(DUTY2_REG, [duty])
        await ClockCycles(dut.clk, 4)
        assert await on_clocks(dut) == (duty, duty), f"duty {duty}"


@cocotb.test()
async def test_channels_independent(dut):
    """The two LEDs follow their own registers."""
    m = await setup(dut)
    await m.write(DUTY1_REG, [30])
    await m.write(DUTY2_REG, [220])
    await ClockCycles(dut.clk, 4)
    assert await on_clocks(dut) == (30, 220)
    await m.write(DUTY1_REG, [0])
    await ClockCycles(dut.clk, 4)
    assert await on_clocks(dut) == (0, 220)


@cocotb.test()
async def test_burst_and_readback(dut):
    """One frame sets both duties; the registers read back what was written."""
    m = await setup(dut)
    await m.write(DUTY1_REG, [10, 90])
    assert await m.read(DUTY1_REG, 2) == [10, 90]
    await ClockCycles(dut.clk, 4)
    assert await on_clocks(dut) == (10, 90)
