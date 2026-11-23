# lzss-compressor

Lossless compression experiments for the Vicharak Zen boards: simple hardware-style algorithms (BDI, FPC) against an LZ-style dictionary coder (LZSS), first measured in Python and then run in the FPGA, as a hardware engine (`lzss-compressor`) and as C firmware on a PicoRV32 soft CPU (the `picorv32-lzss` example). A PC sends a file through the RP2350's USB port, the RP2350 passes it to the FPGA over the Zen Link, the FPGA compresses it, and the PC checks that the result decompresses back to the original.

**Boards:** the hardware compressor and decompressor in this folder is the board build for the Zen 4 over the Zen Link. The CPU version of the compressor is the separate example [picorv32-lzss](../picorv32-lzss) (built and tested on the Zen 4); `firmware/pc-tools/lzss-host.py` is its host tool.

## Layout

```
lzss-compressor/
  README.md
  rtl/                  hardware LZSS compressor + decompressor in Verilog (no CPU), Zen Link board top, Zen Link files in rtl/zink/
  sim/                  testbenches and run-sim.sh, synth.sh (Yosys resource report), and study/
    study/                Python measurements (no board needed)
      lossless-codecs.py    real encoders and decoders for BDI, FPC, text-BDI and LZSS; verifies every round trip
      make-test-files.py    turns an image into raw pixel files the codecs can meaningfully test
  sdc/                  timing constraints
  bitstream/            lzss-compressor.hex.bin, the built bitstream
  firmware/
    pc-tools/           PC side: compengine.py (compress / decompress), lzss_ref.py (Python reference), lzss-host.py (host tool of the CPU build),
                        hw-probe.py, rp-check.py, zink_uart.py (the RP2350 side of the Zen Link), compress.cmd, decompress.cmd, tests/, samples/
  lzss-compressor.xml   Efinity project (T4F81, top = lzss_zen4_top)
  lzss-compressor.peri.xml   pins and PLL
```

`lzss_ref.py` keeps its underscore because other scripts import it by name.

The board is the Zen 4 (Trion T4F81). A Zen 8 version can be added the same way once that board is brought up.

## What the measurements say

Compressed size as a share of the original (lower is better; 100% = no gain; every codec decompressed back to the exact input, header included):

| Data | BDI | FPC | text-BDI | LZSS (512 B window) | zlib (reference) |
|---|---|---|---|---|---|
| English prose | 100.9% | 109.0% | 89.9% | **59.0%** | 34.5% |
| Verilog source | 100.8% | 105.5% | 89.7% | **32.8%** | 16.8% |
| CSV of readings (text) | 100.9% | 109.4% | 77.7% | **48.5%** | 35.2% |
| int32 sensor readings | **35.2%** | 59.4% | 92.3% | 40.6% | 29.1% |
| int64 pointers near one base | 39.9% | 84.4% | 100.2% | **33.2%** | 23.9% |
| Diagram or screenshot, raw pixels | 71.0% | 63.8% | 70.1% | **29.5%** | 17.5% |
| Photo, raw pixels | 100.8% | 109.1% | 88.4% | 92.1% | 73.5% |
| `.jpg` / `.png` files | 100.9% | 109% | 100.2% | 110–112% | 98–100% |

- BDI and FPC were designed for cache lines of integers and pointers. On text they give nothing, and FPC makes it slightly larger.
- LZSS with a 512-byte window is the reasonable general choice: no tables, no Huffman coding, and it also does well on binary data.
- BDI wins only on slowly varying binary numbers (sensor data).
- Already-compressed files (`.jpg`, `.png`, `.zip`) do not shrink. Use text, source, CSV, or raw pixel dumps. A production version would add a "stored" fallback so the output is never larger than the input plus a small header.

Reproduce: `python sim/study/lossless-codecs.py yourfile.txt` (prints this table for your files plus two synthetic binary sets). For images: `pip install pillow`, `python sim/study/make-test-files.py picture.png`, then pass the `_raw_rgb.bin` file.

## The LZSS format and the CPU firmware

- **Format:** LZSS, 512-byte window. A literal is `0` + 8 bits; a match is `1` + 9 bits (distance - 1) + 4 bits (length - 3), length 3..18. The window carries over between 64-byte blocks; a match never crosses the end of its block; each block's output is padded to a whole byte.
- **Protocol (lock-step, so the 25 MHz CPU never overruns):** PC sends `L` (1..64) then `L` raw bytes; the board replies `C` then `C` compressed bytes. `0` resets the history and is acknowledged with `0`.
- **CPU build:** the firmware, the board top, the pin table, the simulation and the build steps are in `picorv32-lzss` (see its README). It uses about 750 bytes of code and 664 bytes of buffers in the 3 KB RAM, and compressed the 2,402-byte test file to 329 bytes in 0.4 s on the Zen 4.

## Command line (compress / decompress)

Run from `firmware/pc-tools` with a Zen Link build loaded; add `--rp COM8` so the data goes through the RP2350 (below). Without `--rp` the tool talks to a USB-serial adapter, which only works with a build that has its UART on header pads (no current build does):

    .\compress FILE            -> writes FILE.lzb next to it, prints sizes, ratio, path, time
    .\decompress FILE.lzb      -> writes FILE (or FILE.restored.ext if FILE exists; never overwrites)

Options: `-o OUT` for the output name, `-p COMx` to pick the adapter port (default: the one CH340 adapter, or env `COMPENGINE_PORT`), `--check-reference` (compress) to compare with the Python encoder, `--force` (decompress) to overwrite `-o`.
Incompressible files are stored (`LZB0`, +8 bytes) instead of growing. Decompress runs on the PC only (no board, no pyserial). Test without hardware: `python3 tests/test-compengine.py`.

    .\decompress FILE.lzb --rp COM8      (decode on the FPGA, checked against the PC's decode; needs the hardware engine build)

### Through the RP2350 (no UART adapter, no wires)

    .\compress FILE --rp COM8

The PC only sends the file and receives the result over the RP2350's own USB port: it sends `[u32 length][file bytes]` and gets the `.lzb` container back. The tool starts a small MicroPython engine on the RP2350 (raw REPL, no files to copy; the Zen Link helper class `firmware/pc-tools/zink_uart.py` is sent in front of it, and the board's own `fpga` module does the Zen Link transfers) that cuts the data into 64-byte blocks, runs the block protocol with the FPGA over the Zen Link and streams the container back (so big files never need to fit in RP2350 RAM). The PC only adds the stored fallback for incompressible data and verifies the result by decompressing it. Inside the FPGA the bridge turns the Zen Link bytes into the UART lines of the unchanged compressor, so the byte protocol is the same as before; the old `--rp-uart/--rp-tx/--rp-rx` options are gone because no RP2350 UART pins are used. Rebuild in Efinity, load with `mpremote cp ... :` and `mpremote exec "import main"`, then run compress. Check the Zen Link and the design with `python firmware\pc-tools\rp-check.py COM8`. Tested only against a simulated RP2350 (the RP2350 programs run on CPython against a fake Zen Link) and in the Verilog simulation.

## Hardware engine (replaces the CPU build)

This folder holds a Verilog version of the same compressor plus a decompressor (no CPU, 1132 LUTs in Yosys vs 3,113). `lzss-compressor.xml` builds it; the details are in the section "Hardware engine details" below. `--baud` (default 921600, `--baud 115200` for the original rate) now sets the UART rate between the Zen Link bridge and the engine inside the FPGA; it is switched at run time and restored afterwards. The Zen Link itself is the speed limit on the RP2350 side. The CPU version of the compressor is the `lzss` example of PicoRV32-Zen.

## Status and open items

- `lzss-compressor` is built in Efinity (including the second PLL output `clk_core`) and works on the Zen 4 over the Zen Link, for both directions. Compress on real files (all decompress back to the input): the 97 KB `picorv32.v` to 36.3% (identical to the Python reference encoder), a 59 KB sensor CSV to 44.4%, README prose to 71.3%, and a 79 KB PNG is stored (+8 bytes). Decode on the FPGA of the same files gives output identical to the PC's decode, at about 25 to 40 KB/s. The PC tool tests pass.
- Decode has a size limit on the RP2350 side: the decoded data comes back faster than it is read, and the bridge's receive FIFO holds 1,023 bytes. `compengine.py` therefore sends at most 7 blocks (448 raw bytes) per group and keeps two groups in flight (at most 910 bytes outstanding). Without that cap, larger files lost bytes on the board (receive overflow flag set in the bridge's STATUS register).
- A run that fails leaves the engine in a bad state, and the next run's first command can fail once. Reset it with `python -m mpremote exec "import fpga; fpga.write(0x10, 1); fpga.write(0x10, 0)"` (or btn1) before the next run.
- The CPU build (`picorv32-lzss`) is built (2,803 of 3,888 logic elements, both clocks meet timing) and works on the Zen 4: `lzss-host.py rp:COM8 test.txt` compressed 2,402 bytes to 329 (plus an 8-byte header) in 0.4 s, identical to the Python reference encoder, and the saved file decompressed back to the input. That test file repeats one sentence, so 14% is not typical; use real prose, source or CSV for realistic ratios (59% / 33% / 49% in the Python study).
- `compress FILE --rp COM8` is for the hardware engine build only; on the CPU build use `lzss-host.py`.
- Still open: throughput with large files on the CPU build (the search slows as the 512-byte window fills), a "stored" fallback for incompressible data, a hash table to speed up matching, and a Zen 8 folder.

## Hardware engine details

The same compressor as the PicoRV32 firmware, written in Verilog, plus a hardware decompressor. Same byte protocol and same bits for compression, so `compress ... --rp COM8` and the PC tools work unchanged.

**Status:** the RP2350 now reaches this engine over the Zen Link. The compressor RTL (`lzss-hw-top.v`, `lzss-core.v`, ...) is unchanged; the new board top `rtl/lzss-zen4-top.v` puts a Zen Link bridge in front of it. Simulation passes (the engine on its own, and the board top driven by real Zen Link frames, including the baud switch and the stream commands). Built in Efinity 2026.1 for the T4F81: 2,177 / 3,888 logic elements (56%), 1,439 LUT4, 965 flip-flops, 362 adders, 12 RAM blocks; `clk` meets 50 MHz (maximum 54.1 MHz) and `clk_core` meets 25 MHz (maximum 29.3 MHz). Tested on a Zen 4 over the Zen Link: it works. `bitstream/lzss-compressor.hex.bin` is that build. Decompression: `decompress FILE.lzb --rp COM8` decodes on the FPGA and checks it against the PC's decode.



- `rtl/` `lzss-zen4-top.v` (board top: Zen Link bridge + engine), `lzss-core.v`, `lzss-hw-top.v`, `rx-fifo.v`, `uart-rx.v`, `uart-tx.v`, `zl-uart-bridge.v`, `zl-afifo.v`, `zink/` (Zen Link: `zen-link.v`, `zl-slave.v`, `zl-regs.v`)
- `sim/` `tb-lzss-hw-core.v` (the engine alone over UART lines), `tb-lzss-zink.v` (through the Zen Link), `zink-host-model.vh`, `run-sim.sh` (uses `../firmware/pc-tools/lzss_ref.py` as the reference), `synth.sh` (Yosys resource report)
- Efinity: `lzss-compressor.xml`, `lzss-compressor.peri.xml`, `sdc/lzss-compressor.sdc`
- `bitstream/` `lzss-compressor.hex.bin` (built in Efinity, loads with the board loader)
- The PC tools (`compress`, `decompress`) are in `firmware/pc-tools`.

Protocol: `0` = reset history (reply `0`); `1..64` + bytes = compress a block (reply `C` + `C` bytes); `0x80 | C` + `C` compressed bytes = decode one block (reply `D` + `D` raw bytes). The decoder uses the same 512-byte history window as the encoder, so blocks must be sent in order after a reset.

Host-side limit for decode: the decoded bytes come back faster than the RP2350 reads them, and the bridge's receive FIFO holds 1,023 bytes (`AW_RX = 10`), so a host must never have more than about 900 raw bytes outstanding. `firmware/pc-tools/compengine.py` sends at most 7 blocks (448 raw bytes) per `0x7C` group and keeps two groups in flight. A host that sends more loses bytes (sticky receive-overflow bit 3 in the bridge STATUS register).

- `rtl/uart-rx.v`, `rtl/uart-tx.v`: 8N1 UART blocks (CPB = clock cycles per bit, 217 at 25 MHz).
- `rtl/lzss-core.v`: protocol FSM, 1024-byte circular window RAM (written twice so two bytes read per clock), match search at one candidate distance per clock (nearest first, strictly-longer wins), bit-serial token packer, 128-byte output RAM so the block length can be sent first.
- `rtl/lzss-hw-top.v`: engine top level with UART ports (clk, btn1, led1, led2, uart_tx, uart_rx), power-on reset and input synchroniser. Unchanged; `lzss-zen4-top.v` instantiates it and connects uart_tx / uart_rx to the bridge.
- `rtl/lzss-zen4-top.v`: the Zen 4 board top. Two clocks: `clk` 50 MHz for the Zen Link and the bridge registers, `clk_core` 25 MHz for the engine (the same clock as before, so the UART timing is unchanged). The bridge's receive FIFO holds 1024 bytes because the engine answers while the RP2350 is still sending.
- `sim/run-sim.sh`: Icarus testbenches acting as the host; every output byte is compared with `lzss_ref.py` on 10 inputs (1 byte, exactly 64, zeros, repeats, random, text, history wrap, the fake IMU csv), and the hardware decoder must restore each input exactly. Part 1 runs the engine over its UART lines, part 2 runs the board top through real Zen Link frames (block commands, 0x7D / 0x7C stream commands, decode, and the baud switch at 8 and 11 clocks per bit with the return to the default). All pass (about 2.5 minutes).
- `sim/synth.sh`: Yosys `synth_ice40` (4-LUT flow) resource report.

### Yosys result (synth_ice40, flat, CPB = 217, compressor + decompressor + runtime baud switch)

| | hardware engine | PicoRV32 design (Efinity) |
|---|---|---|
| 4-LUTs | 886 (583 for the compressor alone) | 3,113 |
| Flip-flops | 385 | 1,210 |
| Carry cells | 240 | 609 adders |
| Block RAM | 5 x 4 Kb blocks (2 x 1 KB window copies + 128 B output) | 12 x 5 Kb |

The decoder adds about 206 LUTs and no extra RAM. Efinity numbers for the compressor-only build were 617 logic elements (448 LUTs + 112 adders). This is a Yosys estimate for iCE40 (the Efinity numbers would differ slightly; Trion counts carry cells as logic elements).

### Speed

The search tests one distance per clock: about 500 clocks per token at full history, so about 20 us per token at 25 MHz and well above the UART rate. The 115200 UART (11.5 KB/s both ways) is the limit, so a 59 KB file takes about 8 s instead of about 30 s on the CPU version. The link speed can be changed at run time (below), so the UART no longer has to stay the limit.

### Build for the Zen 4 (Efinity)

The project `lzss-compressor.xml` builds this engine: top module `lzss_zen4_top`, design files `rtl/*.v` and `rtl/zink/*.v`, the peri file, and the sdc.
1. Open `lzss-compressor.xml` in Efinity (reopen it if it is already open). In Interface Designer the PLL needs two output clocks: `clk` 50 MHz (divider 16) and `clk_core` 25 MHz (divider 32). The second output builds and meets timing in Efinity. Compile.
2. From this folder: `python -m mpremote cp bitstream\lzss-compressor.hex.bin :` then `python -m mpremote exec "import main"`.
3. From `firmware/pc-tools`: `.\compress FILE --rp COM8`. No wires and no copying of Python files are needed: the tool sends its RP2350 program (with the Zen Link helper) itself.
LED 1 is lit while the engine is busy. Pins: clock, btn1, LEDs and the ten Zen Link pads (GPIOL_09, GPIOL_10, GPIOL_00/03/05/07/04/02/01/06); the old `uart_rx` / `uart_tx` pads are now Zen Link data pins. Software reset: `fpga.write(0x10, 1)`. The Zen Link bridge registers are at 0x100.. (see `rtl/zl-uart-bridge.v`). Not yet built or loaded on the board since the move to the Zen Link.

### Baud switching at run time

The design starts at 115200 (217 clocks per bit at 25 MHz). Command `0x7E` + divisor byte (8..255 clocks per bit; smaller values mean the default) answers `0x7E` at the old rate and then both the receiver and transmitter use the new rate. The RP2350 tool then writes the same divisor into the bridge (registers 0x104 / 0x105), so the bridge's bit time follows (divisor 27 for the default 921600, divisor 12 for 2,000,000). If the link is silent for about 0.67 s the engine returns to 115200 and to the command state, so a crashed session never leaves the board stuck. `compengine --baud N` does all of this; the default for `--rp` is 921600 and `--baud 115200` keeps the slow rate. `run-sim.sh` tests divisors 8 and 11, the switch back and the idle fallback.

### Pipelining and the two-lane search

- `rx-fifo.v` (1024 bytes, block RAM) sits between the UART receiver and the core, so the host can send block N+1 while block N is compressing. The RP2350 programs keep one block ahead. The host keeps at most two chunks of 448 bytes ahead.
- The match search reads two candidate distances per clock (a third window RAM copy); the nearer one wins, so the output is still bit-identical to the reference encoder.
- Yosys (iCE40): 1132 LUT4, 9 RAM (with the stream commands below). `run-sim.sh` also runs pipelined and fast-baud pipelined cases.

### Stream commands (the FPGA cuts the blocks)

- `0x7D lo hi` + N raw bytes: the core cuts the data into 64-byte blocks itself and answers `[C][C bytes]` per block (the last block is shorter). The history carries across blocks like before.
- `0x7C lo hi` + M compressed bytes (whole `[C][C bytes]` blocks): the core decodes block after block and answers `[D][D bytes]` per block.
- The RP2350 now only forwards chunks of up to 448 bytes (7 blocks) with a 3-byte header and keeps two chunks in flight. The single-block commands (`1..64`, `0x80|C`) still work and are used by `hw-probe.py` and the UART adapter path.
