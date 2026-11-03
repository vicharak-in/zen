# dspi-pio-echo

A Dual-SPI echo target on the RP2350 link wires. Pads (all verified from the Zen Link pin set): spi_sck = GPIOL_09 (RP2350 GPIO28), spi_ss = GPIOL_10 (RP2350 GPIO29, bidirectional: the FPGA pulls it low to raise the alert), dual[0] = GPIOL_00 (RP2350 GPIO24), dual[1] = GPIOL_03 (RP2350 GPIO25). GPIO24/25 are contiguous, which the RP2350 PIO needs for its two data lines. Fabric clock 50 MHz (PLL x16 / 16). btn1 resets. LED 1 is the heartbeat (active low).

**Board:** Vicharak Zen 4 (Efinix Trion T4F81 + RP2350). **Ported from:** the Vicharak Shrike example `examples/dspi_pio_echo` (GPL-2.0).

The PIO firmware idea is from the Shrike example.

## Status

| Check | Result |
| --- | --- |
| Simulation (Icarus Verilog, self-checking) | passes, prints `ALL PASS` |
| Efinity project, pad assignment, timing | builds in Efinity for the T4F81 |
| On hardware | **tested on a Zen 4, works as designed** |

## Layout

- `rtl/` `dspi-pio-echo-zen4-top.v`, `dspi-pio-echo.v`, `dual-spi-target.v`
- `sim/` `run-sim.sh`, `tb-dspi-pio-echo.v`
- `firmware/RP2350/` `dspi-pio-echo.py`, `dspi_bus.py`, `main.py`
- Efinity: `dspi-pio-echo.peri.xml`, `dspi-pio-echo.xml`, and `sdc/` (`dspi-pio-echo.sdc`)
- `bitstream/` `dspi-pio-echo.hex.bin` (built in Efinity, loads with the board loader)

## Clock

clk: 50 MHz (50 MHz oscillator on GPIOL_20 into the Efinity PLL).

## Pins

Set in `dspi-pio-echo.peri.xml`. Pads marked verified were used in the hardware tests (clock, buttons, LEDs, the RP2350 link pads and header pads R-05 / R-06). Pads marked placeholder are not verified against the Zen schematic: check them before wiring anything.

| Signal | FPGA pad | Mode | Status | Notes |
| --- | --- | --- | --- | --- |
| `clock input (to PLL)` | GPIOL_20 | input | verified | clock oscillator |
| `btn1` | GPIOR_15 | input | verified | button 1 |
| `spi_sck` | GPIOL_09 | input | verified | RP2350 GPIO28 |
| `spi_ss` | GPIOL_10 | inout | verified | RP2350 GPIO29 |
| `dual[0]` | GPIOL_00 | inout | verified | RP2350 GPIO24 |
| `dual[1]` | GPIOL_03 | inout | verified | RP2350 GPIO25 |
| `led1` | GPIOL_13 | output | verified | LED 1 (active low) |

## Hardware test

Loaded on a Zen 4 and checked against the behaviour described above: it works as designed.

## Simulate

```
bash sim/run-sim.sh
```

Needs Icarus Verilog (`iverilog`, `vvp`). The script fails unless the testbench prints `ALL PASS`.

## Build and load

1. Open `dspi-pio-echo.xml` in Efinity (Trion T4F81).
2. Open Interface Designer and check the PLL and pad assignments against the table above (this is the pad table used for the hardware test).
3. Run synthesis, place and route, then generate the bitstream and program the Zen 4.
4. Copy the files in `firmware/RP2350/*.py` to the RP2350 (MicroPython) and run the main script (`dspi_bus.py`, `dspi-pio-echo.py`, `main.py`).

5. Load without the Efinity programmer: copy `bitstream/dspi-pio-echo.hex.bin` to the board and configure the FPGA with the board loader (`main.py` must already be on the board):

```
python -m mpremote cp bitstream/dspi-pio-echo.hex.bin :
python -m mpremote exec "import main as m; m.FILE_NAME='dspi-pio-echo.hex.bin'; m.configure()"
```

The last command prints `CDONE = 1` when the FPGA is configured.

## Notes and differences from the Shrike example

- The Dual-SPI target shares the link pads (CS = GPIOL_10, SCK = GPIOL_09, IO = GPIOL_00 / GPIOL_03), so the Zen Link is not used here.
- Inherited quirk: when an alert is pending, the reply to the `?` command is `0x3f` (the echoed byte) rather than `0xFF`.
- An alert-clear term got a 2-flop synchroniser on SCK.

## License

GPL-2.0, like the Shrike repository this is ported from.
