# serv-core

[SERV](https://github.com/olofk/serv), the award-winning bit-serial RISC-V core, running on the Vicharak Zen 4 board (Efinix Trion T4F81). The repository contains a small SoC around SERV, self-checking firmware, simulation tests and an Efinity project. The RP2350 on the board reads the test report from the SoC over the Zen Link, so a Zen board and a USB cable are all that is needed.

| | |
|---|---|
| Core | SERV 1.4.0 (tag 2025-10-15, commit `7d9cde4`), RV32I + Zicsr, unmodified |
| Variants | SERV (1-bit datapath) and QERV (4-bit datapath); optional C extension; no M extension |
| Board | Vicharak Zen 4: 50 MHz Zen Link clock, 25 MHz SERV clock (both from the PLL) |
| Tools | Efinity 2026.1; Icarus Verilog 12 and `riscv64-unknown-elf-gcc` for simulation |

## Status

| Check | Result |
| --- | --- |
| Simulation (Icarus Verilog, self-checking) | passes: the SoC alone with the two Zen 4 images, and the board top through real Zen Link frames (an RP2350 model reads the report; `RESULT: ALL PASS`, led1 lit, led2 off). A mutation test (two deliberate faults in the core) is caught |
| Efinity project, pad assignment, timing | built: 1,215 / 3,888 logic elements (31%), 908 of them LUTs/adders, 641 registers, 10 / 15 memory blocks. Both clocks meet timing: `clk` (50 MHz) max 54.0 MHz, setup slack +1.47 ns; `clk_core` (25 MHz) max 31.2 MHz, setup slack +7.93 ns |
| On hardware | **works** on the Zen 4 over the Zen Link: `serv-report.py` prints the report and it ends with `RESULT: ALL PASS` |

## What is unchanged

`rtl/servxzen-soc.v`, `rtl/servxzen-uart-tx.v`, `rtl/vendor/serv/` and the firmware images are the files of the earlier SERVxZen example; only the file names changed (hyphens instead of underscores) and one comment in the SoC that named the old board top. The board top is new: it adds the Zen Link, which needs a 50 MHz fabric clock, so the PLL has two outputs, and it drops the two UART pads. The pad `GPIOL_03` that carried the UART line to the RP2350 is one of the Zen Link data pins, so the old wiring cannot be used together with the link.

## Repository layout

```
rtl/
  serv-zen4-top.v         Zen 4 board top: power-on and software reset, LEDs, Zen Link, UART bridge, the SoC
  servxzen-soc.v          board-independent SoC: SERV, RAM, GPIO, UART TX, cycle counter, timer
  servxzen-uart-tx.v      memory-mapped UART transmitter
  zl-uart-bridge.v        Zen Link register interface to a UART line (registers at 0x100)
  zl-afifo.v              dual-clock FIFO used by the bridge
  zink/                   Zen Link: zen-link.v, zl-slave.v, zl-regs.v
  vendor/serv/            SERV 1.4.0 as released (CPU, servile wrapper, RAM, timer), licence, VERSION
firmware/
  riscv/                  the code that runs inside the FPGA on SERV: firmware.hex (the image built into the bitstream), selftest.hex, trapperf.hex,
                          and src/ (the C source, start.S, link.ld, golden-value generator and build script)
  RP2350/                 loader-main.py (loads the bitstream), serv-report.py (prints the report), zink_uart.py (UART-style helper for the Zen Link)
sdc/serv-core.sdc          timing constraints
serv-core.xml, serv-core.peri.xml   Efinity project and pad/PLL assignment
bitstream/                the built bitstream (serv-core.hex.bin), once built
sim/
  tb-soc.v                SoC testbench (UART decoder, result and memory checks)
  tb-serv-zink.v          board-top testbench: an RP2350 model reads the report through the Zen Link
  zink-host-model.vh      the RP2350 model (Zen Link frames)
  run-sim.sh              simulations; mutation-test.sh breaks the core on purpose and checks the tests notice
```

## Run it on the Zen 4

1. Open `serv-core.xml` in Efinity (top module `serv_zen4_top`) and run the full flow. The PLL needs two outputs: `clk` 50 MHz (divider 16) for the Zen Link and `clk_core` 25 MHz (divider 32) for SERV; the project already has them. The bitstream is `outflow/serv-core.hex.bin`; a built copy is in `bitstream/serv-core.hex.bin`.
2. Load it into the FPGA from the RP2350 (needs `pip install mpremote`):
   ```
   python -m mpremote cp bitstream\serv-core.hex.bin :serv-core.hex.bin
   python -m mpremote run firmware\RP2350\loader-main.py
   ```
   `loader-main.py` should print `CDONE = 1`.
3. Read the report:
   ```
   python -m mpremote cp firmware\RP2350\zink_uart.py :
   python -m mpremote run firmware\RP2350\serv-report.py
   ```
   The firmware repeats the report about every 2 s. The script prints it and ends with `self-test: ALL PASS`. LED 1 is lit when all tests passed (LED 2 lights on a failure). Button 1 or `fpga.write(0x10, 1)` resets the SoC.

### Firmware in the FPGA (where the C code goes and how to use your own)

**How the image sits in memory.** `firmware/riscv/firmware.hex` is a text file with one 32-bit word per line. Efinity reads it at synthesis through `$readmemh` (the `FIRMWARE` parameter of `rtl/serv-zen4-top.v`, a path relative to the project folder) and uses it as the starting contents of the 4 KB block RAM at address 0. SERV starts executing at address 0 after reset, so the program runs as soon as the FPGA is configured. Nothing is loaded at run time: the image is part of the bitstream, so a new `.hex` means a new Efinity compile and a new bitstream. The RAM holds, from address 0 up: code, read-only data, initialised data, zero-initialised data (cleared by `start.S`), free space, and the stack, which grows down from the top (4 KB).

**The C source** is in `firmware/riscv/src/`: `selftest.c` (the program), `start.S` (reset code: sets the stack, clears the zero-initialised data, calls `main`), `link.ld` (the memory layout above; the link fails if the image plus a 480-byte stack no longer fits), `gen-golden.py` (expected values) and `makehex.py` (binary to hex). The peripheral addresses a program can use (UART transmit, GPIO, cycle counter, timer) are in "Memory map" below. There is no standard library and no `printf`: the program is compiled freestanding and talks to the hardware through those registers.

**Using your own C file.**
1. Put your program in `firmware/riscv/src/` (edit `selftest.c`, or add your own file and change the file name in the `gcc` line of `build.sh`, which compiles `start.S` and `selftest.c`).
2. Run `bash firmware/riscv/src/build.sh rv32i_zicsr 4096 myprog` (needs `riscv64-unknown-elf-gcc` and Python 3). The memory size argument must equal the hardware's `MEMSIZE`.
3. The script compiles and links your code at address 0, converts the binary to hex words, and writes `out/myprog.hex` (plus `.elf`, `.bin` and a `.lst` disassembly). It stops with an error if the image plus the stack does not fit in 4 KB.
4. Copy `out/myprog.hex` over `firmware/riscv/firmware.hex`, run the full flow in Efinity, and load the new bitstream. To try it first without a board, run it in the testbench: `-P tb_soc.FIRMWARE=\"<your hex>\"` (see `sim/run-sim.sh`).

### Firmware images

The RAM is 4 KB (Zen 4 has 15 RAM_5K blocks), so the tests are split into images. The image is baked into the bitstream through `$readmemh` of `firmware/riscv/firmware.hex`; to switch images, copy another one over `firmware.hex` and rebuild.

| Image | Checks | Size |
|---|---|---|
| `selftest.hex` (default) | ALU, branches, loads and stores, control flow, CSRs | 3,360 B |
| `trapperf.hex` | ecall, ebreak, misaligned load and store traps, timer interrupt, clocks per instruction | 3,176 B |

Rebuild the firmware with `bash firmware/riscv/src/build.sh rv32i_zicsr 4096 selftest` (or `... trapperf "-DWITH_TRAP -DWITH_PERF"`); the hex files appear in `firmware/riscv/src/out/`. If a check fails the report prints `FAIL <n> got <hex> exp <hex>`, where `<n>` is the order of the check.

## Results on hardware

Measured on a Zen 4 at 25 MHz with the earlier version of this design (the same SoC and firmware, the UART line wired straight to an RP2350 pin). The Zen Link version reproduces the pass: the report ends with `RESULT: ALL PASS`. Its clock-per-instruction numbers have not been re-recorded, but the SoC and clock are the same.

| Check | Result |
|---|---|
| `selftest` image | ALL PASS, repeated reports clean |
| `trapperf` image | `trap ok`, ALL PASS on repeated passes |

Clocks per instruction (identical to simulation):

| Instruction | SERV | QERV (simulation) |
|---|---|---|
| add | 36.0 | 12.0 |
| shift, slt, branch, jal | 65.7 | 19.2 |
| lw, sw | 67.7 | 21.2 |

At 25 MHz that is 0.69 MIPS for simple ALU instructions and about 0.37 MIPS for shifts, compares, branches and memory accesses. QERV runs the self-test 2.5 times faster in simulation (425,597 vs 1,044,955 clocks).

### Resource use of the SoC alone (Efinity 2026.1, T4F81, earlier version, SERV, no C extension)

| Resource | Used |
|---|---|
| LUT4 | 415 |
| Carry cells (EFX_ADD) | 71 |
| Flip-flops | 280 |
| RAM_5K | 9 of 15 |
| Fmax | 33.5 MHz (25 MHz clock: setup slack 10.2 ns, hold slack 0.6 ns) |

That is roughly 490 of 3,888 logic elements. The CPU itself is only about 265 LUT4; the 32-bit timer is the largest peripheral. The whole Zen Link design (SoC, bridge, Zen Link) measured 1,215 logic elements and 10 of 15 memory blocks in Efinity (see Status).

## Memory map

| Address | What |
|---|---|
| `0x0000_0000` | RAM, 4 KB, firmware preloaded; stack at the top |
| `0x4000_0000` | GPIO register: bit 0 = pass (LED 1), bit 1 = fail (LED 2) |
| `0x4000_0004` | UART TX: write a byte to send it; read bit 0 = busy. 115200 8N1 |
| `0x4000_0008` | free-running 32-bit clock counter (read only) |
| `0x8000_0000` | timer: read = mtime, write = mtimecmp (machine timer interrupt) |
| `0x9000_0000` | simulation only: any write ends the simulation |

A hardware UART is used because SERV needs 36 to 68 clocks per instruction, so a bit-banged 115200 baud loop would leave about three instructions per bit at 25 MHz. The bridge in the board top has the same 217 clocks per bit, so the report reaches the RP2350 at the rate the SoC sends it.

## Zen 4 pins

| Port | Pin | Notes |
|---|---|---|
| `clk_pad` | GPIOL_20 | 50 MHz in; PLL gives `clk` 50 MHz and `clk_core` 25 MHz |
| `btn1` | GPIOR_15 | active low reset |
| `led1` | GPIOL_13 | active low, lit = all tests passed |
| `led2` | GPIOL_14 | active low, lit = a test failed |
| `link_clk_in`, `link_csn_in`, `link_d[0..7]` | GPIOL_09, GPIOL_10, GPIOL_00/03/05/07/04/02/01/06 | Zen Link to the RP2350 (GPIO28, 29, 24, 25, 26, 27, 0, 1, 2, 3) |

## Simulation

Needs Icarus Verilog 11 or newer and Python 3 and a bash shell. A RISC-V compiler is needed only for the full matrix.

```
bash sim/run-sim.sh            # the two Zen 4 images on the SoC, then the board top through the Zen Link; about 2 minutes
bash sim/run-sim.sh full       # also rebuilds the firmware and runs SERV/QERV, with and without the C extension, about 6 more minutes
bash sim/mutation-test.sh      # breaks the core on purpose, expects every mutant to be caught
```

The quick run uses the shipped images, whose build does not leave the end addresses the stack-depth check needs, so that one check is switched off there; the full run keeps it. See `sim/README.md` for what is tested and how.

## Limitations

- SERV has no hardware multiply or divide; the simulation-only `full` image does them in software.
- Upstream notes that the decoder is hand-optimised and can misbehave on illegal opcodes, so there is no illegal-instruction test.
- Not yet recorded on hardware over the Zen Link: restart with btn1 and a timed long soak.
- Fmax of the SoC alone was 33.5 MHz, so there is little headroom to raise the 25 MHz SERV clock.

## Licence

SERV is ISC licensed (`rtl/vendor/serv/LICENSE`); the servile wrapper files carry Apache-2.0 headers.
