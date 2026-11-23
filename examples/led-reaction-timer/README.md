# led-reaction-timer

Press button 1 to start a round, LED 1 lights after a random 0 to 5.5 s delay. o_signal goes to a header pad (active high). Fabric clock is 50 MHz (PLL x16 / 16).

**Board:** Vicharak Zen 4 (Efinix Trion T4F81 + RP2350). **Ported from:** the Vicharak Shrike example `examples/led_reaction_timer` (GPL-2.0).

## Status

| Check | Result |
| --- | --- |
| Simulation (Icarus Verilog, self-checking) | passes, prints `ALL PASS` |
| Efinity project, pad assignment, timing | builds in Efinity for the T4F81 |
| On hardware | **tested on a Zen 4 with the outputs mirrored to the on-board LEDs; the header / Pmod pads were not probed** |

## Layout

- `rtl/` `led-reaction-timer-zen4-top.v`, `led-reaction-timer.v`
- `sim/` `run-sim.sh`, `tb-led-reaction-timer.v`
- Efinity: `led-reaction-timer.peri.xml`, `led-reaction-timer.xml`, and `sdc/` (`led-reaction-timer.sdc`)
- `bitstream/` `led-reaction-timer.hex.bin` (built in Efinity, loads with the board loader)

## Clock

clk: 50 MHz (50 MHz oscillator on GPIOL_20 into the Efinity PLL).

## Pins

Set in `led-reaction-timer.peri.xml`. Pads marked verified were used in the hardware tests (clock, buttons, LEDs, the RP2350 link pads and header pads R-05 / R-06). Pads marked placeholder are not verified against the Zen schematic: check them before wiring anything.

| Signal | FPGA pad | Mode | Status | Notes |
| --- | --- | --- | --- | --- |
| `clock input (to PLL)` | GPIOL_20 | input | verified | clock oscillator |
| `btn1` | GPIOR_15 | input | verified | button 1 |
| `led1` | GPIOL_13 | output | verified | LED 1 (active low) |
| `o_signal` | GPIOR_00 | output | placeholder | header pad, number not verified |

## Hardware test

Loaded on a Zen 4. The outputs were mirrored to the on-board LEDs and behaved as expected; the header / Pmod pads were not probed, so the pad numbers for them are still unverified.

## Simulate

```
bash sim/run-sim.sh
```

Needs Icarus Verilog (`iverilog`, `vvp`). The script fails unless the testbench prints `ALL PASS`.

## Build and load

1. Open `led-reaction-timer.xml` in Efinity (Trion T4F81).
2. Open Interface Designer and check the PLL and pad assignments against the table above (this is the pad table used for the hardware test).
3. Run synthesis, place and route, then generate the bitstream and program the Zen 4.

5. Load without the Efinity programmer: copy `bitstream/led-reaction-timer.hex.bin` to the board and configure the FPGA with the board loader (`main.py` must already be on the board):

```
python -m mpremote cp bitstream/led-reaction-timer.hex.bin :
python -m mpremote exec "import main as m; m.FILE_NAME='led-reaction-timer.hex.bin'; m.configure()"
```

The last command prints `CDONE = 1` when the FPGA is configured.

## Notes and differences from the Shrike example

- The random delay comes from a free-running LFSR/counter; a `RAND_BITS` parameter was added so the testbench can shorten the maximum delay (the board build uses the original range).

## License

GPL-2.0, like the Shrike repository this is ported from.
