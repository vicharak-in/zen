# picorv32-core

PicoRV32 soft RISC-V CPU (RV32IMC, every optional feature on) with a self-checking firmware that reports over UART. The RP2350 reads that report over the Zen Link: the CPU system (`zen-picorv32-top.v`, unchanged) still bit-bangs its UART on a gpio pin, and a bridge in the board top `rtl/picorv32-zen4-top.v` turns that pin into bytes on the Zen Link.

**Board:** Vicharak Zen 4 (Efinix Trion T4F81 + RP2350, 3,888 logic elements). The register file is in block RAM, through the wrapper `rtl/picorv32-regs-bram.v`.

**Zen 4 configuration (needed to fit with the Zen Link):** the Zen Link and bridge add about 750 logic elements to a design that was already at 97%, so the board top `rtl/picorv32-zen4-top.v` builds the CPU with `IRQ = 0` (interrupt logic and q registers off, about 450 elements) and `BARREL = 0` (two-stage shifter instead of the barrel shifter, about 130 elements), and the bridge uses a fixed 115200 baud rate and simple FIFO flags (`FIXED_BAUD = 1`, `LITE = 1`; the RP2350 sees 0 or 1 for bytes waiting and room). `picorv32.v` is not changed, and `zen-picorv32-top.v` keeps interrupts and the barrel shifter on by default, so the other simulations still run the full CPU. Because the interrupt registers are off, the self-test's register test now parks `sp` in a spare memory word at 0xB30 instead of a q register, and `firmware.hex` / `selftest.hex` were rebuilt with clang (`-Oz`, see `firmware/riscv/src/build.sh`); the test results are unchanged.

## Status

| Check | Result |
| --- | --- |
| Simulation (Icarus Verilog, self-checking) | passes: bring-up test, 9-test self-test, official PicoRV32 suite, and the self-test read through real Zen Link frames |
| Efinity project, pad assignment, timing | built in Efinity 2026.1 for the T4F81 with the Zen Link: 3,824 / 3,888 logic elements (98.4%), 2,908 LUT4, 648 adders, 1,460 flip-flops, 13 of 15 RAM blocks; `clk` meets 50 MHz (maximum 53.4 MHz) and `clk_core` meets 25 MHz (maximum 29.0 MHz). It only fits with the smaller Zen 4 configuration described below. |
| On hardware | the 9-test self-test passes on a Zen 4 over the Zen Link (all tests pass) |

## Why the register file is in block RAM

- The stock PicoRV32 keeps its registers in flip-flops with asynchronous reads. On the T4F81 that version needs **5,460 logic elements, but the chip has only 3,888**, so it does not fit.
- The design therefore replaces the register file with two block-RAM copies (`rtl/picorv32-regs-bram.v`, hooked in through the core's `PICORV32_REGS` option). That brings the design to 3,771 / 3,888 and it fits. The cost: the block RAM reads on the falling clock edge, so the register read gets half a clock period and the maximum clock drops to about 29 MHz.
- `rtl/` holds two files (core and wrapper). The wrapper must be analysed before `picorv32.v` in the Efinity project, otherwise the core silently falls back to its flip-flop array.

## Resource usage (Efinity 2026.1, 25 MHz target)

| Board | Register file | LUT4 | Adders | FFs | RAM_5K | Logic elements | Status |
|---|---|---|---|---|---|---|---|
| Zen 4 (T4F81) | with wrapper | 3,111 | 593 | 1,191 | 12 / 15 | **3,771 / 3,888 (97.0%)**, fmax 28.8 MHz | measured, runs on the board |
| Zen 4 (T4F81) | without wrapper | 3,840 | 593 | 2,183 | 6 | 5,460 / 3,888, does not fit | measured earlier, with 1 KB memory |

The Zen 4 "with wrapper" row is the current design (3 KB memory plus UART). The "without wrapper" row is older (1 KB memory, no UART); memory is block RAM, so the LUT count barely changes.

## Layout

- `rtl/` `picorv32-zen4-top.v` (board top: Zen Link bridge + the CPU system), `zen-picorv32-top.v` (CPU, 3 KB memory, GPIO, UART pin; unchanged), `picorv32.v` (the CPU), `picorv32-regs-bram.v` (register-file wrapper), `zl-uart-bridge.v`, `zl-afifo.v`, `zink/` (Zen Link)
- `sim/` `run-sim.sh`, `tb-zen-picorv32-top.v` and `firmware-test.hex` (bring-up), `tb-selftest.v`, `tb-picorv32-zink.v` (self-test through the Zen Link), `zink-host-model.vh`, `tb-stress.v`, `gen-stress-fw.py`, `run-official-tests.sh`
- `firmware/riscv/` `firmware.hex` (baked into the bitstream), `blink.hex`, and `src/` (C + assembly self-test source, `build.sh`, `selftest.hex`); this is the code that runs inside the FPGA on the CPU
- `firmware/RP2350/` `loader-main.py` (the loader that runs on the RP2350 as `main.py`), `selftest-report.py` (reads the report over the Zen Link), `zink_uart.py` (its helper)
- Efinity: `picorv32-core.xml`, `picorv32-core.peri.xml`, and `sdc/` (`picorv32-core.sdc`)

Memory map: 3 KB RAM at 0x0 (`MEM_WORDS = 768`, stack top 0xC00), GPIO at 0x1000_0000. The firmware is read with `$readmemh` at synthesis, so every firmware change needs a full Efinity rebuild and a reload.

## Pins

| Port | Pin | Notes |
|---|---|---|
| clk_pad -> PLL -> clk, clk_core | GPIOL_20 | 50 MHz in; `clk` 50 MHz (Zen Link, divider 16) and `clk_core` 25 MHz (CPU, divider 32). The second PLL output builds and meets timing in Efinity |
| btn1 | GPIOR_15 | active low, reset |
| led1 | GPIOL_13 | active low, lit = all tests passed |
| led2 | GPIOL_14 | active low, lit = a test failed or the CPU trapped |
| link_clk_in, link_csn_in, link_d[0..7] | GPIOL_09, GPIOL_10, GPIOL_00/03/05/07/04/02/01/06 | Zen Link to the RP2350 (GPIO28, 29, 24, 25, 26, 27, 0, 1, 2, 3). The CPU's UART now ends in the bridge, so header pad R-05 is free |

## Build and load

1. Open `picorv32-core.xml` in Efinity (top module `picorv32_zen4_top`) and run the full flow. The result is `outflow/picorv32-core.hex.bin`. A built copy is in `bitstream/picorv32-core.hex.bin`.
2. In PowerShell, from the project folder:
   ```
   python -m mpremote cp outflow\picorv32-core.hex.bin :
   python -m mpremote exec "print([l for l in open('main.py') if 'FILE_NAME' in l])"
   python -m mpremote exec "import main"
   ```
   `firmware/RP2350/loader-main.py` is the loader that runs on the RP2350 as `main.py`; a fresh board needs it copied over once (`python -m mpremote cp firmware\RP2350\loader-main.py :main.py`).
   If `FILE_NAME` names another file, patch it first, or the old design loads. "Up to date" from `cp` means the board already has that exact file.
3. Read the report over the Zen Link, no wires needed:
   ```
   python -m mpremote cp firmware\RP2350\zink_uart.py :
   python -m mpremote run firmware\RP2350\selftest-report.py
   ```
   The report repeats about every 2 s and ends with `RESULT: ALL PASS`.

To change the firmware, see "Firmware in the FPGA" below.

## Firmware in the FPGA (where the C code goes and how to use your own)

**How the image sits in memory.** `firmware/riscv/firmware.hex` is a text file with one 32-bit word per line, padded to the whole memory (768 lines = 3 KB). The CPU system declares its memory as an array and fills it at synthesis with `$readmemh(FIRMWARE, mem)` (the `FIRMWARE` parameter, a path relative to the project folder); Efinity turns that into the starting contents of the block RAM at address 0. The CPU starts at address 0 after reset, so the program runs as soon as the FPGA is configured. Nothing is loaded at run time: the image is part of the bitstream, so a new `.hex` means a new Efinity compile and a new bitstream. The memory holds, from 0 up: code, data, free space, and the stack, which grows down from the top (0xC00).

**The C source** is in `firmware/riscv/src/`: `selftest.c` (the program), `start.S` (reset code and stack), `regtest.S` (generated by `gen-regtest.py`) and `diagprobe.S` (extra test code), `link.ld` (code from address 0) and `build.sh`. GPIO is at 0x1000_0000; selftest.c shows how it sends characters out on the UART pin. The CPU is built without interrupts here (`IRQ = 0`), so a program must not rely on them. There is no standard library and no `printf`: the program is compiled freestanding.

**Using your own C file.**
1. Put your program in `firmware/riscv/src/` (replace `selftest.c`, or add your own file and change the file list in the `clang` line of `build.sh`). `regtest.S` and `diagprobe.S` belong to the self-test and can be dropped from that line.
2. `build.sh` also compiles `selftest.c` on the PC with `-DHOST` as a sanity check (step 2 in the script). Keep that guard in your program, or remove the step.
3. Run `bash build.sh` in that folder (needs `clang`, `lld`, `llvm-objcopy` and Python 3; the build uses RV32IMC and `-Oz`). It links your code at address 0, converts the binary to hex words and writes `selftest.hex`. It stops with an error if the program leaves less than 208 bytes for the stack.
4. Copy `selftest.hex` over `firmware/riscv/firmware.hex`, run the full flow in Efinity, and load the new bitstream. To try it first without a board, run it in the simulation (`bash sim/run-sim.sh`, see Tests); the testbenches take the hex path as a parameter.

## Tests (run from the project folder)

Needs Icarus Verilog; the firmware build and the official suite also need `riscv64-unknown-elf-gcc`.

| Test | What it checks | Command |
|---|---|---|
| Basic bring-up | CPU runs a small program, GPIO gets 0x42, no trap | `bash sim/run-sim.sh` |
| Self-test + UART | alu, shift, mem, mul, div, flow, counters, rvc, regs; the testbench decodes the UART like a terminal and expects `RESULT: ALL PASS` (about 1 minute) | `bash sim/run-sim.sh selftest` |
| Self-test through the Zen Link | the board top with the bridge; a model of the RP2350 reads the report with real Zen Link frames and expects `RESULT: ALL PASS` (a few minutes) | `bash sim/run-sim.sh zink` |
| Stress | random programs; dumps memory so a wrapper build can be diffed against a stock build | `python3 sim/gen-stress-fw.py <seed>`, then `sim/tb-stress.v` |
| Official suite | upstream PicoRV32 tests (45 instruction tests, mul/div hardware vs software, counters, interrupts) on stock and wrapper, with and without compressed, and single-port | `bash sim/run-official-tests.sh` |

The stress testbench is compiled by hand with the same file list the script uses, wrapper first: `rtl/picorv32-regs-bram.v rtl/zen-picorv32-top.v rtl/picorv32.v`.

What the self-test covers: ALU ops with edge-case operands, all shifts, byte/half/word memory access, MUL and DIV against software references, branches, calls and loops, cycle and instruction counters, compressed instructions, and every register x1..x31 (a chain written and re-checked, with x0 staying zero). It does not test interrupts; the official suite does.

## Status and open items

- Zen 4: official suite passes on all variants; the full 9-test self-test (alu, shift, mem, mul, div, flow, counters, rvc, regs) passes in simulation (also through the Zen Link) and passed on the board over UART before the move to the Zen Link. The earlier diagnostic build's memory and stack probes also matched simulation.
- An earlier hardware-only failure (a data read of address 4 returned 0, a return through the stack restarted the CPU) did not come back after the firmware layout changed. Its root cause was never proven.
- Interrupts are off in the Zen 4 build (see the next section) and untested on hardware in any build.
