# spi-to-usb

External SPI (an Arduino Uno master) on four header pads; the RP2350 reads the last byte it sent through the Zen Link byte port. LED 1 shows bit 0 of that byte. The Uno is a 5 V device: put resistor dividers (or a level shifter) on ext_sck, ext_mosi and ext_ss_n. Header pad numbers other than R-05 and R-06 are placeholders. The RP2350 reaches the design through the Zen Link (D0..D7, CLK, CS_N) with the zen_spi.py byte port. btn1 resets the design, and so does fpga.write(0x10, 1) (ZenSPI.reset()). Fabric clock: 50 MHz (PLL x16 / 16), required by the Zen Link synchronisers.

**Board:** Vicharak Zen 4 (Efinix Trion T4F81 + RP2350). **Ported from:** the Vicharak Shrike example `examples/spi_to_usb` (GPL-2.0).

## Status

| Check | Result |
| --- | --- |
| Simulation (Icarus Verilog, self-checking) | passes, prints `ALL PASS` |
| Efinity project, pad assignment, timing | builds in Efinity for the T4F81 |
| On hardware | **tested on a Zen 4 without extra hardware (jumpers or an internal loop, see "Hardware test")** |

## Layout

- `rtl/` `spi-target.v`, `spi-to-usb-zen4-top.v`, `spi-to-usb.v`, `zl-byte-port.v`, `zink/zen-link.v`, `zink/zl-regs.v`, `zink/zl-slave.v`
- `sim/` `run-sim.sh`, `tb-spi-to-usb.v`
- `firmware/RP2350/` `spi-to-usb.py`, `zen_spi.py`
- Efinity: `spi-to-usb.peri.xml`, `spi-to-usb.xml`, and `sdc/` (`spi-to-usb.sdc`)
- `bitstream/` `spi-to-usb.hex.bin` (built in Efinity, loads with the board loader)

## Clock

clk: 50 MHz (50 MHz oscillator on GPIOL_20 into the Efinity PLL).

## Pins

Set in `spi-to-usb.peri.xml`. Pads marked verified were used in the hardware tests (clock, buttons, LEDs, the RP2350 link pads and header pads R-05 / R-06). Pads marked placeholder are not verified against the Zen schematic: check them before wiring anything.

| Signal | FPGA pad | Mode | Status | Notes |
| --- | --- | --- | --- | --- |
| `clock input (to PLL)` | GPIOL_20 | input | verified | clock oscillator |
| `btn1` | GPIOR_15 | input | verified | button 1 |
| `ext_ss_n` | GPIOR_00 | input | placeholder | header pad, number not verified |
| `ext_sck` | GPIOR_01 | input | placeholder | header pad, number not verified |
| `ext_mosi` | GPIOR_02 | input | placeholder | header pad, number not verified |
| `ext_miso` | GPIOR_03 | inout | placeholder | header pad, number not verified |
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

The design needs an external SPI master (an Arduino), which was not used. It was tested on a Zen 4 with a temporary build that put an SPI master inside the FPGA in front of the core; the RP2350 read back the expected counting sequence. That test build is not part of this project.

## Simulate

```
bash sim/run-sim.sh
```

Needs Icarus Verilog (`iverilog`, `vvp`). The script fails unless the testbench prints `ALL PASS`.

## Build and load

1. Open `spi-to-usb.xml` in Efinity (Trion T4F81).
2. Open Interface Designer and check the PLL and pad assignments against the table above (this is the pad table used for the hardware test).
3. Run synthesis, place and route, then generate the bitstream and program the Zen 4.
4. Copy the files in `firmware/RP2350/*.py` to the RP2350 (MicroPython) and run the main script (`spi-to-usb.py`, `zen_spi.py`).

5. Load without the Efinity programmer: copy `bitstream/spi-to-usb.hex.bin` to the board and configure the FPGA with the board loader (`main.py` must already be on the board):

```
python -m mpremote cp bitstream/spi-to-usb.hex.bin :
python -m mpremote exec "import main as m; m.FILE_NAME='spi-to-usb.hex.bin'; m.configure()"
```

The last command prints `CDONE = 1` when the FPGA is configured.

## Notes and differences from the Shrike example

- An external Arduino Uno is a 5 V device: use dividers or a level shifter on SCK, MOSI and SS.
- The shipped original `spi_target` had a mismatched parameter; the working copy from the `usb-to-spi` example is used.

## License

GPL-2.0, like the Shrike repository this is ported from.
