# pwm-4ch

Eight header pads (LED 0..3 breathe in turn, LED 4..7 blink), LED 1 shows channel 0 and LED 2 shows channel 4. btn1 restarts the sequence. Fabric clock is 50 MHz (PLL x16 / 16); the Shrike version assumed 44.5 MHz.

**Board:** Vicharak Zen 4 (Efinix Trion T4F81 + RP2350). **Ported from:** the Vicharak Shrike example `examples/pwm_4ch` (GPL-2.0).

## Status

| Check | Result |
| --- | --- |
| Simulation (Icarus Verilog, self-checking) | passes, prints `ALL PASS` |
| Efinity project, pad assignment, timing | builds in Efinity for the T4F81 |
| On hardware | **tested on a Zen 4 with the outputs mirrored to the on-board LEDs; the header / Pmod pads were not probed** |

## Layout

- `rtl/` `pwm-4ch-zen4-top.v`, `pwm-4ch.v`
- `sim/` `run-sim.sh`, `tb-pwm-4ch.v`
- Efinity: `pwm-4ch.peri.xml`, `pwm-4ch.xml`, and `sdc/` (`pwm-4ch.sdc`)
- `bitstream/` `pwm-4ch.hex.bin` (built in Efinity, loads with the board loader)

## Clock

clk: 50 MHz (50 MHz oscillator on GPIOL_20 into the Efinity PLL).

## Pins

Set in `pwm-4ch.peri.xml`. Pads marked verified were used in the hardware tests (clock, buttons, LEDs, the RP2350 link pads and header pads R-05 / R-06). Pads marked placeholder are not verified against the Zen schematic: check them before wiring anything.

| Signal | FPGA pad | Mode | Status | Notes |
| --- | --- | --- | --- | --- |
| `clock input (to PLL)` | GPIOL_20 | input | verified | clock oscillator |
| `btn1` | GPIOR_15 | input | verified | button 1 |
| `led[0]` | GPIOR_00 | output | placeholder | header pad, number not verified |
| `led[1]` | GPIOR_01 | output | placeholder | header pad, number not verified |
| `led[2]` | GPIOR_02 | output | placeholder | header pad, number not verified |
| `led[3]` | GPIOR_03 | output | placeholder | header pad, number not verified |
| `led[4]` | GPIOR_05 | output | verified | header pad R-05 |
| `led[5]` | GPIOR_06 | output | verified | header pad R-06 |
| `led[6]` | GPIOR_07 | output | placeholder | header pad, number not verified |
| `led[7]` | GPIOR_08 | output | placeholder | header pad, number not verified |
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

1. Open `pwm-4ch.xml` in Efinity (Trion T4F81).
2. Open Interface Designer and check the PLL and pad assignments against the table above (this is the pad table used for the hardware test).
3. Run synthesis, place and route, then generate the bitstream and program the Zen 4.

5. Load without the Efinity programmer: copy `bitstream/pwm-4ch.hex.bin` to the board and configure the FPGA with the board loader (`main.py` must already be on the board):

```
python -m mpremote cp bitstream/pwm-4ch.hex.bin :
python -m mpremote exec "import main as m; m.FILE_NAME='pwm-4ch.hex.bin'; m.configure()"
```

The last command prints `CDONE = 1` when the FPGA is configured.

## Notes and differences from the Shrike example

- The Shrike version assumed a 44.5 MHz clock; the Zen version runs from 50 MHz (`IN_CLK_HZ`).

## License

GPL-2.0, like the Shrike repository this is ported from.
