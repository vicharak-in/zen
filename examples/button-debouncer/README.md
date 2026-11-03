# button-debouncer

Both on-board buttons are debounced and shown on the LEDs. Pressing a button lights its LED once the press has been steady for 10 ms. Fabric clock is 50 MHz (PLL x16 / 16).

**Board:** Vicharak Zen 4 (Efinix Trion T4F81 + RP2350). **Ported from:** the Vicharak Shrike example `examples/button_debouncer` (GPL-2.0).

## Status

| Check | Result |
| --- | --- |
| Simulation (Icarus Verilog, self-checking) | passes, prints `ALL PASS` |
| Efinity project, pad assignment, timing | builds in Efinity for the T4F81 |
| On hardware | **tested on a Zen 4, works as designed** |

## Layout

- `rtl/` `button-debouncer-zen4-top.v`, `button-debouncer.v`, `debouncer.v`
- `sim/` `run-sim.sh`, `tb-button-debouncer.v`
- Efinity: `button-debouncer.peri.xml`, `button-debouncer.xml`, and `sdc/` (`button-debouncer.sdc`)
- `bitstream/` `button-debouncer.hex.bin` (built in Efinity, loads with the board loader)

## Clock

clk: 50 MHz (50 MHz oscillator on GPIOL_20 into the Efinity PLL).

## Pins

Set in `button-debouncer.peri.xml`. Pads marked verified were used in the hardware tests (clock, buttons, LEDs, the RP2350 link pads and header pads R-05 / R-06). Pads marked placeholder are not verified against the Zen schematic: check them before wiring anything.

| Signal | FPGA pad | Mode | Status | Notes |
| --- | --- | --- | --- | --- |
| `clock input (to PLL)` | GPIOL_20 | input | verified | clock oscillator |
| `btn1` | GPIOR_15 | input | verified | button 1 |
| `btn2` | GPIOR_16 | input | verified | button 2 |
| `led1` | GPIOL_13 | output | verified | LED 1 (active low) |
| `led2` | GPIOL_14 | output | verified | LED 2 (active low) |

## Hardware test

Loaded on a Zen 4 and checked against the behaviour described above: it works as designed.

## Simulate

```
bash sim/run-sim.sh
```

Needs Icarus Verilog (`iverilog`, `vvp`). The script fails unless the testbench prints `ALL PASS`.

## Build and load

1. Open `button-debouncer.xml` in Efinity (Trion T4F81).
2. Open Interface Designer and check the PLL and pad assignments against the table above (this is the pad table used for the hardware test).
3. Run synthesis, place and route, then generate the bitstream and program the Zen 4.

5. Load without the Efinity programmer: copy `bitstream/button-debouncer.hex.bin` to the board and configure the FPGA with the board loader (`main.py` must already be on the board):

```
python -m mpremote cp bitstream/button-debouncer.hex.bin :
python -m mpremote exec "import main as m; m.FILE_NAME='button-debouncer.hex.bin'; m.configure()"
```

The last command prints `CDONE = 1` when the FPGA is configured.

## Notes and differences from the Shrike example

- The steady time is `DEBOUNCE_CNT_LIMIT` clocks (500 000 = 10 ms at 50 MHz); the testbench uses a smaller value to keep the run short.

## License

GPL-2.0, like the Shrike repository this is ported from.
