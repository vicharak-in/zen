# lzss (example for picorv32-core)

The LZSS compressor as C firmware on the PicoRV32 soft CPU of [picorv32-core](../..), on the Vicharak Zen 4 (Efinix Trion T4F81 + RP2350). The RP2350 sends a file to the CPU and gets the compressed bytes back over the Zen Link. The CPU system (`rtl/zen-picorv32-top.v`) bit-bangs its UART on gpio pins, and a bridge in the board top `rtl/picorv32-lzss-zen4-top.v` turns those pins into Zen Link bytes.

## Status

| Check | Result |
| --- | --- |
| Simulation (Icarus Verilog, self-checking) | passes: the real firmware on the CPU system alone over its UART pins, and the board top through real Zen Link frames (200 bytes); the output is identical to the Python reference encoder and decompresses back to the input |
| Efinity project, pad assignment, timing | built: 2,803 / 3,888 logic elements (72%), 2,548 of them LUTs/adders, and 14 / 15 memory blocks. Both clocks meet timing: `clk` (50 MHz) max 53.5 MHz, setup slack +1.29 ns; `clk_core` (25 MHz) max 29.4 MHz, setup slack +5.95 ns |
| On hardware | **works** on the Zen 4: a 2,402-byte text file compressed to 329 bytes (14.0%) in 0.4 s; the board's output is identical to the Python reference encoder and decompresses back to the input |

## Zen 4 configuration

To fit with the Zen Link, the board top builds the CPU with interrupts off (`IRQ = 0`), the two-stage shifter (`BARREL = 0`), no multiplier and no divider (`MUL = 0`, `DIV = 0`; the firmware does not use them), and the bridge uses a fixed 115200 baud rate and simple FIFO flags (`FIXED_BAUD = 1`, `LITE = 1`). `picorv32.v` is not changed. The simulation runs the firmware on exactly this configuration, so an instruction the CPU lacks would make it fail.

## Layout

- `rtl/` `picorv32-lzss-zen4-top.v` (board top: Zen Link bridge + the CPU system), `zen-picorv32-top.v` (CPU, 3 KB memory, GPIO, UART pins), `picorv32.v`, `picorv32-regs-bram.v`, `zl-uart-bridge.v`, `zl-afifo.v`, `zink/` (Zen Link: `zen-link.v`, `zl-slave.v`, `zl-regs.v`)
- `sim/` `tb-lzss-core.v` (CPU system alone over UART pins), `tb-lzss-zink.v` (through the Zen Link), `zink-host-model.vh`, `lzss_ref.py` (Python reference encoder), `lzss-in.hex` (test input), `run-sim.sh`
- `firmware/riscv/` `firmware.hex` (baked into the bitstream, a copy of `lzss/lzss.hex`) and the C source with `build.sh`: `lzss/`
- `bitstream/` `picorv32-lzss.hex.bin` (built for the Zen 4)
- Efinity: `picorv32-lzss.xml`, `picorv32-lzss.peri.xml`, `sdc/picorv32-lzss.sdc`

## Simulate

```
bash sim/run-sim.sh    # needs iverilog and python3; about 2 minutes; prints PASS twice
```

To rebuild the firmware hex (needs a RISC-V toolchain): `bash firmware/riscv/src/build.sh`, then copy `lzss.hex` to `firmware/riscv/firmware.hex`.

## Build and load

The built bitstream is in `bitstream/picorv32-lzss.hex.bin`; load it with the board loader (`load-zen.ps1` of the Zen examples, or by hand):

```
python -m mpremote cp bitstream\picorv32-lzss.hex.bin :
python -m mpremote exec "import main as m; m.FILE_NAME='picorv32-lzss.hex.bin'; m.configure()"
```

To rebuild it, open `picorv32-lzss.xml` in Efinity (top module `picorv32_lzss_zen4_top`) and run the full flow. The PLL needs two outputs: `clk` 50 MHz (divider 16) for the Zen Link and `clk_core` 25 MHz (divider 32) for the CPU. The result is `outflow/picorv32-lzss.hex.bin`.

## Using it

Load the bitstream, press btn1 (resets the CPU), then run the host tool from the compengine `pc-tools` folder:

```
python lzss-host.py rp:COM8 FILE        # writes FILE.lzb, checks it against the Python encoder and decompresses it again
python rp-check.py COM8                 # optional link check: sends 00 and expects 00 back
```

The byte protocol is one block at a time: the PC sends the block length (1 to 64) and the bytes, the CPU answers with the compressed length and the compressed bytes; a length of 0 resets the history and is answered with 0. The CPU works through the file at about 6 KB/s.

Use `lzss-host.py` for this build. The `compress FILE --rp COM8` command of the compengine tools speaks the protocol of the hardware engine (`compengine/lzss-engine`) and will get no answer from the CPU; worse, the bytes it sends leave the firmware out of step with its block framing, and then every later request is answered wrongly until the bitstream is loaded again (btn1 alone does not clear it). If that happens, reload the bitstream. Those PC tools are not part of this example.
