# stack-processor

The RP2350 sends the instruction bytes through the Zen Link byte port (zen_spi.py); the stack lives in a block RAM. LED 1 is on while the stack holds data (an addition, the Shrike example had no LED). The RP2350 reaches the design through the Zen Link (D0..D7, CLK, CS_N) with the zen_spi.py byte port. btn1 resets the design, and so does fpga.write(0x10, 1) (ZenSPI.reset()). Fabric clock: 50 MHz (PLL x16 / 16), required by the Zen Link synchronisers.

**Board:** Vicharak Zen 4 (Efinix Trion T4F81 + RP2350). **Ported from:** the Vicharak Shrike example `examples/stack_processor` (GPL-2.0).

## Status

| Check | Result |
| --- | --- |
| Simulation (Icarus Verilog, self-checking) | passes, prints `ALL PASS` |
| Efinity project, pad assignment, timing | builds in Efinity for the T4F81 |
| On hardware | **tested on a Zen 4, works as designed** |

## Layout

- `rtl/` `lifo-bram.v`, `stack-processor-zen4-top.v`, `stack-processor.v`, `zl-byte-port.v`, `zink/zen-link.v`, `zink/zl-regs.v`, `zink/zl-slave.v`
- `sim/` `run-sim.sh`, `tb-stack-processor.v`
- `firmware/RP2350/` `multiplication.py`, `zen_spi.py`
- Efinity: `stack-processor.peri.xml`, `stack-processor.xml`, and `sdc/` (`stack-processor.sdc`)
- `bitstream/` `stack-processor.hex.bin` (built in Efinity, loads with the board loader)

## Clock

clk: 50 MHz (50 MHz oscillator on GPIOL_20 into the Efinity PLL).

## Pins

Set in `stack-processor.peri.xml`. Pads marked verified were used in the hardware tests (clock, buttons, LEDs, the RP2350 link pads and header pads R-05 / R-06). Pads marked placeholder are not verified against the Zen schematic: check them before wiring anything.

| Signal | FPGA pad | Mode | Status | Notes |
| --- | --- | --- | --- | --- |
| `clock input (to PLL)` | GPIOL_20 | input | verified | clock oscillator |
| `btn1` | GPIOR_15 | input | verified | button 1 |
| `led1` | GPIOL_13 | output | verified | LED 1 (active low) |
| `link_clk_in` | GPIOL_09 | input | verified | RP2350 GPIO28 |
| `link_csn_in` | GPIOL_10 | input | verified | RP2350 GPIO29 |
| `link_d[0]` | GPIOL_00 | inout | verified | RP2350 GPIO24 |
| `link_d[1]` | GPIOL_03 | inout | verified | RP2350 GPIO25 |
| `link_d[2]` | GPIOL_05 | inout | verified | RP2350 GPIO26 |
| `link_d[3]` | GPIOL_07 | inout | verified | RP2350 GPIO27 |
| `link_d[4]` | GPIOL_04 | inout | verified | RP2350 GPIO0 |
| `link_d[5]` | GPIOL_02 | inout | verified | RP2350 GPIO1 |
| `link_d[6]` | GPIOL_01 | inout | verified | RP2350 GPIO2 |
| `link_d[7]` | GPIOL_06 | inout | verified | RP2350 GPIO3 |

## Hardware test

Loaded on a Zen 4 and checked against the behaviour described above: it works as designed.

## Simulate

```
bash sim/run-sim.sh
```

Needs Icarus Verilog (`iverilog`, `vvp`). The script fails unless the testbench prints `ALL PASS`.

## Build and load

1. Open `stack-processor.xml` in Efinity (Trion T4F81).
2. Open Interface Designer and check the PLL and pad assignments against the table above (this is the pad table used for the hardware test).
3. Run synthesis, place and route, then generate the bitstream and program the Zen 4.
4. Copy the files in `firmware/RP2350/*.py` to the RP2350 (MicroPython) and run the main script (`multiplication.py`, `zen_spi.py`).

5. Load without the Efinity programmer: copy `bitstream/stack-processor.hex.bin` to the board and configure the FPGA with the board loader (`main.py` must already be on the board):

```
python -m mpremote cp bitstream/stack-processor.hex.bin :
python -m mpremote exec "import main as m; m.FILE_NAME='stack-processor.hex.bin'; m.configure()"
```

The last command prints `CDONE = 1` when the FPGA is configured.

## Notes and differences from the Shrike example

- LED 1 lights while the stack is not empty (an addition, the Shrike example had no LED).
- The stack is an inferred 512 x 4 block RAM.

## License

GPL-2.0, like the Shrike repository this is ported from.
