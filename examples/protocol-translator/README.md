# protocol-translator

Six bridges between SPI, UART and I2C, ported from the Vicharak Shrike `examples/protocol-translator` (GPL-2.0) to the Vicharak Zen 4 (Efinix Trion T4F81 + RP2350). Each bridge is its own project with `rtl/`, `sim/`, `firmware/RP2350/`, the Efinity files and `bitstream/`, in the same layout as the other examples.

| Bridge | FPGA role | Notes | Simulation |
| --- | --- | --- | --- |
| [`spi-to-uart-bridge`](spi-to-uart-bridge) | SPI slave, UART | SPI byte goes out on the UART; the UART reply is read back over SPI | passes |
| [`uart-to-spi-bridge`](uart-to-spi-bridge) | UART, SPI master | UART byte becomes an SPI byte; the SPI reply goes back on the UART | passes |
| [`spi-to-i2c-bridge`](spi-to-i2c-bridge) | SPI slave, I2C master | I2C write then read of a sensor at 0x50 per SPI command | passes |
| [`i2c-to-uart-bridge`](i2c-to-uart-bridge) | I2C slave (0x50), UART | both directions run independently | passes |
| [`uart-to-i2c-bridge`](uart-to-i2c-bridge) | UART, I2C master | each UART byte becomes an I2C write then read, echoed on the UART | passes |
| [`i2c-to-spi-bridge`](i2c-to-spi-bridge) | I2C slave (0x32), SPI master | I2C write goes out on SPI, the MISO byte comes back on the next I2C read | passes |

## Pins

The UART of every bridge uses the pads wired to the RP2350 UART1 (GPIOL_00 = RP2350 GPIO24, GPIOL_03 = RP2350 GPIO25), so a bridge with a UART can be driven from the RP2350 directly. All SPI and I2C pins are on header pads whose numbers are **placeholders** (only header pad R-05 has been verified), so check each `.peri.xml` before wiring. I2C SDA and SCL are open-drain pads: add external pull-up resistors to 3.3 V.

## Differences from the Shrike versions

- The Renesas pad-enable ports (`clk_en`, `*_en`, `*_oe` tied high) are removed; open-drain I2C and the SPI MISO pad use tristate pads with output-enable.
- `spi-to-uart-bridge` got a power-on reset and a moved assignment (details in its README); `i2c-to-spi-bridge` declares `SPI_CLK_DIV` (the original used it undeclared).
- The firmware scripts are ports of the originals with the Shrike-specific lines removed and the UART on UART1 (GPIO24 / GPIO25). Where the original emulated an I2C slave by poking RP2040 registers, the RP2350 port uses `SoftI2C` as the master (`i2c-to-uart-bridge`, `i2c-to-spi-bridge`); `uart-to-i2c-bridge` and `spi-to-i2c-bridge` are plain drivers for an I2C sensor.

## Status

All six simulate and all six have been tested on a Zen 4.
