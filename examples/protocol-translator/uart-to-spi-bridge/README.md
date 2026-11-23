# uart-to-spi-bridge

Board top for the UART <-> SPI bridge on the Vicharak Zen 4 (Trion T4F81). The UART is on the pads wired to the RP2350 UART1 (GPIO24 / GPIO25); the SPI master (1 MHz, mode 0) is on header pads. Each UART byte becomes one SPI byte and the SPI reply comes back on the UART. Test setup in the original: jumper MOSI to MISO so the bridge echoes every byte. btn1 = reset (hold).

**Board:** Vicharak Zen 4 (Efinix Trion T4F81 + RP2350). **Ported from:** the Vicharak Shrike example `examples/protocol_translator/uart_to_spi_bridge` (GPL-2.0).

## Status

| Check | Result |
| --- | --- |
| Simulation (Icarus Verilog, self-checking) | passes, prints `ALL PASS` |
| Efinity project, pad assignment, timing | builds in Efinity for the T4F81 |
| On hardware | **tested on a Zen 4 without extra hardware (jumpers or an internal loop, see "Hardware test")** |

## Layout

- `rtl/` `bridge-controller.v`, `fifo-8x8.v`, `spi-master.v`, `uart-rx.v`, `uart-to-spi-bridge-zen4-top.v`, `uart-to-spi-bridge.v`, `uart-tx-handler.v`, `uart-tx.v`
- `sim/` `run-sim.sh`, `tb-uart-to-spi-bridge.v`
- `firmware/RP2350/` `uart-to-spi-bridge.py`
- Efinity: `uart-to-spi-bridge.peri.xml`, `uart-to-spi-bridge.xml`, and `sdc/` (`uart-to-spi-bridge.sdc`)
- `bitstream/` `uart-to-spi-bridge.hex.bin` (built in Efinity, loads with the board loader)

## Clock

clk: 50 MHz (50 MHz oscillator on GPIOL_20 into the Efinity PLL).

## Pins

Set in `uart-to-spi-bridge.peri.xml`. Pads marked verified were used in the hardware tests (clock, buttons, LEDs, the RP2350 link pads and header pads R-05 / R-06). Pads marked placeholder are not verified against the Zen schematic: check them before wiring anything.

| Signal | FPGA pad | Mode | Status | Notes |
| --- | --- | --- | --- | --- |
| `clock input (to PLL)` | GPIOL_20 | input | verified | clock oscillator |
| `btn1` | GPIOR_15 | input | verified | button 1 |
| `rx` | GPIOL_00 | input | verified | RP2350 GPIO24 |
| `tx` | GPIOL_03 | output | verified | RP2350 GPIO25 |
| `sclk` | GPIOR_00 | output | placeholder | header pad, left unconnected |
| `cs` | GPIOR_01 | output | placeholder | header pad, left unconnected |
| `mosi` | GPIOR_05 | output | verified | header pad R-05: jumper to R-06 |
| `miso` | GPIOR_06 | input | verified | header pad R-06: jumper to R-05 |

## Hardware test

UART from the RP2350 (GPIO24 / GPIO25, link wires). A jumper wire from MOSI (R-05) to MISO (R-06) loops the SPI byte back, and it returns on the UART.

## Simulate

```
bash sim/run-sim.sh
```

Needs Icarus Verilog (`iverilog`, `vvp`). The script fails unless the testbench prints `ALL PASS`.

## Build and load

1. Open `uart-to-spi-bridge.xml` in Efinity (Trion T4F81).
2. Open Interface Designer and check the PLL and pad assignments against the table above (this is the pad table used for the hardware test).
3. Run synthesis, place and route, then generate the bitstream and program the Zen 4.
4. Copy the files in `firmware/RP2350/*.py` to the RP2350 (MicroPython) and run the main script (`uart-to-spi-bridge.py`).

5. Load without the Efinity programmer: copy `bitstream/uart-to-spi-bridge.hex.bin` to the board and configure the FPGA with the board loader (`main.py` must already be on the board):

```
python -m mpremote cp bitstream/uart-to-spi-bridge.hex.bin :
python -m mpremote exec "import main as m; m.FILE_NAME='uart-to-spi-bridge.hex.bin'; m.configure()"
```

The last command prints `CDONE = 1` when the FPGA is configured.

## Notes and differences from the Shrike example

- Test setup in the original: jumper MOSI to MISO so the bridge echoes each byte. Reset is button 1.

## License

GPL-2.0, like the Shrike repository this is ported from.
