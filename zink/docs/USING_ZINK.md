# Using zink with your own design

zink gives your FPGA logic a small register file that the RP2350 can read and write. You never edit zink. You write a short top file that connects your design to it.

New to zink? Start with the working examples. Each runs on the Zen board and is explained step by step in its README:

- [examples/zink_pwm](../examples/zink_pwm): the simplest. The MCU sets the brightness of the two LEDs. Registers go one way only (MCU to FPGA).
- [examples/zink_alu](../examples/zink_alu): an 8-bit ALU. The MCU sends operands and gets results and flags back.

The rest of this page is the recipe they follow.

## What you get

```
RP2350 ──10 wires──> zen_link ──ctrl_flat──> your design
                             <──stat_flat──
```

- **ctrl_flat**: what the MCU writes. Register `0x10 + k` is `ctrl_flat[8k+7:8k]`. Use it for inputs, modes, enables.
- **stat_flat**: what the MCU reads. Register `0x20 + k` is `stat_flat[8k+7:8k]`. Use it for results, flags, busy/done.
- Up to 16 of each (`NCTRL`, `NSTAT`).
- For a buffer or a memory, use the **user bus** at `0x100` and up (last section).

## How data moves

```
 RP2350                                   FPGA (Trion T4F81)
 ┌──────────────────────┐                 ┌──────────────────────────────────────┐
 │ your MicroPython     │                 │ your design (alu.v, pwm.v, ...)      │
 │  fpga.write(a, v)    │                 │    ▲ ctrl_flat          │ stat_flat  │
 │  fpga.read(a)        │                 │    │ (MCU writes)      ▼ (MCU reads) │
 ├──────────────────────┤                 ├──────────────────────────────────────┤
 │ fpga.mpy (bus.c)     │   D0..D7        │ zl_regs   registers 0x10.. / 0x20..  │
 │ builds the frame,    │◄──────────────► │ zl_slave  frame decoder              │
 │ drives the pins      │   CLK ────────► │ (samples the pins with the 50 MHz    │
 │                      │   CS_N ───────► │  fabric clock)       = zen_link      │
 └──────────────────────┘                 └──────────────────────────────────────┘
```

Every `fpga.write` or `fpga.read` is one frame on the wires. The MCU is always the master, the 8 data pins are shared (half duplex), and CS_N low marks the frame.

```
write 0x10 = 0x80  (one byte)

 CS_N   ‾‾\______________________________________/‾‾
 D      | CMD 0x00 | ADDR_H 0x00 | ADDR_L 0x10 | DATA 0x80 |
 driven |   MCU    |     MCU     |     MCU     |    MCU    |
          write, 1 byte                          lands in CTRL0

read 0x20  (one byte)

 CS_N   ‾‾\____________________________________________/‾‾
 D      | CMD 0x80 | ADDR_H 0x00 | ADDR_L 0x20 | (turn) | DATA |
 driven |   MCU    |     MCU     |     MCU     | nobody |  FPGA |
          read, 1 byte                           1 clock   byte from STAT0
```

- The command byte: bit 7 is read (1) or write (0), bits 6:0 are the byte count minus 1 (1 to 128 bytes per frame). Extra bytes go to consecutive addresses.
- On a write, the byte is stored in the register and appears on `ctrl_flat`. Your logic sees it at once.
- On a read, the FPGA puts the register on the wires after one turnaround clock. Whatever your logic drives on `stat_flat` at that moment is what the MCU gets.
- The FPGA samples CLK, CS_N and D with its own 50 MHz clock, so there is no clock-domain crossing to design around. Frame details are in [PROTOCOL.md](./PROTOCOL.md).

## The smallest example: zink_pwm

Before the ALU, the whole recipe fits in a few lines. [zink_pwm](../examples/zink_pwm) lets the MCU set the brightness of the two LEDs:

| Register | Address | Direction | Content |
|---|---|---|---|
| CTRL0 | 0x10 | MCU to FPGA | LED1 brightness, 0 to 255 |
| CTRL1 | 0x11 | MCU to FPGA | LED2 brightness, 0 to 255 |

The IP is a counter and a comparator (`pwm.v`, ports `clk`, `duty`, `out`). The glue is the three steps above with nothing coming back:

```verilog
pwm u_pwm1 (.clk(clk), .duty(ctrl_flat[7:0]),  .out(pwm1));   // CTRL0 -> LED1 brightness
pwm u_pwm2 (.clk(clk), .duty(ctrl_flat[15:8]), .out(pwm2));   // CTRL1 -> LED2 brightness
assign led1 = ~pwm1;                                           // LED pins are active low
assign led2 = ~pwm2;
```

and the MCU side is `fpga.write(0x10, 128)`. It runs on the Zen board: both LEDs fade smoothly as you change the values. The ALU example adds results coming back and the same steps in more detail.

## Step 1: write down the register map

For an ALU with inputs A, B, op and outputs result, flags:

| Register | Address | Direction | Content |
|---|---|---|---|
| CTRL0 | 0x10 | MCU to FPGA | A |
| CTRL1 | 0x11 | MCU to FPGA | B |
| CTRL2 | 0x12 | MCU to FPGA | op[2:0] |
| STAT0 | 0x20 | FPGA to MCU | result |
| STAT1 | 0x21 | FPGA to MCU | {overflow, negative, carry, zero} |

Put this table in your README first. Everything else follows from it.

## Step 2: keep your IP clean

Your design (`alu.v`) has plain ports: `a`, `b`, `op`, `result`, flags. It has no link signals. That way it can be simulated alone and reused anywhere.

## Step 3: write the glue top

The glue top (`zink_alu_top.v`) does three things:

1. Slice `ctrl_flat` into your inputs: `.a(ctrl_flat[7:0]), .b(ctrl_flat[15:8]), .op(ctrl_flat[18:16])`.
2. Pack your outputs into `stat_flat`: `assign stat_flat = {16'd0, 4'd0, flags_q, result_q};`.
3. Instantiate `zen_link` with `NCTRL`/`NSTAT` large enough, `rst_n` tied to 1, and `usr_rdata` tied to 0 if you do not use the user bus.

Keep the port list the same as the base `rtl/top.v` (`clk, link_clk_in, link_csn_in, link_d_in/out/oe, btn1, btn2, led1, led2`). Then the existing pin setup and timing constraints work unchanged.

**Timing rule:** a link read takes many fabric clocks (tens of microseconds), so a design that settles in a few clocks needs no handshake. Register your outputs before `stat_flat`, as the example does. If your logic takes longer, add a `busy` or `done` bit in a STAT register and have the MCU poll it. There is no interrupt line.

## Step 4: simulate

Reuse the base `LinkMaster` model. The ALU test does:

```python
from test_zen_link import LinkMaster
m = LinkMaster(dut)
await m.write(0x10, [a]); await m.write(0x11, [b]); await m.write(0x12, [op])
result = (await m.read(0x20, 1))[0]
```

and compares with a Python model. Copy `examples/zink_alu/sim/` as a starting point, then change the model and the register addresses. Run `python run_sim.py`.

## Step 5: build in Efinity

1. Copy `examples/zink_alu/zink_alu.xml` into your own folder as `<your_design>.xml` (it is a plain Efinity project file) and edit the `top_module` and `design_file` lines. The link IP and the pin and timing files are referenced by relative path (`../../rtl/...`, `../../zen_link.peri.xml`, `../../zen_link.sdc`), so adjust those if your folder sits somewhere else. Or open the base project and change the files by hand in Efinity.
2. The design files are `zen_link.v`, `zl_slave.v`, `zl_regs.v`, your IP and your top. Set the top module to your top.
3. Keep `zen_link.peri.xml` and `zen_link.sdc`. The pins match as long as the port names did not change.
4. The first time Efinity opens a new project, open **Interface Designer**, run **Check Design**, then **Generate Efinity Constraints**. Without this the bitstream is not produced (`Missing Interface Designer LPF constraint file`).
5. Run the full flow. The bitstream is `outflow/<project name>.hex.bin`, next to the project file.

## Step 6: load and run on the board

1. Copy the bitstream to the board: `python -m mpremote cp outflow/<name>.hex.bin :`
2. **Make sure `FILE_NAME` in the board's `main.py` is that file name.** If it is stale, the board loads the old design and still prints `CDONE = 1`. One-line patch: `python -m mpremote exec "s=open('main.py').read().replace('old.hex.bin','new.hex.bin'); open('main.py','w').write(s)"`
3. Load it: `python -m mpremote exec "import main"`
4. Drive it:

```python
import fpga
fpga.init()
fpga.write(0x10, 200)       # A
fpga.write(0x11, 100)       # B
fpga.write(0x12, 0)         # ADD
fpga.read(0x20)             # 44 (300 wraps to 8 bits)
fpga.read(0x21) & 2         # carry set
```

Consecutive registers auto-increment inside one frame, so `0x10..0x12` can be written in one 3-byte write (`fpga.write_block`). `examples/zink_alu/mcu/alu_demo.py` is the full script.

## When registers are not enough: the user bus

For memories or large blocks, use addresses `0x100` and up. zen_link gives you `usr_addr[15:0]`, `usr_wr`, `usr_wdata[7:0]`, `usr_rd`, `usr_rdata[7:0]`. `usr_wr` and `usr_rd` are one-clock strobes. `usr_rdata` must be valid in the clock where `usr_rd` is high (combinational or registered RAM both work, and the base testbench checks both). A block RAM behind it is about ten lines of Verilog. See `sim/tb_zen_link.v` for one.

## Checklist

- [ ] Register map written down
- [ ] IP has no link signals
- [ ] Glue top slices `ctrl_flat`, packs `stat_flat`, instantiates `zen_link`
- [ ] Outputs registered, or a done/busy bit added
- [ ] Simulation compares against a software model
- [ ] Interface Designer run once, top module set, flow runs, pins unchanged
- [ ] `FILE_NAME` on the board matches the new bitstream
