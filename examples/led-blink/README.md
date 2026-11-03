# led-blink

Blinks LED 1 once per second. Fabric clock is 50 MHz (50 MHz oscillator on GPIOL_20 through the PLL, x16 / 16, set up in Efinity Interface Designer).

**Board:** Vicharak Zen 4 (Efinix Trion T4F81 + RP2350). **Ported from:** the Vicharak Shrike example `examples/led_blink` (GPL-2.0).

## Status

| Check | Result |
| --- | --- |
| Simulation (Icarus Verilog, self-checking) | passes, prints `ALL PASS` |
| Efinity project, pad assignment, timing | builds in Efinity for the T4F81 |
| On hardware | **tested on a Zen 4, works as designed** |

## Layout

- `rtl/` `led-blink-zen4-top.v`, `led-blink.v`
- `sim/` `run-sim.sh`, `tb-led-blink.v`
- Efinity: `led-blink.peri.xml`, `led-blink.xml`, and `sdc/` (`led-blink.sdc`)
- `bitstream/` `led-blink.hex.bin` (built in Efinity, loads with the board loader)

## Clock

clk: 50 MHz (50 MHz oscillator on GPIOL_20 into the Efinity PLL).

## Pins

Set in `led-blink.peri.xml`. Pads marked verified were used in the hardware tests (clock, buttons, LEDs, the RP2350 link pads and header pads R-05 / R-06). Pads marked placeholder are not verified against the Zen schematic: check them before wiring anything.

| Signal | FPGA pad | Mode | Status | Notes |
| --- | --- | --- | --- | --- |
| `clock input (to PLL)` | GPIOL_20 | input | verified | clock oscillator |
| `led1` | GPIOL_13 | output | verified | LED 1 (active low) |

## Hardware test

Loaded on a Zen 4 and checked against the behaviour described above: it works as designed.

## Simulate

```
bash sim/run-sim.sh
```

Needs Icarus Verilog (`iverilog`, `vvp`). The script fails unless the testbench prints `ALL PASS`.

## Build and load

1. Open `led-blink.xml` in Efinity (Trion T4F81).
2. Open Interface Designer and check the PLL and pad assignments against the table above (this is the pad table used for the hardware test).
3. Run synthesis, place and route, then generate the bitstream and program the Zen 4.

5. Load without the Efinity programmer: copy `bitstream/led-blink.hex.bin` to the board and configure the FPGA with the board loader (`main.py` must already be on the board):

```
python -m mpremote cp bitstream/led-blink.hex.bin :
python -m mpremote exec "import main as m; m.FILE_NAME='led-blink.hex.bin'; m.configure()"
```

The last command prints `CDONE = 1` when the FPGA is configured.

## Notes and differences from the Shrike example

- The blink interval is a parameter (`HALF_CLKS`), 50 000 000 clocks = 1 s at 50 MHz.

## License

GPL-2.0, like the Shrike repository this is ported from.
