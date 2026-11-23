"""
cocotb testbench for zen_link (Zen Link FPGA endpoint, 8-bit registers).

The RP2350 side is modelled by LinkMaster, which performs exactly the beat
sequence the MCU driver (bus.c) must perform:

  write : CS_N low, [CMD][ADDR_H][ADDR_L][data bytes...], CS_N high
  read  : CS_N low, [CMD][ADDR_H][ADDR_L], release D, one turnaround clock,
          then sample D just before each rising edge, CS_N high

Every edge is separated by `hp` (half period) and is NOT aligned to the FPGA
clock, so the 2-FF synchronisers are exercised with arbitrary phase.
"""

import os
import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, ClockCycles, RisingEdge

CLK_NS = 20.0      # FPGA clock period: fabric runs at 50 MHz (Efinity timing closes at about 66 MHz)
HP_NS = 8.185 * CLK_NS   # default link half period: ~8.2 FPGA clocks, not clock aligned
NCTRL = 4          # must match the tb parameter
NSTAT = 4          # must match the tb parameter
ID_VALUE = 0x5A
ID_INV = 0xA5
VERSION = 0x01
SEED = int(os.environ.get("SEED", "1234"))


async def start_clock(dut):
    """Start the FPGA system clock."""
    cocotb.start_soon(Clock(dut.clk, CLK_NS, unit="ns").start())


async def reset_dut(dut):
    """Apply reset with the link idle, then release it."""
    dut.rst_n.value = 0
    dut.m_clk.value = 0
    dut.m_csn.value = 1
    dut.m_d.value = 0
    dut.m_oe.value = 0
    dut.stat_flat.value = 0
    await ClockCycles(dut.clk, 6)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 6)


class StrobeLog:
    """Records every usr_wr / usr_rd strobe (one sample per FPGA clock)."""

    def __init__(self, dut):
        self.dut = dut
        self.wr = []   # (addr, data)
        self.rd = []   # addr
        cocotb.start_soon(self._run())

    async def _run(self):
        while True:
            await RisingEdge(self.dut.clk)
            if self.dut.usr_wr.value == 1:
                self.wr.append((self.dut.usr_addr.value.to_unsigned(),
                                self.dut.usr_wdata.value.to_unsigned()))
            if self.dut.usr_rd.value == 1:
                self.rd.append(self.dut.usr_addr.value.to_unsigned())


class LinkMaster:
    """Behavioural model of the RP2350 side of the link."""

    def __init__(self, dut, hp_ns=HP_NS):
        self.dut = dut
        self.hp = hp_ns

    async def _t(self, ns):
        await Timer(int(round(ns * 1000)), unit="ps")

    async def _beat_out(self, byte):
        """Drive one byte: D already settles for hp, then one full CLK cycle."""
        self.dut.m_d.value = byte
        await self._t(self.hp)
        self.dut.m_clk.value = 1
        await self._t(self.hp)
        self.dut.m_clk.value = 0

    async def _begin(self, cmd, addr):
        """CS_N low and the three header bytes."""
        self.dut.m_csn.value = 0
        self.dut.m_oe.value = 1
        await self._beat_out(cmd)
        await self._beat_out((addr >> 8) & 0xFF)
        await self._beat_out(addr & 0xFF)

    async def _end(self):
        """Raise CS_N, release D, honour the minimum CS_N-high time."""
        await self._t(self.hp)
        self.dut.m_csn.value = 1
        self.dut.m_oe.value = 0
        await self._t(self.hp * 1.5)

    async def write(self, addr, data):
        """Write the bytes in data starting at address addr (one frame, auto-increment)."""
        await self._begin(len(data) - 1, addr)
        for b in data:
            await self._beat_out(b)
        await self._end()

    async def write_partial(self, addr, nbytes_cmd, data_bytes):
        """Start a write frame but stop after data_bytes bytes (abort test)."""
        await self._begin(nbytes_cmd - 1, addr)
        for b in data_bytes:
            await self._beat_out(b)
        await self._end()

    async def read(self, addr, n=1):
        """Read n bytes starting at address addr; returns a list of ints."""
        await self._begin(0x80 | (n - 1), addr)
        self.dut.m_oe.value = 0              # release D right after the address
        await self._t(self.hp)               # turnaround clock: nobody drives D
        self.dut.m_clk.value = 1
        await self._t(self.hp)
        self.dut.m_clk.value = 0
        out = []
        for _ in range(n):
            await self._t(self.hp)           # FPGA drives the byte during this phase
            out.append(self.dut.d_bus.value.to_unsigned())
            self.dut.m_clk.value = 1
            await self._t(self.hp)
            self.dut.m_clk.value = 0
        await self._end()
        return out

    async def read_aborted(self, addr, n, nbytes):
        """Start a read, take only nbytes bytes, then raise CS_N early."""
        await self._begin(0x80 | (n - 1), addr)
        self.dut.m_oe.value = 0
        await self._t(self.hp)
        self.dut.m_clk.value = 1
        await self._t(self.hp)
        self.dut.m_clk.value = 0
        for _ in range(nbytes):
            await self._t(self.hp)
            self.dut.m_clk.value = 1
            await self._t(self.hp)
            self.dut.m_clk.value = 0
        await self._end()


class Model:
    """Reference model of the register map (see zl_regs.v)."""

    def __init__(self):
        self.scratch = 0
        self.ctrl = [0] * NCTRL
        self.stat = [0] * NSTAT
        self.ram = {}

    def read(self, addr):
        a = addr & 0xFFFF
        if a < 0x100:
            if a == 0x00:
                return ID_VALUE
            if a == 0x01:
                return ID_INV
            if a == 0x02:
                return self.scratch
            if a == 0x03:
                return VERSION
            if 0x10 <= a < 0x10 + NCTRL:
                return self.ctrl[a - 0x10]
            if 0x20 <= a < 0x20 + NSTAT:
                return self.stat[a - 0x20]
            return 0
        return self.ram.get(a & 0xFF, 0)

    def write(self, addr, val):
        a = addr & 0xFFFF
        if a < 0x100:
            if a == 0x02:
                self.scratch = val
            elif 0x10 <= a < 0x10 + NCTRL:
                self.ctrl[a - 0x10] = val
        else:
            self.ram[a & 0xFF] = val

    def set_stat(self, dut, j, val):
        self.stat[j] = val
        flat = 0
        for k, v in enumerate(self.stat):
            flat |= v << (8 * k)
        dut.stat_flat.value = flat


def ctrl_byte(dut, i):
    """Read control register i as the FPGA user logic would see it."""
    return (dut.ctrl_flat.value.to_unsigned() >> (8 * i)) & 0xFF


def check_no_contention(dut):
    assert dut.contention.value == 0, "data bus driven by both sides at once"


@cocotb.test()
async def test_id_and_scratch(dut):
    """ID, ID_INV and VERSION read back, SCRATCH round-trips several patterns."""
    await start_clock(dut)
    await reset_dut(dut)
    m = LinkMaster(dut)

    assert await m.read(0x00, 4) == [ID_VALUE, ID_INV, 0, VERSION], "ID block wrong"
    for pat in (0xFF, 0xAA, 0x55, 0x0F, 0xF0, 0x8B, 0x01, 0x00):
        await m.write(0x02, [pat])
        got = (await m.read(0x02))[0]
        assert got == pat, f"scratch wrote {pat:#04x} read {got:#04x}"
    check_no_contention(dut)


@cocotb.test()
async def test_ctrl_and_stat(dut):
    """MCU writes show up on ctrl_flat; FPGA stat inputs show up on MCU reads."""
    await start_clock(dut)
    await reset_dut(dut)
    m = LinkMaster(dut)
    mdl = Model()

    for i in range(NCTRL):
        v = 0xC0 | (i << 4) | 0x5
        await m.write(0x10 + i, [v])
        mdl.write(0x10 + i, v)
    for i in range(NCTRL):
        assert ctrl_byte(dut, i) == mdl.ctrl[i], f"ctrl_flat[{i}] wrong"
        assert (await m.read(0x10 + i))[0] == mdl.ctrl[i], f"ctrl read-back {i}"

    for j in range(NSTAT):
        mdl.set_stat(dut, j, 0xE0 + j)
    for j in range(NSTAT):
        got = (await m.read(0x20 + j))[0]
        assert got == 0xE0 + j, f"stat[{j}] read {got:#04x}"

    # writes to read-only / unmapped registers must be ignored
    for a in (0x00, 0x01, 0x03, 0x20, 0x30, 0x08):
        await m.write(a, [0x77])
    assert await m.read(0x00, 4) == [ID_VALUE, ID_INV, 0, VERSION]
    assert (await m.read(0x20))[0] == 0xE0
    assert (await m.read(0x30))[0] == 0
    assert (await m.read(0x08))[0] == 0
    check_no_contention(dut)


@cocotb.test()
async def test_every_address_is_distinct(dut):
    """Registers are byte-addressed: neighbouring addresses never alias."""
    await start_clock(dut)
    await reset_dut(dut)
    m = LinkMaster(dut)
    await m.write(0x10, [0x11, 0x22, 0x33, 0x44])
    assert await m.read(0x10, 4) == [0x11, 0x22, 0x33, 0x44]
    await m.write(0x102, [0xA5])
    assert await m.read(0x100, 4) == [0, 0, 0xA5, 0]
    check_no_contention(dut)


@cocotb.test()
async def test_user_bus_and_strobes(dut):
    """Writes/reads >= 0x100 reach the user bus with exactly one strobe per byte."""
    await start_clock(dut)
    await reset_dut(dut)
    log = StrobeLog(dut)
    m = LinkMaster(dut)

    # bank accesses must not create user strobes
    await m.write(0x02, [1])
    await m.read(0x02)
    await ClockCycles(dut.clk, 4)
    assert not log.wr and not log.rd, "bank access leaked onto the user bus"

    await m.write(0x100, [0x11])
    await m.write(0x101, [0x22])
    assert (await m.read(0x100))[0] == 0x11
    assert (await m.read(0x101))[0] == 0x22
    await ClockCycles(dut.clk, 4)
    assert log.wr == [(0x100, 0x11), (0x101, 0x22)], f"wr strobes {log.wr}"
    assert log.rd == [0x100, 0x101], f"rd strobes {log.rd}"
    check_no_contention(dut)


@cocotb.test()
async def test_bursts(dut):
    """Auto-increment bursts, including crossing the 0xFF/0x100 bank/user boundary."""
    await start_clock(dut)
    await reset_dut(dut)
    log = StrobeLog(dut)
    m = LinkMaster(dut)

    data = [(0x10 + i * 0x11) & 0xFF for i in range(16)]
    await m.write(0x100, data)
    assert await m.read(0x100, 16) == data, "16-byte burst mismatch"

    # burst across the boundary: 0xFE, 0xFF (bank, zero) then 0x100, 0x101 (user)
    got = await m.read(0xFE, 4)
    assert got == [0, 0, data[0], data[1]], f"boundary burst {[hex(x) for x in got]}"

    # burst through the ctrl registers
    cw = [0xC0 + i for i in range(NCTRL)]
    await m.write(0x10, cw)
    assert await m.read(0x10, NCTRL) == cw
    assert [ctrl_byte(dut, i) for i in range(NCTRL)] == cw

    # maximum burst: 128 bytes
    big = [random.getrandbits(8) for _ in range(128)]
    await m.write(0x100, big)
    assert await m.read(0x100, 128) == big, "128-byte burst mismatch"
    await ClockCycles(dut.clk, 4)
    assert len(log.wr) == 16 + 128 and len(log.rd) == 16 + 2 + 128
    check_no_contention(dut)


@cocotb.test()
async def test_abort_commits_only_received_bytes(dut):
    """CS_N high mid-frame commits exactly the bytes already received; later frames work."""
    await start_clock(dut)
    await reset_dut(dut)
    log = StrobeLog(dut)
    m = LinkMaster(dut)

    await m.write(0x100, [0xAA, 0xBB, 0xCC, 0xDD])
    log.wr.clear()

    # 4-byte write aborted after 2 bytes: exactly two writes commit
    await m.write_partial(0x100, 4, [0x01, 0x02])
    await ClockCycles(dut.clk, 4)
    assert log.wr == [(0x100, 0x01), (0x101, 0x02)], f"partial write {log.wr}"
    assert await m.read(0x102, 2) == [0xCC, 0xDD], "aborted frame wrote beyond its data"

    # abort inside the header: nothing happens
    log.wr.clear()
    await m.write_partial(0x100, 1, [])
    await ClockCycles(dut.clk, 4)
    assert not log.wr

    # abort a read part-way: the FPGA must release D, next frame is clean
    await m.read_aborted(0x100, 4, 2)
    check_no_contention(dut)
    assert await m.read(0x00, 2) == [ID_VALUE, ID_INV]
    check_no_contention(dut)


@cocotb.test()
async def test_back_to_back_frames(dut):
    """Frames separated by the minimum CS_N-high time keep working."""
    await start_clock(dut)
    await reset_dut(dut)
    m = LinkMaster(dut)
    for i in range(40):
        await m.write(0x02, [(i * 7) & 0xFF])
        assert (await m.read(0x02))[0] == (i * 7) & 0xFF
    check_no_contention(dut)


@cocotb.test()
async def test_speed_sweep(dut):
    """Find which link half periods work; require the documented minimum to pass."""
    await start_clock(dut)
    await reset_dut(dut)
    results = {}
    clean = {}
    for hp in [CLK_NS * x for x in (2, 3, 4, 5, 6, 6.5, 7.5, 12.5, 50)]:
        dut.contention.value = 0                 # judge every speed on its own
        m = LinkMaster(dut, hp_ns=hp)
        ok = True
        try:
            for i in range(6):
                v = random.getrandbits(8)
                await m.write(0x02, [v])
                ok &= (await m.read(0x02))[0] == v
                await m.write(0x100, [v, ~v & 0xFF])
                ok &= await m.read(0x100, 2) == [v, ~v & 0xFF]
        except ValueError:
            ok = False
        results[hp] = ok
        clean[hp] = dut.contention.value == 0
        await reset_dut(dut)                     # recover if a too-fast run lost sync
    dut._log.info("half-period sweep (FPGA clk = %.0f ns): ok=%s", CLK_NS, results)
    dut._log.info("half-period sweep: bus-contention free=%s", clean)
    # documented minimum is 6.5 FPGA clocks
    for hp in [CLK_NS * x for x in (6.5, 7.5, 12.5, 50)]:
        assert results[hp], f"half period {hp} ns must work"
        assert clean[hp], f"half period {hp} ns caused bus contention"


@cocotb.test()
async def test_random_traffic(dut):
    """Random reads/writes at random half periods vs the reference model."""
    await start_clock(dut)
    await reset_dut(dut)
    random.seed(SEED)
    mdl = Model()
    m = LinkMaster(dut)
    # earlier tests leave data in the user RAM, so zero all 256 bytes first
    await m.write(0x100, [0] * 128)
    await m.write(0x180, [0] * 128)
    dut.contention.value = 0
    addrs = [0x00, 0x01, 0x02, 0x03, 0x04, 0x10, 0x11, 0x12, 0x13, 0x14, 0x20, 0x21, 0x23,
             0x24, 0x30, 0xFF, 0x100, 0x101, 0x17F, 0x1FF]

    for it in range(400):
        m.hp = random.uniform(6.5 * CLK_NS, 20 * CLK_NS)
        await Timer(random.randint(0, 40000), unit="ps")     # random phase
        if random.random() < 0.3:
            j = random.randrange(NSTAT)
            mdl.set_stat(dut, j, random.getrandbits(8))
        a = random.choice(addrs)
        n = random.choice([1, 1, 1, 2, 3, 5, 9])
        if a + n > 0x200:
            n = 1
        if random.random() < 0.5:
            data = [random.getrandbits(8) for _ in range(n)]
            await m.write(a, data)
            for k, w in enumerate(data):
                mdl.write(a + k, w)
        else:
            got = await m.read(a, n)
            exp = [mdl.read(a + k) for k in range(n)]
            assert got == exp, (f"iter {it} read {a:#x} x{n}: "
                                f"got {[hex(x) for x in got]} exp {[hex(x) for x in exp]}")
    assert [ctrl_byte(dut, i) for i in range(NCTRL)] == mdl.ctrl
    check_no_contention(dut)
