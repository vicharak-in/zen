# Zen Link - RP2350 <-> Trion T4 register bus

`import fpga; fpga.write(addr, val); fpga.read(addr)` from MicroPython, and the same
registers from Verilog. 8-bit registers, 10 wires, no clock-domain crossing. In Efinity the link IP is 180 LUT4 / 124 FF (4 ctrl + 4 stat); the LED/button example top around it is 182 LUT4 / 128 FF.

New here? [USING_ZINK.md](./USING_ZINK.md) shows how to connect your own design, with two worked examples: [zink_pwm](../examples/zink_pwm) and [zink_alu](../examples/zink_alu).

## Pins (Zen Link header, hardware V1.0 R0.1)

| Signal | Efinity GPIO | T4F81 package pin | RP2350 GPIO | Direction | Note |
|---|---|---|---|---|---|
| D0 | GPIOL_00 | G5 | 24 | bidir | |
| D1 | GPIOL_03 | G4 | 25 | bidir | |
| D2 | GPIOL_05 | J3 | 26 | bidir | |
| D3 | GPIOL_07 | G3 | 27 | bidir | |
| D4 | GPIOL_04 | F4 | 0 | bidir | FPGA SPI config pin SI |
| D5 | GPIOL_02 | H4 | 1 | bidir | FPGA SPI config pin SCLK |
| D6 | GPIOL_01 | J4 | 2 | bidir | FPGA SPI config pin CS |
| D7 | GPIOL_06 | H3 | 3 | bidir | FPGA SPI config pin SO |
| CLK | GPIOL_09 | J2 | 28 | RP -> FPGA | driven by the RP2350, idle low. The Zen sheet says GPIOL_08, but Efinity's T4F81 package file maps J2 to GPIOL_09 |
| CS_N | GPIOL_10 | H2 | 29 | RP -> FPGA | idle high |
| CDONE | (config pin) | | 4 | FPGA -> RP | `fpga.ready()` |

GPIO0-3 are the config SPI pins and are free for normal use once the FPGA is configured, so load the bitstream first.
The Efinity peripheral file `zen_link.peri.xml` already has these pins: bus `link_d[7:0]` (bidirectional) with signals `link_d_in[i]`, `link_d_out[i]`, `link_d_oe[i]`, plus `link_clk_in` and `link_csn_in`, matching the ports of `zen_link`.

## Clock

Run the fabric `clk` at 50 MHz (20 ns): either the 50 MHz oscillator directly, or the PLL with out divider 16.
Efinity timing on the T4F81 (C2) closes at about 66 MHz (critical path 15.1 ns, 4 LUT levels with routing delays of 1.5-4.5 ns per hop), so 100 MHz does not fit without pipelining.
Minimum link half-period is 6.5 clocks = 130 ns. Measured on the Zen board with stress.py (random write/read-back, full 128-register burst compare): 0 errors with 20 down to 4 loops, errors at 3 loops, so the failing edge is between 80 and 100 ns. The driver default is 8 loops (about 180 ns per half period, 2x the failing one): 2.3 MB/s expected for bursts. For reference, 10 loops measured 1.91 MB/s read / 1.83 MB/s write, 6 loops 2.80 / 2.62, 4 loops 3.65 / 3.35. The first driver version measured 0.64 MB/s because about 300 ns of fixed call overhead per half period dominated the delay loop.

## Frame

CS_N low, then bytes, one per CLK rising edge (data MSB-first inside a byte):

1. CMD: bit7 = read, bits[6:0] = bytes - 1 (1..128 bytes)
2. ADDR_H, ADDR_L: 16-bit address (registers are bytes, no alignment)
3. Write: one data byte per clock, RP drives D. Each byte is a complete register write.
   Read: one turnaround clock (nobody drives), then FPGA drives each byte after the falling edge; RP samples just before the next rising edge.

Address auto-increments per byte. Raising CS_N at any time aborts: bytes already received stay written, nothing after that does.

## Timing rules

- The FPGA oversamples CLK / CS_N / D (3/3/2-flop synchronisers) in its own `clk` domain.
- Minimum CLK half-period: 6.5 FPGA clocks (simulation works down to 3). A burst moves one byte per link clock, so throughput is about 1 / (2 x half period); each loop adds about 40 ns per byte.
- CS_N high between frames: at least 1.5 half-periods.
- Driver default is 8 loops. One loop is subs + a taken bne, about 3 cycles (20 ns at 150 MHz), so a half period is about 20 ns x loops + 20 ns. `fpga.set_pulse_delay(6)` is the fastest setting that still meets 130 ns; 4 passed on the board but has no margin and 3 fails. Single fpga.write()/fpga.read() calls cost about 35 us each, almost all MicroPython call overhead, so use the block calls for many registers.

## Register map (8-bit registers, byte addresses)

| Address | Name | Access |
|---|---|---|
| 0x00 | ID = 0x5A | R |
| 0x01 | ID_INV = 0xA5 (~ID) | R |
| 0x02 | SCRATCH | R/W |
| 0x03 | VERSION = 0x01 | R |
| 0x10 + k | CTRL[k] (to Verilog via `ctrl_flat[8*k +: 8]`), k < 16 | R/W |
| 0x20 + k | STAT[k] (from Verilog via `stat_flat[8*k +: 8]`), k < 16 | R |
| 0x100 and up | User bus: `usr_addr[15:0], usr_wr, usr_wdata[7:0], usr_rd, usr_rdata[7:0]` | your logic |

User bus read data may be combinational or registered. Bank is `cpu_addr[15:8] == 0`.
`fpga.link_ok()` checks ID and ID_INV together, so a floating or stuck bus cannot pass.

## Area (Yosys `synth -flatten; abc -lut 4`, estimate only)

| NCTRL/NSTAT | LUT4 | FF |
|---|---|---|
| 4/4 | 191 | 128 |
| 8/8 | 259 | 160 |
| 16/16 | 382 | 224 |

All inside the 800-LUT budget. This table is a Yosys estimate. Efinity's own report is authoritative: the T4F81 build of the 4/4 link IP is 180 LUT4 / 124 FF.

## MicroPython API

`write(addr, val)`, `read(addr)`, `write_block(addr, buf)`, `read_block(addr, buf)`, `init()`, `deinit()`,
`ready()`, `link_ok()`, `set_pulse_delay(n)`, `get_pulse_delay()`, `FPGAError`.
Addresses 0..0xFFFF, values 0..255. Blocks are any bytes-like object (`bytes`, `bytearray`); addresses auto-increment per byte.

## Verification

`sim/run_sim.py`: 9 RTL tests plus 6 tests running the real `mcu/bus.c` against the RTL, each with combinational and registered user RAM. The examples have their own simulations (`examples/zink_alu/sim`: 4 tests, `examples/zink_pwm/sim`: 3 tests).

On the Zen board: `sim/stress.py` (random write/read-back and 128-byte burst compare) runs with 0 errors at the default speed, the LED/button example top works, and both `zink_pwm` and `zink_alu` run correctly.

## Putting it on the board

### 1. FPGA (Efinity)

Your own top module instantiates `zen_link` and connects `ctrl_flat` / `stat_flat` to your logic.

The ready-made Efinity projects are `zen_link.xml` (LED/button top, in the zink root), `examples/zink_alu/zink_alu.xml` and `examples/zink_pwm/zink_pwm.xml`. Open one and run the flow, or follow the steps below for your own top.

1. Add `rtl/zen_link.v`, `rtl/zl_slave.v`, `rtl/zl_regs.v` to the project and instantiate `zen_link` in your top. Constrain `clk` at 50 MHz (period 20 ns).
2. Feed `clk` at 50 MHz (oscillator directly, or PLL x16 with out divider 16).
3. Pins and PLL are already in `zen_link.peri.xml` (3.3 V LVTTL). If you build your own top, keep the same port names or edit them in Interface Designer.
4. The first time Efinity opens a new project, open Interface Designer, run Check Design and Generate Efinity Constraints. Then run the flow up to bitstream. The file to load is `outflow/<project>.hex.bin`.
5. Copy it to the board and load it with the repository's loader, `bring-up/mcu/rp_fpga_flash.py`: set `FILE_NAME` to your bitstream name and copy it to the board as `main.py`, then run `python -m mpremote exec "import main"` and expect `CDONE = 1`. If you switch designs, update `FILE_NAME` too. A stale name loads the old design and still reports `CDONE = 1`.

### 2. RP2350 (MicroPython)

1. Copy the module to the board: `mpremote cp fpga.mpy :` (or Thonny: right-click the file, upload).
2. If `import fpga` gives "incompatible .mpy", rebuild against the same MicroPython version as the firmware:
   `cd mcu && make -f Makefile.txt MPY_DIR=/path/to/micropython` (delete `build-armv7m` and `fpga.mpy` first when rebuilding)
3. Test by hand:
   ```python
   import fpga
   fpga.ready()           # True once the bitstream is loaded (CDONE)
   fpga.link_ok()         # True when ID 0x5A and ID_INV 0xA5 read back
   fpga.write(0x02, 0x42) # SCRATCH
   fpga.read(0x02)        # 66
   fpga.write(0x10, 0x01) # CTRL[0], appears on ctrl_flat[7:0]
   fpga.read(0x20)        # STAT[0], whatever you drive on stat_flat[7:0]
   ```
4. If `link_ok()` is False: check the pin assignments, then raise `fpga.set_pulse_delay()` (each loop adds about 40 ns per link clock).

Order: load the bitstream first, then `import fpga`. Call `fpga.deinit()` before loading a new bitstream; GPIO0-3 are the FPGA config pins and the driver only claims them once the first read or write happens (or `fpga.init()`).
