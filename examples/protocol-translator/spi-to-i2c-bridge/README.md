# spi-to-i2c-bridge

Board top for the SPI -> I2C bridge on the Vicharak Zen 4 (Trion T4F81). The FPGA is an SPI slave (host = RP2350 or any SPI master, mode 0) and the I2C master of a sensor at TARGET_SLAVE_ADDR (0x50 in the core). Each SPI command byte is written to the sensor, then one byte is read back and placed in the SPI transmit buffer (read it with a second, dummy SPI transaction). I2C is 100 kHz; SDA and SCL are open-drain pads and need external pull-up resistors.

**Board:** Vicharak Zen 4 (Efinix Trion T4F81 + RP2350). **Ported from:** the Vicharak Shrike example `examples/protocol_translator/spi_to_i2c_bridge` (GPL-2.0).

## Status

| Check | Result |
| --- | --- |
| Simulation (Icarus Verilog, self-checking) | passes, prints `ALL PASS` |
| Efinity project, pad assignment, timing | built in Efinity 2026.1 for the T4F81: 229 / 3,888 logic elements (6%), 176 LUT4, 126 flip-flops; `clk` meets 50 MHz (maximum 54.0 MHz) |
| On hardware | **tested on a Zen 4** (works; see "Hardware test") |

## Layout

- `rtl/` `i2c-master-core.v`, `spi-slave.v`, `spi-to-i2c-bridge-zen4-top.v`, `spi-to-i2c-bridge.v`
- `sim/` `run-sim.sh`, `tb-spi-to-i2c-bridge.v`
- `firmware/RP2350/` `spi-to-i2c.py`
- Efinity: `spi-to-i2c-bridge.peri.xml`, `spi-to-i2c-bridge.xml`, and `sdc/` (`spi-to-i2c-bridge.sdc`)
- `bitstream/` `spi-to-i2c-bridge.hex.bin` (built in Efinity, loads with the board loader)

## Clock

clk: 50 MHz (50 MHz oscillator on GPIOL_20 into the Efinity PLL).

## Pins

Set in `spi-to-i2c-bridge.peri.xml`. Pads marked verified were used in hardware tests (clock, LEDs, the RP2350 link pads and header pads R-05 / R-06).

| Signal | FPGA pad | Mode | Status | Notes |
| --- | --- | --- | --- | --- |
| `clock input (to PLL)` | GPIOL_20 | input | verified | clock oscillator |
| `spi_sck` | GPIOL_01 | input | verified | RP2350 GPIO2 |
| `spi_mosi` | GPIOL_06 | input | verified | RP2350 GPIO3 |
| `spi_ss` | GPIOL_02 | input | verified | RP2350 GPIO1 |
| `spi_miso` | GPIOL_04 | inout | verified | RP2350 GPIO0 |
| `sda` | GPIOR_05 | inout | verified | header pad R-05, needs a pull-up to 3.3 V |
| `scl` | GPIOR_06 | inout | verified | header pad R-06, needs a pull-up to 3.3 V |

## Hardware test

Works on a Zen 4. The script talks to an I2C device at address 0x50 on header pads R-05 (SDA) and R-06 (SCL), with pull-ups to 3.3 V; the SPI side uses the Zen link wires, so it needs no jumpers.

## Simulate

```
bash sim/run-sim.sh
```

Needs Icarus Verilog (`iverilog`, `vvp`). The script fails unless the testbench prints `ALL PASS`.

## Build and load

1. Open `spi-to-i2c-bridge.xml` in Efinity (Trion T4F81).
2. Open Interface Designer and check the PLL and pad assignments against the table above (this is the pad table used for the hardware test).
3. Run synthesis, place and route, then generate the bitstream and program the Zen 4.
4. Run the scripts in `firmware/RP2350/` with `python -m mpremote run <script>`.

5. Load without the Efinity programmer: copy `bitstream/spi-to-i2c-bridge.hex.bin` to the board and configure the FPGA with the board loader (`main.py` must already be on the board):

```
python -m mpremote cp bitstream/spi-to-i2c-bridge.hex.bin :
python -m mpremote exec "import main as m; m.FILE_NAME='spi-to-i2c-bridge.hex.bin'; m.configure()"
```

## Notes and differences from the Shrike example

- The FPGA is the I2C master for a sensor at 0x50 (`TARGET_SLAVE_ADDR` in the core). Each SPI command byte is written to the sensor, then one byte is read back; read it with a second, dummy SPI transaction.
- I2C SDA/SCL are open-drain pads: add external pull-up resistors to 3.3 V.

## License

GPL-2.0, like the Shrike repository this is ported from.
