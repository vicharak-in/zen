// usb-to-spi.v - USB-to-SPI bridge core: every byte received from the RP2350 is sent out as one SPI transfer (master, mode 0), and the byte the external slave shifts back is
// returned to the RP2350 on its next transfer (one transfer behind). Bit 0 of the byte sent drives the LED.
// Ported from the Shrike example (module "top"): the spi_target to the RP2040 is gone, replaced by the Zen Link byte port in the board top (rx_data / rx_valid in,
// return_data out). The power-on reset moved to the board top. SPI clock = clk / (2 * CLK_DIV) = 390 kHz at 50 MHz.

module usb_to_spi #(
    parameter CLK_DIV = 64     // Clocks per half SPI period
) (
    input  wire       clk,          // Fabric clock
    input  wire       rst_n,        // Reset, active low
    input  wire [7:0] rx_data,      // Byte from the RP2350
    input  wire       rx_valid,     // One clock when rx_data is new
    output reg  [7:0] return_data = 8'h00, // Reply of the last completed SPI transfer
    output wire       m_ss_n,       // SPI master: chip select
    output wire       m_sck,        // SPI master: clock
    output wire       m_mosi,       // SPI master: data out
    input  wire       m_miso,       // SPI master: data in
    output reg        led = 1'b0    // Bit 0 of the last byte sent
);

    // Master handshake
    wire [7:0] m_rx_data;
    wire m_busy;
    wire m_done;
    reg [7:0] m_tx_data = 8'h00;
    reg m_start = 1'b0;

    // This block starts a transfer for each byte from the RP2350 (a byte that arrives while the master is busy is dropped, as in the original)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            m_tx_data <= 8'h00;
            m_start <= 1'b0;
        end else begin
            m_start <= 1'b0;
            if (rx_valid && !m_busy && !m_start) begin
                m_tx_data <= rx_data;
                m_start <= 1'b1;
            end
        end
    end

    // This block keeps the reply of the finished transfer
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) return_data <= 8'h00;
        else if (m_done) return_data <= m_rx_data;
    end

    // This block drives the LED
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) led <= 1'b0;
        else if (rx_valid) led <= rx_data[0];
    end

    // This contains the instantiation for the SPI master
    spi_master #(.WIDTH(8), .CLK_DIV(CLK_DIV)) u_spi_master (
        .i_clk(clk), .i_rst_n(rst_n), .i_start(m_start), .i_tx_data(m_tx_data), .o_rx_data(m_rx_data),
        .o_busy(m_busy), .o_done(m_done), .o_ss_n(m_ss_n), .o_sck(m_sck), .o_mosi(m_mosi), .i_miso(m_miso));

endmodule
