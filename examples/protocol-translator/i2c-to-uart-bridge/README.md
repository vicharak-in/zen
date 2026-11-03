# i2c-to-uart-bridge

Board top for the I2C <-> UART bridge on the Vicharak Zen 4 (Trion T4F81). The FPGA is an I2C slave at 0x50 (100 kHz, SDA open-drain, needs external pull-ups) and a full-duplex UART (115200 8N1) on the pads wired to the RP2350 UART1 (GPIO24 / GPIO25). A byte written over I2C goes out on the UART; the last byte received on the UART is what the next I2C read returns.

**Board:** Vicharak Zen 4 (Efinix Trion T4F81 + RP2350). **Ported from:** the Vicharak Shrike example `examples/protocol_translator/i2c_to_uart_bridge` (GPL-2.0).

## Status

| Check | Result |
| --- | --- |
| Simulation (Icarus Verilog, self-checking) | passes, prints `ALL PASS` |
| Efinity project, pad assignment, timing | builds in Efinity for the T4F81 |
| On hardware | **tested on a Zen 4 without extra hardware (jumpers or an internal loop, see "Hardware test")** |

## Layout

- `rtl/` `i2c-slave-core.v`, `i2c-to-uart-bridge-zen4-top.v`, `i2c-to-uart-bridge.v`, `sync-fifo.v`, `uart-rx.v`, `uart-tx.v`
- `sim/` `run-sim.sh`, `tb-i2c-to-uart-bridge.v`
- `firmware/RP2350/` `i2c-to-uart.py`
- Efinity: `i2c-to-uart-bridge.peri.xml`, `i2c-to-uart-bridge.xml`, and `sdc/` (`i2c-to-uart-bridge.sdc`)
- `bitstream/` `i2c-to-uart-bridge.hex.bin` (built in Efinity, loads with the board loader)

## Clock

clk: 50 MHz (50 MHz oscillator on GPIOL_20 into the Efinity PLL).

## Pins

Set in `i2c-to-uart-bridge.peri.xml`. Pads marked verified were used in the hardware tests (clock, buttons, LEDs, the RP2350 link pads and header pads R-05 / R-06). Pads marked placeholder are not verified against the Zen schematic: check them before wiring anything.

| Signal | FPGA pad | Mode | Status | Notes |
| --- | --- | --- | --- | --- |
| `clock input (to PLL)` | GPIOL_20 | input | verified | clock oscillator |
| `uart_rx` | GPIOL_00 | input | verified | RP2350 GPIO24 |
| `uart_tx` | GPIOL_03 | output | verified | RP2350 GPIO25 |
| `sda` | GPIOL_04 | inout | verified | RP2350 GPIO0 (no wire) |
| `scl` | GPIOL_02 | input | verified | RP2350 GPIO1 (no wire) |

## Hardware test

No external I2C master was used. The RP2350 acts as the I2C master with SoftI2C on GPIO0 / GPIO1 (Zen link wires to the FPGA SCL / SDA pads), and the UART is on GPIO24 / GPIO25. Both directions passed.

## Simulate

```
bash sim/run-sim.sh
```

Needs Icarus Verilog (`iverilog`, `vvp`). The script fails unless the testbench prints `ALL PASS`.

## Build and load

1. Open `i2c-to-uart-bridge.xml` in Efinity (Trion T4F81).
2. Open Interface Designer and check the PLL and pad assignments against the table above (this is the pad table used for the hardware test).
3. Run synthesis, place and route, then generate the bitstream and program the Zen 4.
4. Copy the files in `firmware/RP2350/*.py` to the RP2350 (MicroPython) and run the main script (`i2c-to-uart.py`).

5. Load without the Efinity programmer: copy `bitstream/i2c-to-uart-bridge.hex.bin` to the board and configure the FPGA with the board loader (`main.py` must already be on the board):

```
python -m mpremote cp bitstream/i2c-to-uart-bridge.hex.bin :
python -m mpremote exec "import main as m; m.FILE_NAME='i2c-to-uart-bridge.hex.bin'; m.configure()"
```

The last command prints `CDONE = 1` when the FPGA is configured.

## Notes and differences from the Shrike example

- I2C slave address 0x50. A byte written over I2C goes out on the UART; the last byte received on the UART is what the next I2C read returns.
- SDA is an open-drain pad: add an external pull-up resistor to 3.3 V.

## License

GPL-2.0, like the Shrike repository this is ported from.
