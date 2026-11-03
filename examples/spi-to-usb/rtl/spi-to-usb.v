// spi-to-usb.v - SPI-to-USB bridge core: an external SPI master (an Arduino Uno) sends bytes to the FPGA, the FPGA keeps the last one and the RP2350 reads it.
// The byte is also returned to the external master on its next transfer, and bit 0 of it drives the LED.
// Ported from the Shrike example (module "top"): the external spi_target stays, the second spi_target (to the RP2040) is gone, replaced by the Zen Link byte port
// in the board top (the RP2350 reads arduino_byte there). The power-on reset moved to the board top.

module spi_to_usb (
    input  wire       clk,           // Fabric clock
    input  wire       rst_n,         // Reset, active low
    input  wire       ext_ss_n,      // External SPI: chip select
    input  wire       ext_sck,       // External SPI: clock
    input  wire       ext_mosi,      // External SPI: data from the master
    output wire       ext_miso,      // External SPI: data to the master
    output wire       ext_miso_oe,   // External SPI: MISO output enable
    output reg  [7:0] arduino_byte = 8'h00, // Last byte received from the external master
    output reg        led = 1'b0     // Bit 0 of the last byte
);

    // Byte received by the external target and its valid strobe
    wire [7:0] ext_rx_data;
    wire       ext_rx_valid;

    // This contains the instantiation for the external SPI target
    spi_target #(.CPOL(1'b0), .CPHA(1'b0), .WIDTH(8), .LSB(1'b0)) u_ext_target (
        .i_clk(clk), .i_rst_n(rst_n), .i_enable(1'b1),
        .i_ss_n(ext_ss_n), .i_sck(ext_sck), .i_mosi(ext_mosi), .o_miso(ext_miso), .o_miso_oe(ext_miso_oe),
        .o_rx_data(ext_rx_data), .o_rx_data_valid(ext_rx_valid),
        .i_tx_data(arduino_byte),   // Echo back the previous byte
        .o_tx_data_hold());

    // This block keeps the last byte and the LED
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            arduino_byte <= 8'h00;
            led <= 1'b0;
        end else if (ext_rx_valid) begin
            arduino_byte <= ext_rx_data;
            led <= ext_rx_data[0];
        end
    end

endmodule
