// zl-byte-port.v - SPI-style byte port on the Zen Link user bus: lets a Shrike "spi_target" design run behind the link with its core unchanged.
//
// Shrike side: the RP2040 clocks one byte at a time through spi_target (o_rx_data / o_rx_data_valid for the byte it sent, i_tx_data for the byte it gets back, o_ss_n for chip select).
// Zen side: the RP2350 does the same through three registers at BASE:
//   BASE+0  DATA  write: the byte "sent" (o_rx_data, with a one-clock o_rx_data_valid pulse)
//                 read : the byte SPI would have shifted back during that byte (i_tx_data, with a one-clock o_tx_data_hold pulse)
//   BASE+1  CTRL  write bit 0: 1 = chip select asserted (o_ss_n low), 0 = released.  read: current select state
//   BASE+2  LAST  read: the last byte written to DATA
// One SPI byte is "read DATA, then write DATA": reading first returns what SPI would already have loaded into its shift register at the start of the byte.
// o_ss_fall is a one-clock pulse when the select goes active (the SPI designs use the chip-select edge to restart a transfer).

module zl_byte_port #(
    parameter [15:0] BASE = 16'h0100   // First register address on the user bus
) (
    input  wire        clk,               // Fabric clock
    input  wire        rst_n,             // Reset, active low
    input  wire [15:0] usr_addr,          // Zen Link user bus address
    input  wire        usr_wr,            // Write strobe
    input  wire [7:0]  usr_wdata,         // Write data
    input  wire        usr_rd,            // Read strobe
    output reg  [7:0]  usr_rdata,         // Read data (combinational from usr_addr)
    output reg  [7:0]  o_rx_data = 8'd0,  // Last byte written to DATA
    output reg         o_rx_data_valid = 1'b0, // One clock after a write to DATA
    input  wire [7:0]  i_tx_data,         // Byte returned when DATA is read
    output reg         o_tx_data_hold = 1'b0,  // One clock after a read of DATA
    output reg         o_ss_n = 1'b1,     // Chip select, active low
    output reg         o_ss_fall = 1'b0   // One clock when the select goes active
);

    // Register hits
    wire hit_data = (usr_addr == BASE);
    wire hit_ctrl = (usr_addr == BASE + 16'd1);
    wire hit_last = (usr_addr == BASE + 16'd2);

    // This block handles the writes and the strobes
    always @(posedge clk) begin
        // Strobes last one clock
        o_rx_data_valid <= 1'b0;
        o_tx_data_hold  <= 1'b0;
        o_ss_fall       <= 1'b0;
        if (!rst_n) begin
            o_ss_n <= 1'b1;
        end else begin
            // Write to DATA: the byte "sent"
            if (usr_wr && hit_data) begin
                o_rx_data       <= usr_wdata;
                o_rx_data_valid <= 1'b1;
            end
            // Write to CTRL: chip select
            if (usr_wr && hit_ctrl) begin
                o_ss_n <= ~usr_wdata[0];
                if (usr_wdata[0] && o_ss_n) o_ss_fall <= 1'b1;
            end
            // Read of DATA: the byte "taken" by the master
            if (usr_rd && hit_data) o_tx_data_hold <= 1'b1;
        end
    end

    // This block is the read mux
    always @* begin
        usr_rdata = 8'd0;
        if (hit_data) usr_rdata = i_tx_data;
        if (hit_ctrl) usr_rdata = {7'd0, ~o_ss_n};
        if (hit_last) usr_rdata = o_rx_data;
    end

endmodule
