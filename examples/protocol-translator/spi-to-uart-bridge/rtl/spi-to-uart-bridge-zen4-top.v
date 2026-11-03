// spi-to-uart-bridge-zen4-top.v - board top for the SPI <-> UART bridge on the Vicharak Zen 4 (Trion T4F81).
// SPI slave (mode 0) and UART (115200 8N1) both face the outside world: the SPI pins are on header pads, the UART is on the pads wired to the RP2350 UART1 (GPIO24 / GPIO25).
// Fabric clock: 50 MHz from the Efinity PLL. LED 1 lights while the bridge can accept more data (fpga_ready).

module spi_to_uart_bridge_zen4_top (
    input  wire clk,        // 50 MHz fabric clock from the PLL
    input  wire spi_sck,    // SPI clock from the host
    input  wire spi_cs,     // SPI chip select, active low
    input  wire spi_mosi,   // SPI data into the FPGA
    output wire spi_miso,   // SPI data out of the FPGA
    input  wire uart_rx,    // UART receive (RP2350 UART1 TX, GPIO24)
    output wire uart_tx,    // UART transmit (RP2350 UART1 RX, GPIO25)
    output wire fpga_ready, // High while the UART RX FIFO has room
    output wire led1        // LED 1, active low
);

    // This contains the instantiation for the bridge
    spi_to_uart_bridge #(.CLK(50000000), .BAUD_RATE(115200)) u_bridge (
        .clk(clk), .spi_sck(spi_sck), .spi_cs(spi_cs), .spi_mosi(spi_mosi), .spi_miso(spi_miso),
        .uart_rx(uart_rx), .uart_tx(uart_tx), .fpga_ready(fpga_ready));

    // LED 1 on while ready
    assign led1 = ~fpga_ready;

endmodule
