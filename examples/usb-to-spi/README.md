# usb-to-spi

The RP2350 sends bytes through the Zen Link byte port; each one goes out as an SPI transfer (master, mode 0, about 390 kHz) on four header pads, and the reply of the previous transfer comes back with the next byte. LED 1 shows bit 0 of the last byte sent. Header pad numbers other than R-05 and R-06 are placeholders. The RP2350 reaches the design through the Zen Link (D0..D7, CLK, CS_N) with the zen_spi.py byte port. btn1 resets the design, and so does fpga.write(0x10, 1) (ZenSPI.reset()). Fabric clock: 50 MHz (PLL x16 / 16), required by the Zen Link synchronisers.

**Board:** Vicharak Zen 4 (Efinix Trion T4F81 + RP2350). **Ported from:** the Vicharak Shrike example `examples/usb_to_spi` (GPL-2.0).

## Status

| Check | Result |
| --- | --- |
| Simulation (Icarus Verilog, self-checking) | passes, prints `ALL PASS` |
| Efinity project, pad assignment, timing | builds in Efinity for the T4F81 |
| On hardware | **tested on a Zen 4 without extra hardware (jumpers or an internal loop, see "Hardware test")** |

## Layout

- `rtl/` `spi-master.v`, `spi-target.v`, `usb-to-spi-zen4-top.v`, `usb-to-spi.v`, `zl-byte-port.v`, `zink/zen-link.v`, `zink/zl-regs.v`, `zink/zl-slave.v`
- `sim/` `run-sim.sh`, `tb-usb-to-spi.v`
- `firmware/RP2350/` `host.py`, `loopback-test.py`, `usb-to-spi.py`, `zen_spi.py`
- Efinity: `usb-to-spi.peri.xml`, `usb-to-spi.xml`, and `sdc/` (`usb-to-spi.sdc`)
- `bitstream/` `usb-to-spi.hex.bin` (built in Efinity, loads with the board loader)

## Clock

clk: 50 MHz (50 MHz oscillator on GPIOL_20 into the Efinity PLL).

## Pins

Set in `usb-to-spi.peri.xml`. Pads marked verified were used in the hardware tests (clock, buttons, LEDs, the RP2350 link pads and header pads R-05 / R-06). Pads marked placeholder are not verified against the Zen schematic: check them before wiring anything.

| Signal | FPGA pad | Mode | Status | Notes |
| --- | --- | --- | --- | --- |
| `clock input (to PLL)` | GPIOL_20 | input | verified | clock oscillator |
| `btn1` | GPIOR_15 | input | verified | button 1 |
| `m_ss_n` | GPIOR_00 | output | placeholder | header pad, left unconnected |
| `m_sck` | GPIOR_01 | output | placeholder | header pad, left unconnected |
| `m_mosi` | GPIOR_05 | output | verified | header pad R-05: jumper to R-06 |
| `m_miso` | GPIOR_06 | input | verified | header pad R-06: jumper to R-05 |
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

SPI loopback with a jumper wire from MOSI (R-05) to MISO (R-06). `firmware/RP2350/loopback-test.py` sends a byte sequence through the Zen Link and checks that every reply equals the previous byte sent. SCK and SS were not probed.

## Simulate

```
bash sim/run-sim.sh
```

Needs Icarus Verilog (`iverilog`, `vvp`). The script fails unless the testbench prints `ALL PASS`.

## Build and load

1. Open `usb-to-spi.xml` in Efinity (Trion T4F81).
2. Open Interface Designer and check the PLL and pad assignments against the table above (this is the pad table used for the hardware test).
3. Run synthesis, place and route, then generate the bitstream and program the Zen 4.
4. Copy the files in `firmware/RP2350/*.py` to the RP2350 (MicroPython) and run the main script (`host.py`, `loopback-test.py`, `usb-to-spi.py`, `zen_spi.py`).

5. Load without the Efinity programmer: copy `bitstream/usb-to-spi.hex.bin` to the board and configure the FPGA with the board loader (`main.py` must already be on the board):

```
python -m mpremote cp bitstream/usb-to-spi.hex.bin :
python -m mpremote exec "import main as m; m.FILE_NAME='usb-to-spi.hex.bin'; m.configure()"
```

The last command prints `CDONE = 1` when the FPGA is configured.

## Notes and differences from the Shrike example

- The SPI clock period is 2560 ns (about 390 kHz).

## License

GPL-2.0, like the Shrike repository this is ported from.
