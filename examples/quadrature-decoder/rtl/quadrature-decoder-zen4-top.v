// quadrature-decoder-zen4-top.v - board top for quadrature_decoder on the Zen 4: encoder A/B on two header pads (or a test encoder driven over the Zen Link),
// 8-byte packets to the RP2350 over the Zen Link, LED 1 shows direction.
// The Zen Link replaces the UART wire: the bridge below collects the UART line of the unchanged quadrature_decoder_uart core, and the RP2350 reads the packet bytes from it.
// Test encoder: Zen Link register CTRL1 (address 0x11): bit 0 = use the test encoder instead of the header pads, bit 1 = test A, bit 2 = test B.
// The encoder pads have the weak pullup on (for open-collector encoders); keep the inputs 3.3 V. btn1 resets the decoder, and so does fpga.write(0x10, 1).
// Fabric clock is 50 MHz (PLL x16 / 16), required by the Zen Link synchronisers.

module quadrature_decoder_zen4_top #(
    parameter CLK_FREQ  = 50_000_000,  // Fabric clock in Hz
    parameter UPDATE_MS = 500,         // Speed window and packet interval in ms
    parameter CPR       = 4000         // Counts per revolution (4x decoding)
) (
    input  wire       clk,          // 50 MHz fabric clock from the PLL
    input  wire       btn1,         // Button 1, active low: reset
    input  wire       link_clk_in,  // Zen Link CLK from the RP2350 (GPIO28)
    input  wire       link_csn_in,  // Zen Link CS_N from the RP2350 (GPIO29)
    input  wire [7:0] link_d_in,    // Zen Link data pins, input side
    output wire [7:0] link_d_out,   // Zen Link data pins, output side
    output wire [7:0] link_d_oe,    // Zen Link data pins, output enable
    input  wire       enc_a,        // Header pad: encoder channel A
    input  wire       enc_b,        // Header pad: encoder channel B
    output wire       led1          // On-board LED 1, active low: lit when the last step was forward
);

    // Power-on reset counter: the decoder is held in reset for 255 clocks after configuration
    reg [7:0] por = 8'd0;
    // Two-flop synchroniser for the button (released = 1)
    reg [1:0] btn_sync = 2'b11;
    // Zen Link control registers: CTRL0 (address 0x10) bit 0 is a software reset the RP2350 can pulse
    wire [31:0] ctrl_flat;
    // Zen Link user bus
    wire [15:0] usr_addr;
    wire usr_wr, usr_rd;
    wire [7:0] usr_wdata, usr_rdata;
    // Active-high reset: power-on counter running, button pressed or software reset set
    wire rst = (por != 8'hFF) | ~btn_sync[1] | ctrl_flat[0];
    // Test encoder control: CTRL1 is the second control register (bits 15:8 of ctrl_flat)
    wire [7:0] ctrl1 = ctrl_flat[15:8];
    // Encoder channels seen by the decoder: the header pads, or the test encoder when CTRL1 bit 0 is set
    wire a_in = ctrl1[0] ? ctrl1[1] : enc_a;
    wire b_in = ctrl1[0] ? ctrl1[2] : enc_b;
    // UART line from the core into the bridge (idles high)
    wire uart_tx;
    // Direction of the last step
    wire direction;

    // This block runs the power-on counter and the button synchroniser (the encoder inputs are synchronised inside the decoder)
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

    // This contains the instantiation for the Zen Link to UART bridge
    zl_uart_bridge #(.BASE(16'h0100), .CPB_DEFAULT(16'd434)) u_bridge (
        .clk(clk), .rst_n(~rst), .usr_addr(usr_addr), .usr_wr(usr_wr), .usr_wdata(usr_wdata), .usr_rd(usr_rd), .usr_rdata(usr_rdata),
        .core_clk(clk), .core_rst_n(~rst), .line_to_core(), .line_from_core(uart_tx));

    // This contains the instantiation for the decoder with UART output (unchanged)
    quadrature_decoder_uart #(.WIDTH(16), .CLK_FREQ(CLK_FREQ), .UPDATE_MS(UPDATE_MS), .CPR(CPR), .CLKS_PER_BIT(434)) u_qd (
        .clk(clk), .rst(rst), .enc_a(a_in), .enc_b(b_in), .uart_tx(uart_tx), .direction(direction));

    // LED 1 sinks current: a low pin lights it
    assign led1 = ~direction;

endmodule
