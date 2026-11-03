# i2c-to-spi-bridge

Board top for the I2C -> SPI bridge on the Vicharak Zen 4 (Trion T4F81). The FPGA is an I2C slave at 0x32 (100 kHz; SDA is open-drain and needs an external pull-up) and an SPI master (mode 0, 1 MHz) on header pads. Each byte written over I2C is sent on SPI; the byte received on MISO during it is what the next I2C read returns (0xFF until a transfer has completed). LED 1 blinks on every I2C byte received.

**Board:** Vicharak Zen 4 (Efinix Trion T4F81 + RP2350). **Ported from:** the Vicharak Shrike example `examples/protocol_translator/i2c_to_spi_bridge` (GPL-2.0).

## Status

| Check | Result |
| --- | --- |
| Simulation (Icarus Verilog, self-checking) | passes, prints `ALL PASS` |
| Efinity project, pad assignment, timing | builds in Efinity for the T4F81 |
| On hardware | **tested on a Zen 4 without extra hardware (jumpers or an internal loop, see "Hardware test")** |

## Layout

- `rtl/` `bridge-controller-sync-fifo.v`, `fifo-8x8.v`, `i2c-slave.v`, `i2c-to-spi-bridge-zen4-top.v`, `i2c-to-spi-bridge.v`, `spi-master.v`
- `sim/` `run-sim.sh`, `tb-i2c-to-spi-bridge.v`
- `firmware/RP2350/` `i2c-to-spi-bridge.py`
- Efinity: `i2c-to-spi-bridge.peri.xml`, `i2c-to-spi-bridge.xml`, and `sdc/` (`i2c-to-spi-bridge.sdc`)
- `bitstream/` `i2c-to-spi-bridge.hex.bin` (built in Efinity, loads with the board loader)

## Clock

clk: 50 MHz (50 MHz oscillator on GPIOL_20 into the Efinity PLL).

## Pins

Set in `i2c-to-spi-bridge.peri.xml`. Pads marked verified were used in the hardware tests (clock, buttons, LEDs, the RP2350 link pads and header pads R-05 / R-06). Pads marked placeholder are not verified against the Zen schematic: check them before wiring anything.

| Signal | FPGA pad | Mode | Status | Notes |
| --- | --- | --- | --- | --- |
| `clock input (to PLL)` | GPIOL_20 | input | verified | clock oscillator |
| `sda` | GPIOL_04 | inout | verified | RP2350 GPIO0 (no wire) |
| `scl` | GPIOL_02 | input | verified | RP2350 GPIO1 (no wire) |
| `spi_sclk` | GPIOR_00 | output | placeholder | header pad, left unconnected |
| `spi_ss` | GPIOR_01 | output | placeholder | header pad, left unconnected |
| `spi_mosi` | GPIOR_05 | output | verified | header pad R-05 |
| `spi_miso` | GPIOR_06 | input | verified | header pad R-06 |
| `led1` | GPIOL_13 | output | verified | LED 1 (active low) |

## Hardware test

The RP2350 is the I2C master with SoftI2C on GPIO0 / GPIO1 (link wires). On the SPI side a jumper wire from MOSI (R-05) to MISO (R-06) loops the byte back, so the byte written over I2C comes back on the next I2C read.

## Simulate

```
bash sim/run-sim.sh
```

Needs Icarus Verilog (`iverilog`, `vvp`). The script fails unless the testbench prints `ALL PASS`.

## Build and load

1. Open `i2c-to-spi-bridge.xml` in Efinity (Trion T4F81).
2. Open Interface Designer and check the PLL and pad assignments against the table above (this is the pad table used for the hardware test).
3. Run synthesis, place and route, then generate the bitstream and program the Zen 4.
4. Copy the files in `firmware/RP2350/*.py` to the RP2350 (MicroPython) and run the main script (`i2c-to-spi-bridge.py`).

5. Load without the Efinity programmer: copy `bitstream/i2c-to-spi-bridge.hex.bin` to the board and configure the FPGA with the board loader (`main.py` must already be on the board):

```
python -m mpremote cp bitstream/i2c-to-spi-bridge.hex.bin :
python -m mpremote exec "import main as m; m.FILE_NAME='i2c-to-spi-bridge.hex.bin'; m.configure()"
```

The last command prints `CDONE = 1` when the FPGA is configured.

## Notes and differences from the Shrike example

- I2C slave address 0x32. A byte written over I2C goes out on SPI (mode 0, 1 MHz); the byte received on MISO is what the next I2C read returns (0xFF until a transfer has finished).
- The original uses `SPI_CLK_DIV` without declaring it; it is now a `localparam` of 25 (1 MHz).
- SDA is an open-drain pad: add an external pull-up resistor to 3.3 V.

## License

GPL-2.0, like the Shrike repository this is ported from.
