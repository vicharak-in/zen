# ultrasonic-sensor

One HC-SR04 on three header pads, LED 1 lights when an object is in range. The HC-SR04 runs on 5 V: use a level shifter (or divider) on echo, the header pads are 3.3 V only. Fabric clock is 50 MHz (PLL x16 / 16).

**Board:** Vicharak Zen 4 (Efinix Trion T4F81 + RP2350). **Ported from:** the Vicharak Shrike example `examples/ultrasonic_sensor` (GPL-2.0).

Original ultrasonic-sensor logic: Copyright Vicharak.

## Status

| Check | Result |
| --- | --- |
| Simulation (Icarus Verilog, self-checking) | passes, prints `ALL PASS` |
| Efinity project, pad assignment, timing | builds in Efinity for the T4F81 |
| On hardware | **tested on a Zen 4 without extra hardware (jumpers or an internal loop, see "Hardware test")** |

## Layout

- `rtl/` `ultrasonic-sensor-zen4-top.v`, `ultrasonic-sensor.v`, `ultrasonic-sensors.v`
- `sim/` `run-sim.sh`, `tb-ultrasonic-sensor.v`
- Efinity: `ultrasonic-sensor.peri.xml`, `ultrasonic-sensor.xml`, and `sdc/` (`ultrasonic-sensor.sdc`)
- `bitstream/` `ultrasonic-sensor.hex.bin` (built in Efinity, loads with the board loader)

## Clock

clk: 50 MHz (50 MHz oscillator on GPIOL_20 into the Efinity PLL).

## Pins

Set in `ultrasonic-sensor.peri.xml`. Pads marked verified were used in the hardware tests (clock, buttons, LEDs, the RP2350 link pads and header pads R-05 / R-06). Pads marked placeholder are not verified against the Zen schematic: check them before wiring anything.

| Signal | FPGA pad | Mode | Status | Notes |
| --- | --- | --- | --- | --- |
| `clock input (to PLL)` | GPIOL_20 | input | verified | clock oscillator |
| `echo` | GPIOR_06 | input | verified | header pad R-06 (loopback test: jumper to R-05) |
| `trig` | GPIOR_05 | output | verified | header pad R-05 (loopback test: jumper to R-06) |
| `object_detected` | GPIOR_00 | output | placeholder | header pad, not needed for the test (LED 1 shows it) |
| `led1` | GPIOL_13 | output | verified | LED 1 (active low) |

## Hardware test

No HC-SR04 was used. A jumper wire from trig (R-05) to echo (R-06) makes the echo input go high, which latches the object-detected LED (the design keeps the last detection). Distance values were not measured.

## Simulate

```
bash sim/run-sim.sh
```

Needs Icarus Verilog (`iverilog`, `vvp`). The script fails unless the testbench prints `ALL PASS`.

## Build and load

1. Open `ultrasonic-sensor.xml` in Efinity (Trion T4F81).
2. Open Interface Designer and check the PLL and pad assignments against the table above (this is the pad table used for the hardware test).
3. Run synthesis, place and route, then generate the bitstream and program the Zen 4.

5. Load without the Efinity programmer: copy `bitstream/ultrasonic-sensor.hex.bin` to the board and configure the FPGA with the board loader (`main.py` must already be on the board):

```
python -m mpremote cp bitstream/ultrasonic-sensor.hex.bin :
python -m mpremote exec "import main as m; m.FILE_NAME='ultrasonic-sensor.hex.bin'; m.configure()"
```

The last command prints `CDONE = 1` when the FPGA is configured.

## Notes and differences from the Shrike example

- The HC-SR04 runs on 5 V. Power it from 5 V and put a level shifter (or a resistor divider) on the echo line; the header pads are 3.3 V only.

## License

GPL-2.0, like the Shrike repository this is ported from.
