# spi-to-uart-bridge

Board top for the SPI <-> UART bridge on the Vicharak Zen 4 (Trion T4F81). SPI slave (mode 0) and UART (115200 8N1) both face the outside world: the SPI pins are on header pads, the UART is on the pads wired to the RP2350 UART1 (GPIO24 / GPIO25). Fabric clock: 50 MHz from the Efinity PLL. LED 1 lights while the bridge can accept more data (fpga_ready).

**Board:** Vicharak Zen 4 (Efinix Trion T4F81 + RP2350). **Ported from:** the Vicharak Shrike example `examples/protocol_translator/spi_to_uart_bridge` (GPL-2.0).

## Status

| Check | Result |
| --- | --- |
| Simulation (Icarus Verilog, self-checking) | passes, prints `ALL PASS` |
| Efinity project, pad assignment, timing | builds in Efinity for the T4F81 |
| On hardware | **tested on a Zen 4 without extra hardware (jumpers or an internal loop, see "Hardware test")** |

## Layout

- `rtl/` `fifo-8x8.v`, `spi-slave.v`, `spi-to-uart-bridge-zen4-top.v`, `spi-to-uart-bridge.v`, `uart-rx.v`, `uart-tx.v`
- `sim/` `run-sim.sh`, `tb-spi-to-uart-bridge.v`
- `firmware/RP2350/` `spi-to-uart-bridge.py`
- Efinity: `spi-to-uart-bridge.peri.xml`, `spi-to-uart-bridge.xml`, and `sdc/` (`spi-to-uart-bridge.sdc`)
- `bitstream/` `spi-to-uart-bridge.hex.bin` (built in Efinity, loads with the board loader)

## Clock

clk: 50 MHz (50 MHz oscillator on GPIOL_20 into the Efinity PLL).

## Pins

Set in `spi-to-uart-bridge.peri.xml`. Pads marked verified were used in the hardware tests (clock, buttons, LEDs, the RP2350 link pads and header pads R-05 / R-06). Pads marked placeholder are not verified against the Zen schematic: check them before wiring anything.

| Signal | FPGA pad | Mode | Status | Notes |
| --- | --- | --- | --- | --- |
| `clock input (to PLL)` | GPIOL_20 | input | verified | clock oscillator |
| `spi_sck` | GPIOL_01 | input | verified | RP2350 GPIO2 (no wire) |
| `spi_cs` | GPIOL_02 | input | verified | RP2350 GPIO1 (no wire) |
| `spi_mosi` | GPIOL_06 | input | verified | RP2350 GPIO3 (no wire) |
| `spi_miso` | GPIOL_04 | output | verified | RP2350 GPIO0 (no wire) |
| `uart_rx` | GPIOL_00 | input | verified | RP2350 GPIO24 |
| `uart_tx` | GPIOL_03 | output | verified | RP2350 GPIO25 |
| `fpga_ready` | GPIOR_05 | output | verified | header pad R-05 |
| `led1` | GPIOL_13 | output | verified | LED 1 (active low) |

## Hardware test

Both sides run over the Zen link wires (SPI on GPIO2 / GPIO3 / GPIO0 / GPIO1, UART on GPIO24 / GPIO25), so no jumpers were needed. Bytes sent over SPI came out on the UART and the reverse.

## Simulate

```
bash sim/run-sim.sh
```

Needs Icarus Verilog (`iverilog`, `vvp`). The script fails unless the testbench prints `ALL PASS`.

## Build and load

1. Open `spi-to-uart-bridge.xml` in Efinity (Trion T4F81).
2. Open Interface Designer and check the PLL and pad assignments against the table above (this is the pad table used for the hardware test).
3. Run synthesis, place and route, then generate the bitstream and program the Zen 4.
4. Copy the files in `firmware/RP2350/*.py` to the RP2350 (MicroPython) and run the main script (`spi-to-uart-bridge.py`).

5. Load without the Efinity programmer: copy `bitstream/spi-to-uart-bridge.hex.bin` to the board and configure the FPGA with the board loader (`main.py` must already be on the board):

```
python -m mpremote cp bitstream/spi-to-uart-bridge.hex.bin :
python -m mpremote exec "import main as m; m.FILE_NAME='spi-to-uart-bridge.hex.bin'; m.configure()"
```

The last command prints `CDONE = 1` when the FPGA is configured.

## Notes and differences from the Shrike example

- The original ties every reset low and relies on the Renesas fabric clearing the registers at configuration; a 16-clock power-on reset was added so the FIFOs start empty on any fabric and in simulation.
- The original assigns `fpga_ready` before `fifo_count` is declared; the assignment was moved below the declaration.
- Inherited behaviour: every SPI byte is sent to the UART twice (a direct path and the FIFO path), and the dummy SPI read bytes are forwarded too. The board script flushes its UART buffer for this reason.

## License

GPL-2.0, like the Shrike repository this is ported from.
