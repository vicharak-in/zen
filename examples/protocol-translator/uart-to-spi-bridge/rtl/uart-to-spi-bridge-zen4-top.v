// uart-to-spi-bridge-zen4-top.v - board top for the UART <-> SPI bridge on the Vicharak Zen 4 (Trion T4F81).
// The UART is on the pads wired to the RP2350 UART1 (GPIO24 / GPIO25); the SPI master (1 MHz, mode 0) is on header pads. Each UART byte becomes one SPI byte and the SPI reply comes back on the UART.
// Test setup in the original: jumper MOSI to MISO so the bridge echoes every byte. btn1 = reset (hold).

module uart_to_spi_bridge_zen4_top (
    input  wire clk,    // 50 MHz fabric clock from the PLL
    input  wire btn1,   // Reset, active low (pressed = low)
    input  wire rx,     // UART receive (RP2350 UART1 TX, GPIO24)
    output wire tx,     // UART transmit (RP2350 UART1 RX, GPIO25)
    output wire sclk,   // SPI clock
    output wire cs,     // SPI chip select, active low
    output wire mosi,   // SPI data out
    input  wire miso    // SPI data in
);

    // Button synchroniser and reset, active high for the bridge
    reg [1:0] s = 2'b11;
    always @(posedge clk) s <= {s[0], btn1};
    wire rst = ~s[1];

    // This contains the instantiation for the bridge
    uart_to_spi_bridge #(.CLK(50000000), .BAUD_RATE(115200)) u_bridge (
        .rx(rx), .tx(tx), .rst(rst), .clk(clk), .mosi(mosi), .miso(miso), .sclk(sclk), .cs(cs));

endmodule
