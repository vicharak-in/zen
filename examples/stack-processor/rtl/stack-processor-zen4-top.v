// stack-processor-zen4-top.v - board top for stack_processor on the Zen 4.
// The RP2350 sends the instruction bytes through the Zen Link byte port (zen_spi.py); the stack lives in a block RAM. LED 1 is on while the stack holds data (an addition, the Shrike example had no LED).
// The RP2350 reaches the design through the Zen Link (D0..D7, CLK, CS_N) with the zen_spi.py byte port. btn1 resets the design, and so does fpga.write(0x10, 1) (ZenSPI.reset()).
// Fabric clock: 50 MHz (PLL x16 / 16), required by the Zen Link synchronisers.

module stack_processor_zen4_top (
    input  wire       clk,          // 50 MHz fabric clock from the PLL
    input  wire       link_clk_in,  // Zen Link CLK from the RP2350 (GPIO28)
    input  wire       link_csn_in,  // Zen Link CS_N from the RP2350 (GPIO29)
    input  wire [7:0] link_d_in,    // Zen Link data pins, input side
    output wire [7:0] link_d_out,   // Zen Link data pins, output side
    output wire [7:0] link_d_oe,    // Zen Link data pins, output enable
    input  wire       btn1,         // Button 1, active low: reset
    output wire       led1          // On-board LED 1, active low
);

    // Power-on reset counter: the design is held in reset for 255 clocks after configuration
    reg [7:0] por = 8'd0;
    // Two-flop synchroniser for the button (released = 1)
    reg [1:0] btn_sync = 2'b11;
    // Zen Link control registers: CTRL0 (address 0x10) bit 0 is a software reset the RP2350 can pulse
    wire [31:0] ctrl_flat;
    // Active-low reset: power-on counter running, button pressed or software reset set
    wire rst_n = (por == 8'hFF) & btn_sync[1] & ~ctrl_flat[0];
    // Zen Link user bus
    wire [15:0] usr_addr;
    wire usr_wr, usr_rd;
    wire [7:0] usr_wdata, usr_rdata;
    // Byte port signals (the SPI-target view of the link)
    wire [7:0] rx_data;
    wire rx_valid, tx_hold, ss_n, ss_fall;
    // Byte returned to the RP2350 (driven below)
    wire [7:0] tx_data;

    // This block runs the power-on counter and the button synchroniser
    always @(posedge clk) begin
        if (por != 8'hFF) por <= por + 8'd1;  // Count until the end value, then stay
        btn_sync <= {btn_sync[0], btn1};      // Synchronise the button
    end

    // This contains the instantiation for the Zen Link
    zen_link #(.NCTRL(4), .NSTAT(4)) u_link (
        .clk(clk), .rst_n(1'b1), .link_clk_in(link_clk_in), .link_csn_in(link_csn_in),
        .link_d_in(link_d_in), .link_d_out(link_d_out), .link_d_oe(link_d_oe),
        .ctrl_flat(ctrl_flat), .stat_flat(32'd0),
        .usr_addr(usr_addr), .usr_wr(usr_wr), .usr_wdata(usr_wdata), .usr_rd(usr_rd), .usr_rdata(usr_rdata));

    // This contains the instantiation for the byte port
    zl_byte_port #(.BASE(16'h0100)) u_port (
        .clk(clk), .rst_n(rst_n), .usr_addr(usr_addr), .usr_wr(usr_wr), .usr_wdata(usr_wdata), .usr_rd(usr_rd), .usr_rdata(usr_rdata),
        .o_rx_data(rx_data), .o_rx_data_valid(rx_valid), .i_tx_data(tx_data), .o_tx_data_hold(tx_hold), .o_ss_n(ss_n), .o_ss_fall(ss_fall));

    // Stack status
    wire stack_empty, stack_full;

    // This contains the instantiation for the stack processor
    stack_processor u_core (.clk(clk), .rst_n(rst_n), .rx_data(rx_data), .rx_valid(rx_valid), .tx_data(tx_data), .stack_empty(stack_empty), .stack_full(stack_full));

    // LED 1 sinks current: a low pin lights it, so it is on while the stack is not empty
    assign led1 = stack_empty;

endmodule
