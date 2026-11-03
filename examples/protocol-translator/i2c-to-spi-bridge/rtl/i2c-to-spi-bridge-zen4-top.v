// i2c-to-spi-bridge-zen4-top.v - board top for the I2C -> SPI bridge on the Vicharak Zen 4 (Trion T4F81).
// The FPGA is an I2C slave at 0x32 (100 kHz; SDA is open-drain and needs an external pull-up) and an SPI master (mode 0, 1 MHz) on header pads. Each byte written over I2C is sent on SPI; the byte received on
// MISO during it is what the next I2C read returns (0xFF until a transfer has completed). LED 1 blinks on every I2C byte received.

module i2c_to_spi_bridge_zen4_top (
    input  wire clk,       // 50 MHz fabric clock from the PLL
    input  wire sda_in,    // I2C SDA pad input
    output wire sda_out,   // I2C SDA pad output (always low)
    output wire sda_oe,    // I2C SDA pull-down enable
    input  wire scl,       // I2C SCL (input only)
    output wire spi_sclk,  // SPI clock
    output wire spi_ss,    // SPI chip select, active low
    output wire spi_mosi,  // SPI data out
    input  wire spi_miso,  // SPI data in
    output wire led1       // LED 1, active low
);

    // Activity pulse from the core
    wire act;

    // This contains the instantiation for the bridge
    i2c_to_spi_bridge u_bridge (
        .i_clk(clk), .i_scl(scl), .i_sda(sda_in), .o_sda(sda_out), .o_sda_oe(sda_oe), .o_led(act),
        .o_spi_sclk(spi_sclk), .o_spi_ss(spi_ss), .o_spi_mosi(spi_mosi), .i_spi_miso(spi_miso));

    // Stretch the one-clock activity pulse so the LED is visible (about 84 ms)
    reg [22:0] stretch = 23'd0;
    always @(posedge clk) begin
        if (act) stretch <= {23{1'b1}};
        else if (stretch != 23'd0) stretch <= stretch - 23'd1;
    end
    assign led1 = ~(stretch != 23'd0);

endmodule
