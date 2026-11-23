# pll-oscillator

The fabric clock comes from the Efinity PLL (50 MHz oscillator on GPIOL_20, x16 / 16 = 50 MHz). The counter is on four header pads for a logic analyser and on the two LEDs. btn1 = reset (hold), btn2 = rate select (each press steps through the four rates).

**Board:** Vicharak Zen 4 (Efinix Trion T4F81 + RP2350). **Ported from:** the Vicharak Shrike example `examples/pll_oscillator` (GPL-2.0).

Original: Renesas application note AN-003 "How to drive PLL from OSC".

## Status

| Check | Result |
| --- | --- |
| Simulation (Icarus Verilog, self-checking) | passes, prints `ALL PASS` |
| Efinity project, pad assignment, timing | builds in Efinity for the T4F81 |
| On hardware | **tested on a Zen 4 with the outputs mirrored to the on-board LEDs; the header / Pmod pads were not probed** |

## Layout

- `rtl/` `pll-counter.v`, `pll-oscillator-zen4-top.v`
- `sim/` `run-sim.sh`, `tb-pll-counter.v`
- Efinity: `pll-oscillator.peri.xml`, `pll-oscillator.xml`, and `sdc/` (`pll-oscillator.sdc`)
- `bitstream/` `pll-oscillator.hex.bin` (built in Efinity, loads with the board loader)

## Clock

clk: 50 MHz (50 MHz oscillator on GPIOL_20 into the Efinity PLL).

## Pins

Set in `pll-oscillator.peri.xml`. Pads marked verified were used in the hardware tests (clock, buttons, LEDs, the RP2350 link pads and header pads R-05 / R-06). Pads marked placeholder are not verified against the Zen schematic: check them before wiring anything.

| Signal | FPGA pad | Mode | Status | Notes |
| --- | --- | --- | --- | --- |
| `clock input (to PLL)` | GPIOL_20 | input | verified | clock oscillator |
| `btn1` | GPIOR_15 | input | verified | button 1 |
| `btn2` | GPIOR_16 | input | verified | button 2 |
| `counter[0]` | GPIOR_00 | output | placeholder | header pad, number not verified |
| `counter[1]` | GPIOR_01 | output | placeholder | header pad, number not verified |
| `counter[2]` | GPIOR_02 | output | placeholder | header pad, number not verified |
| `counter[3]` | GPIOR_03 | output | placeholder | header pad, number not verified |
| `led1` | GPIOL_13 | output | verified | LED 1 (active low) |
| `led2` | GPIOL_14 | output | verified | LED 2 (active low) |

## Hardware test

Loaded on a Zen 4. The outputs were mirrored to the on-board LEDs and behaved as expected; the header / Pmod pads were not probed, so the pad numbers for them are still unverified.

## Simulate

```
bash sim/run-sim.sh
```

Needs Icarus Verilog (`iverilog`, `vvp`). The script fails unless the testbench prints `ALL PASS`.

## Build and load

1. Open `pll-oscillator.xml` in Efinity (Trion T4F81).
2. Open Interface Designer and check the PLL and pad assignments against the table above (this is the pad table used for the hardware test).
3. Run synthesis, place and route, then generate the bitstream and program the Zen 4.

5. Load without the Efinity programmer: copy `bitstream/pll-oscillator.hex.bin` to the board and configure the FPGA with the board loader (`main.py` must already be on the board):

```
python -m mpremote cp bitstream/pll-oscillator.hex.bin :
python -m mpremote exec "import main as m; m.FILE_NAME='pll-oscillator.hex.bin'; m.configure()"
```

The last command prints `CDONE = 1` when the FPGA is configured.

## Notes and differences from the Shrike example

- The Trion PLL has fixed settings chosen in Efinity (no run-time control pins like the SLG47910), so the run-time part (rate select) is done with a fabric prescaler. The example shows a counter whose speed changes on button 2.

## License

GPL-2.0, like the Shrike repository this is ported from.
