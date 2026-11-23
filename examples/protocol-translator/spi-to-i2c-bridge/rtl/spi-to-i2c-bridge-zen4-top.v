// spi-to-i2c-bridge-zen4-top.v - board top for the SPI -> I2C bridge on the Vicharak Zen 4 (Trion T4F81).
// The FPGA is an SPI slave (host = RP2350 or any SPI master, mode 0) and the I2C master of a sensor at TARGET_SLAVE_ADDR (0x50 in the core). Each SPI command byte is written to the sensor, then one byte is read
// back and placed in the SPI transmit buffer (read it with a second, dummy SPI transaction). I2C is 100 kHz; SDA and SCL are open-drain pads and need external pull-up resistors.

module spi_to_i2c_bridge_zen4_top (
    input  wire clk,          // 50 MHz fabric clock from the PLL
    input  wire spi_sck,      // SPI clock from the host
    input  wire spi_mosi,     // SPI data into the FPGA
    input  wire spi_ss,       // SPI chip select, active low
    input  wire spi_miso_in,  // Pad input of the MISO pad (unused)
    output wire spi_miso_out, // MISO data
    output wire spi_miso_oe,  // MISO output enable: driven only while selected
    input  wire sda_in,       // I2C SDA pad input
    output wire sda_out,      // I2C SDA pad output (always low)
    output wire sda_oe,       // I2C SDA pull-down enable
    input  wire scl_in,       // I2C SCL pad input
    output wire scl_out,      // I2C SCL pad output (always low)
    output wire scl_oe        // I2C SCL pull-down enable
);

    // This contains the instantiation for the bridge
    spi_to_i2c_bridge u_bridge (
        .clk(clk),
        .i_spi_sck(spi_sck), .i_spi_mosi(spi_mosi), .o_spi_miso(spi_miso_out), .o_spi_miso_oe(spi_miso_oe), .i_spi_ss(spi_ss),
        .i_i2c_sda(sda_in), .i_i2c_scl(scl_in), .o_i2c_scl(scl_out), .o_i2c_scl_oe(scl_oe), .o_i2c_sda(sda_out), .o_i2c_sda_oe(sda_oe));

endmodule
