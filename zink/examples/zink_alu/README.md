# zink_alu

A worked example of using your own design with zink. An 8-bit ALU sits in the FPGA, and the RP2350 sends it operands and an opcode over the link and reads back the result and flags. It runs on the Zen board.

Read this first, then [docs/USING_ZINK.md](../../docs/USING_ZINK.md) for the general recipe.

## Architecture

```
 RP2350                                   FPGA
 ┌──────────────────────┐                 ┌──────────────────────────────────────┐
 │ alu_demo.py          │                 │ alu.v  a, b, op ──► result, flags    │
 │  fpga.write(0x10..12)│                 │   ▲ ctrl_flat              │ stat    │
 │  fpga.read(0x20/21)  │                 │   │                        ▼         │
 ├──────────────────────┤                 │ zink_alu_top.v: CTRL0/1/2 = A/B/op,  │
 │ fpga.mpy (bus.c)     │   D0..D7        │   result/flags -> flip-flops -> STAT │
 │ builds the frame,    │◄──────────────► ├──────────────────────────────────────┤
 │ drives the pins      │   CLK ────────► │ zl_regs + zl_slave = zen_link        │
 │                      │   CS_N ───────► │ (samples pins with the 50 MHz clock) │
 └──────────────────────┘                 └──────────────────────────────────────┘

 write path:  fpga.write(0x10, A) -> frame -> zl_slave -> CTRL0 -> ctrl_flat[7:0]  -> alu.a
 compute:     alu (combinational) -> result_q / flags_q (flip-flops, every clock)
 read path:   fpga.read(0x20) -> frame -> zl_regs reads stat_flat[7:0] (STAT0) -> D pins -> MCU
```

Only `zink_alu_top.v` knows about both sides. `alu.v` and the link IP never see each other.

## What happens

```
MicroPython                  FPGA
fpga.write(0x10, A) ──┐
fpga.write(0x11, B) ──┼─> zen_link ──ctrl_flat──> alu ──> result/flags ──> stat_flat
fpga.write(0x12, op)──┘                                                       │
fpga.read(0x20)  <────────────────── zen_link <───────────────────────────────┤
fpga.read(0x21)  <────────────────────────────────────────────────────────────┘
```

1. **The MCU writes a register.** `fpga.write(0x10, 0xF0)` sends one frame over the 10 wires: a command byte, the address `0x0010`, then the data byte `0xF0`.
2. **zink stores it.** The link IP checks the frame and puts the byte in CTRL0. CTRL0 is wired straight to the ALU's `a` input, so the ALU sees `0xF0` immediately. B and the opcode arrive the same way through CTRL1 and CTRL2.
3. **The ALU computes.** `alu.v` is combinational. It never knows zink exists: it only sees `a`, `b` and `op`.
4. **The result is captured.** `zink_alu_top.v` copies the ALU outputs into flip-flops on every fabric clock and wires those into STAT0 (result) and STAT1 (flags).
5. **The MCU reads it back.** `fpga.read(0x20)` sends a read frame. zink drives the STAT0 byte onto the wires and the MCU reads it. A read takes tens of microseconds, much longer than the one or two clocks the ALU needs, so the answer is always ready. No handshake is needed.

## Registers

| Register | Address | Meaning |
|---|---|---|
| CTRL0 | 0x10 | operand A |
| CTRL1 | 0x11 | operand B |
| CTRL2 | 0x12 | opcode: 0 ADD, 1 SUB, 2 AND, 3 OR, 4 XOR, 5 NOT A, 6 SHL1, 7 SHR1 |
| STAT0 | 0x20 | result |
| STAT1 | 0x21 | `{4'b0, overflow, negative, carry, zero}` |

LED1 shows the zero flag and LED2 the carry flag (both pins are active low). NOT, SHL1 and SHR1 ignore B. Carry means carry out for ADD, borrow for SUB, and the bit shifted out for the shifts.

## Files

```
zink_alu/
├── rtl/
│   ├── alu.v               the IP: knows nothing about zink
│   └── zink_alu_top.v      glue: CTRL -> ALU inputs, ALU outputs -> STAT, plus zen_link
├── zink_alu.xml            Efinity project (open this in Efinity)
├── sim/
│   ├── tb_zink_alu.v       tri-state bus wrapper around the top
│   ├── test_zink_alu.py    4 cocotb tests: all ops vs a Python model, LEDs, burst write
│   └── run_sim.py
└── mcu/
    └── alu_demo.py         MicroPython demo
```

To read the example in order: `alu.v` (the plain IP), `zink_alu_top.v` (the 30 lines of glue), `test_zink_alu.py` (how it is checked), `alu_demo.py` (how the MCU uses it).

## Run it

**Simulation** (needs `cocotb` 2.x and Icarus Verilog):

```
cd sim
python run_sim.py
```

Expect 4/4 passing. The tests run every op against a Python model (corner cases plus random operands), check the LED pins, and write A, B and the opcode in a single 3-byte frame.

**On the board:**

1. Open `zink_alu.xml` (in this folder) in Efinity. It uses the link IP in `../../rtl` and the shared pin and timing files `../../zen_link.peri.xml` / `../../zen_link.sdc`. The first time, open Interface Designer, run Check Design and Generate Efinity Constraints. Then run the full flow. The bitstream is `outflow/zink_alu.hex.bin` in this folder.
2. Copy it and set the loader's file name (run these from the zink folder):
   ```
   python -m mpremote cp examples/zink_alu/outflow/zink_alu.hex.bin :
   python -m mpremote exec "s=open('main.py').read().replace('zen_link.hex.bin','zink_alu.hex.bin'); open('main.py','w').write(s)"
   ```
3. Load the FPGA onto the board (expect `CDONE = 1`):
   ```
   python -m mpremote exec "import main"
   ```

**Try it by typing commands.** Open the MicroPython shell on the board from the same terminal:

```
python -m mpremote
```

You get a `>>>` prompt. Type these lines one at a time (the text after `#` is what you should see):

```python
import fpga
fpga.init()
fpga.link_ok()              # True: the link is up
fpga.write(0x10, 200)       # A = 200
fpga.write(0x11, 100)       # B = 100
fpga.write(0x12, 0)         # op 0 = ADD
fpga.read(0x20)             # 44   (200 + 100 = 300, wrapped to 8 bits)
fpga.read(0x21)             # 2    (carry set)
```

The flags byte at `0x21` is `bit 0 zero, bit 1 carry, bit 2 negative, bit 3 overflow`. More to try (each line group is one calculation):

```python
fpga.write(0x10, 5); fpga.write(0x11, 5); fpga.write(0x12, 1)       # 5 - 5
fpga.read(0x20)             # 0
fpga.read(0x21)             # 1    (zero flag: LED1 lights)

fpga.write(0x10, 0xFF); fpga.write(0x11, 1); fpga.write(0x12, 0)    # 0xFF + 1
fpga.read(0x20)             # 0
fpga.read(0x21)             # 3    (zero and carry: both LEDs light)

fpga.write(0x10, 0x7F); fpga.write(0x11, 1); fpga.write(0x12, 0)    # 127 + 1
fpga.read(0x20)             # 128
fpga.read(0x21)             # 12   (negative and overflow)

fpga.write(0x10, 0xF0); fpga.write(0x12, 5)                         # NOT 0xF0
fpga.read(0x20)             # 15
```

One frame can set A, B and the opcode together, because consecutive registers auto-increment:

```python
fpga.write_block(0x10, bytes([0x12, 0x34, 0]))   # A=0x12, B=0x34, op=ADD
fpga.read(0x20)             # 70   (0x46)
```

Press `Ctrl+X` to leave the shell.

**Without the shell**, one command from the terminal does a whole calculation and prints the answer:

```
python -m mpremote exec "import fpga; fpga.init(); fpga.write(0x10,200); fpga.write(0x11,100); fpga.write(0x12,0); print(fpga.read(0x20), fpga.read(0x21))"
```

It prints `44 2`.

**Or run the demo script**, which loops through all 8 ops:

```
python -m mpremote run examples/zink_alu/mcu/alu_demo.py
```

Expected output for A = `0xF0`, B = `0x15` (measured on the board):

| Op | Result | Flags |
|---|---|---|
| ADD | 0x05 | carry |
| SUB | 0xDB | negative |
| AND | 0x10 | none |
| OR | 0xF5 | negative |
| XOR | 0xE5 | negative |
| NOT | 0x0F | none |
| SHL1 | 0xE0 | carry, negative |
| SHR1 | 0x78 | none |

If every result is `0x00` with no flags, the board is still running the old LED/button bitstream. Check that `FILE_NAME` in the board's `main.py` is `zink_alu.hex.bin`.

## Adapt it to your own design

Replace `alu.v` with your IP, change the slices and packing in `zink_alu_top.v` to match your register map, and update the model in `test_zink_alu.py`. The step-by-step version is in [docs/USING_ZINK.md](../../docs/USING_ZINK.md).
