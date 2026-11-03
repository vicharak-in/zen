"""
cocotb test of the REAL RP2350 driver (mcu/bus.c) against the FPGA RTL.

bus.c is compiled for the host with -DBUS_HOST_TEST, so its register reads/writes
and delays go to Python instead of hardware. Python models the RP2350 SIO block
(GPIO_OUT / OE / IN) and wires it to the simulated link pins, advancing simulated
time for every register access (7 ns, ~1 cycle at 150 MHz) and every delay loop
(20 ns: subs + taken bne, ~3 cycles at 150 MHz). The blocking C code runs in a cocotb "bridge"
thread, so what is tested is the exact byte-for-byte driver that goes on the board.
"""

import ctypes
import os
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, ClockCycles

try:                                       # public name in newer cocotb
    from cocotb import bridge, resume
except ImportError:                        # cocotb 2.1 keeps them here
    from cocotb._bridge import bridge, resume

ACCESS_NS = 7.0      # one SIO register access
LOOP_NS = 20.0       # one BUS_WAIT loop iteration (~3 cycles at 150 MHz)
CLK_NS = 20.0        # FPGA clock (50 MHz)

# SIO register addresses (checked against pico-sdk, same as mcu/bus.h)
SIO_GPIO_IN, SIO_GPIO_OUT = 0xD0000004, 0xD0000010
SIO_OUT_SET, SIO_OUT_CLR = 0xD0000018, 0xD0000020
SIO_OE, SIO_OE_SET, SIO_OE_CLR = 0xD0000030, 0xD0000038, 0xD0000040
IO_BANK0_BASE, PADS_BANK0_BASE = 0x40028000, 0x40038000

D_LO_MASK, D_HI_MASK = 0x0F << 24, 0x0F
DATA_MASK = D_LO_MASK | D_HI_MASK
CLK_PIN, CSN_PIN, CDONE_PIN = 28, 29, 4
LINK_PINS = [0, 1, 2, 3, 24, 25, 26, 27, 28, 29]
ID_VALUE = 0x5A
ID_INV = 0xA5

CB_READ = ctypes.CFUNCTYPE(ctypes.c_uint32, ctypes.c_uint32)
CB_WRITE = ctypes.CFUNCTYPE(None, ctypes.c_uint32, ctypes.c_uint32)
CB_DELAY = ctypes.CFUNCTYPE(None, ctypes.c_uint32)


def gather(gpio):
    """GPIO snapshot -> data byte (D0..3 = GPIO24..27, D4..7 = GPIO0..3)."""
    return ((gpio >> 24) & 0xF) | ((gpio & 0xF) << 4)


def spread(byte):
    """Data byte -> GPIO bit pattern."""
    return ((byte & 0xF) << 24) | ((byte >> 4) & 0xF)


@resume
async def co_drive(dut, clk, csn, d, doe, ns):
    """Apply the RP2350 pin levels to the simulated link, then let time pass."""
    dut.m_clk.value = clk
    dut.m_csn.value = csn
    dut.m_d.value = d
    dut.m_oe.value = doe
    await Timer(int(round(ns * 1000)), unit="ps")


@resume
async def co_wait(ns):
    """Let simulated time pass."""
    await Timer(int(round(ns * 1000)), unit="ps")


@resume
async def co_pins(dut):
    """Snapshot of the shared data pins as a string like '0101ZZZZ'."""
    return str(dut.d_bus.value)


class Sio:
    """Model of the RP2350 SIO GPIO block plus the pad/mux config registers."""

    def __init__(self, dut):
        self.dut = dut
        self.out = 0
        self.oe = 0
        self.cdone = 1
        self.funcsel = {}      # pin -> FUNCSEL written
        self.pad = {}          # pin -> pad register written
        self.bad_access = []   # anything the driver should never touch

    def _drive(self, ns):
        """Push the current output state onto the simulated pins and advance time."""
        d_oe_bits = self.oe & DATA_MASK
        assert d_oe_bits in (0, DATA_MASK), f"partial data OE {d_oe_bits:#x}"
        clk = (self.out >> CLK_PIN) & 1 if (self.oe >> CLK_PIN) & 1 else 0
        csn = (self.out >> CSN_PIN) & 1 if (self.oe >> CSN_PIN) & 1 else 1
        co_drive(self.dut, clk, csn, gather(self.out), 1 if d_oe_bits else 0, ns)

    def write(self, addr, val):
        """A register write from bus.c."""
        if addr == SIO_OUT_SET:
            self.out |= val
        elif addr == SIO_OUT_CLR:
            self.out &= ~val
        elif addr == SIO_OE_SET:
            self.oe |= val
        elif addr == SIO_OE_CLR:
            self.oe &= ~val
        elif addr == SIO_GPIO_OUT:
            self.out = val
        elif addr == SIO_OE:
            self.oe = val
        elif IO_BANK0_BASE <= addr < IO_BANK0_BASE + 0x200 and (addr - IO_BANK0_BASE) % 8 == 4:
            self.funcsel[(addr - IO_BANK0_BASE - 4) // 8] = val
        elif PADS_BANK0_BASE + 4 <= addr < PADS_BANK0_BASE + 4 + 4 * 48:
            self.pad[(addr - PADS_BANK0_BASE - 4) // 4] = val
        else:
            self.bad_access.append(("write", hex(addr), hex(val)))
        self._drive(ACCESS_NS)

    def read(self, addr):
        """A register read from bus.c."""
        if addr != SIO_GPIO_IN:
            self.bad_access.append(("read", hex(addr)))
            self._drive(ACCESS_NS)
            return 0
        self._drive(ACCESS_NS)
        pins = co_pins(self.dut)                      # 8 chars, MSB first
        val = 0
        if (self.oe & DATA_MASK):
            val |= self.out & DATA_MASK                # we drive: read back our own level
        else:
            assert "x" not in pins.lower(), f"data pins X while master reads: {pins}"
            byte = int(pins.lower().replace("z", "0"), 2)   # pull-down on a floating bus
            val |= spread(byte)
        val |= ((self.out >> CLK_PIN) & 1) << CLK_PIN
        val |= ((self.out >> CSN_PIN) & 1) << CSN_PIN
        val |= (self.cdone & 1) << CDONE_PIN
        return val

    def delay(self, loops):
        """bus_delay(): hold the levels for 'loops' loop iterations."""
        co_wait(loops * LOOP_NS)


class Driver:
    """ctypes wrapper around the host build of bus.c, with the SIO model attached."""

    def __init__(self, dut):
        self.sio = Sio(dut)
        lib = ctypes.CDLL(os.environ["BUS_HOST_LIB"])
        self.lib = lib
        # keep references so ctypes callbacks are not garbage collected
        self._cbs = (CB_READ(self.sio.read), CB_WRITE(self.sio.write), CB_DELAY(self.sio.delay))
        lib.shim_set_callbacks(*self._cbs)
        # the C library persists across tests but each test has a fresh pin model
        ctypes.c_bool.in_dll(lib, "bus_attached").value = False
        lib.bus_read.restype = ctypes.c_uint8
        lib.bus_read.argtypes = [ctypes.c_uint32]
        lib.bus_write.argtypes = [ctypes.c_uint32, ctypes.c_uint8]
        lib.bus_write_block.argtypes = [ctypes.c_uint32, ctypes.c_void_p, ctypes.c_uint32]
        lib.bus_read_block.argtypes = [ctypes.c_uint32, ctypes.c_void_p, ctypes.c_uint32]
        lib.bus_set_delay.argtypes = [ctypes.c_uint32]
        lib.bus_set_delay.restype = ctypes.c_bool
        lib.bus_ready.restype = ctypes.c_bool
        lib.bus_link_ok.restype = ctypes.c_bool
        lib.bus_attach.restype = None
        lib.bus_detach.restype = None


@bridge
def c_call(fn, *args):
    """Run one blocking C call in a bridge thread so it can advance simulated time."""
    return fn(*args)


async def setup(dut):
    """Clock, reset, and a Driver whose bus.c is ready to run."""
    cocotb.start_soon(Clock(dut.clk, CLK_NS, unit="ns").start())
    dut.rst_n.value = 0
    dut.m_clk.value = 0
    dut.m_csn.value = 1
    dut.m_d.value = 0
    dut.m_oe.value = 0
    dut.stat_flat.value = 0
    await ClockCycles(dut.clk, 6)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 6)
    return Driver(dut)


def bytes_to_buf(data, offset=0):
    """Byte buffer, optionally starting at an odd address."""
    backing = ctypes.create_string_buffer(b"\xEE" * offset + bytes(data) + b"\xEE" * 8)
    return backing, ctypes.addressof(backing) + offset


def ctrl_byte(dut, i):
    return (dut.ctrl_flat.value.to_unsigned() >> (8 * i)) & 0xFF


@cocotb.test()
async def test_attach_pins_and_idle_levels(dut):
    """bus_attach claims exactly the 10 link pins, clears ISO, parks CS_N high / CLK low."""
    drv = await setup(dut)
    await c_call(drv.lib.bus_attach)
    s = drv.sio
    assert sorted(s.funcsel) == sorted(LINK_PINS), f"funcsel pins {sorted(s.funcsel)}"
    assert all(v == 5 for v in s.funcsel.values()), "FUNCSEL must be SIO (5)"
    assert sorted(s.pad) == sorted(LINK_PINS), f"pad pins {sorted(s.pad)}"
    for p, v in s.pad.items():
        assert v & (1 << 6), f"pin {p}: input enable missing"
        assert not v & (1 << 8), f"pin {p}: ISO still set (pad would stay disconnected)"
        assert not v & (1 << 7), f"pin {p}: output disable set"
    for p in (0, 1, 2, 3, 24, 25, 26, 27):
        assert s.pad[p] & (1 << 2), f"data pin {p} should have a pull-down"
    assert (s.out >> CSN_PIN) & 1 and not (s.out >> CLK_PIN) & 1, "idle must be CS_N high, CLK low"
    assert s.oe == (1 << CLK_PIN) | (1 << CSN_PIN), f"only CLK and CS_N driven, got oe={s.oe:#x}"
    assert not s.bad_access, f"unexpected register accesses {s.bad_access}"


@cocotb.test()
async def test_link_ok_and_ready(dut):
    """The driver reads ID / ID_INV and sees CDONE."""
    drv = await setup(dut)
    assert await c_call(drv.lib.bus_ready)
    assert await c_call(drv.lib.bus_link_ok), "ID registers did not read back"
    assert await c_call(drv.lib.bus_read, 0x0000) == ID_VALUE
    assert await c_call(drv.lib.bus_read, 0x0001) == ID_INV
    drv.sio.cdone = 0
    assert not await c_call(drv.lib.bus_ready)
    drv.sio.cdone = 1
    assert dut.contention.value == 0


@cocotb.test()
async def test_register_write_read(dut):
    """fpga.write / fpga.read equivalents: scratch patterns and ctrl registers."""
    drv = await setup(dut)
    for pat in (0xFF, 0xAA, 0x55, 0x8B, 0x01, 0x0):
        await c_call(drv.lib.bus_write, 0x02, pat)
        got = await c_call(drv.lib.bus_read, 0x02)
        assert got == pat, f"scratch {pat:#04x} -> {got:#04x}"
    for i in range(4):
        await c_call(drv.lib.bus_write, 0x10 + i, 0xC0 + i)
    for i in range(4):
        assert ctrl_byte(dut, i) == 0xC0 + i, f"ctrl_flat[{i}]"
        assert await c_call(drv.lib.bus_read, 0x10 + i) == 0xC0 + i
    dut.stat_flat.value = 0xE3E2E1E0
    for j in range(4):
        assert await c_call(drv.lib.bus_read, 0x20 + j) == 0xE0 + j
    assert not drv.sio.bad_access, drv.sio.bad_access
    assert dut.contention.value == 0


@cocotb.test()
async def test_block_transfers(dut):
    """write_block/read_block with odd-aligned buffers, and >128 bytes (multi-frame)."""
    drv = await setup(dut)
    data = [(0x35 * (i + 1)) & 0xFF for i in range(20)]
    backing, ptr = bytes_to_buf(data, offset=1)           # deliberately unaligned
    await c_call(drv.lib.bus_write_block, 0x100, ptr, len(data))
    out = ctypes.create_string_buffer(len(data) + 3)
    await c_call(drv.lib.bus_read_block, 0x100, ctypes.addressof(out) + 3, len(data))
    assert list(out.raw[3:3 + len(data)]) == data, "20-byte block mismatch"

    big = [(i * 167 + 13) & 0xFF for i in range(256)]     # 128 + 128 (RAM is 256 bytes)
    backing, ptr = bytes_to_buf(big)
    await c_call(drv.lib.bus_write_block, 0x100, ptr, len(big))
    out = ctypes.create_string_buffer(len(big))
    await c_call(drv.lib.bus_read_block, 0x100, ctypes.addressof(out), len(big))
    assert list(out.raw[:len(big)]) == big, "256-byte multi-frame block mismatch"

    odd = list(range(1, 131))                             # 128 + 2
    backing, ptr = bytes_to_buf(odd)
    await c_call(drv.lib.bus_write_block, 0x100, ptr, len(odd))
    out = ctypes.create_string_buffer(len(odd))
    await c_call(drv.lib.bus_read_block, 0x100, ctypes.addressof(out), len(odd))
    assert list(out.raw[:len(odd)]) == odd, "130-byte block mismatch"
    assert not drv.sio.bad_access
    assert dut.contention.value == 0


@cocotb.test()
async def test_delay_setting(dut):
    """set_delay range check, and the fastest delay that is still inside the spec works."""
    drv = await setup(dut)
    assert not await c_call(drv.lib.bus_set_delay, 0)
    assert not await c_call(drv.lib.bus_set_delay, 100001)
    assert await c_call(drv.lib.bus_set_delay, 6)     # 6 loops = ~140 ns half period >= 130 ns (6.5 clocks)
    for pat in (0xA5, 0x5A, 0xF0):
        await c_call(drv.lib.bus_write, 0x02, pat)
        assert await c_call(drv.lib.bus_read, 0x02) == pat, "fast setting dropped data"
    assert await c_call(drv.lib.bus_set_delay, 8)     # the default
    assert dut.contention.value == 0


@cocotb.test()
async def test_detach_leaves_idle_bus(dut):
    """bus_detach releases D and leaves CS_N high, CLK low."""
    drv = await setup(dut)
    await c_call(drv.lib.bus_write, 0x04, 1)
    await c_call(drv.lib.bus_detach)
    s = drv.sio
    assert s.oe & DATA_MASK == 0, "data pins still driven after detach"
    assert (s.out >> CSN_PIN) & 1 and not (s.out >> CLK_PIN) & 1
    assert dut.contention.value == 0
