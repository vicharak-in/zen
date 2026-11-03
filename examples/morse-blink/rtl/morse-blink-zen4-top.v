// morse-blink-zen4-top.v - board top for morse_blink on the Zen 4: the RP2350 sends characters over the Zen Link and LED 1 blinks them in Morse code.
// The Zen Link replaces the UART wires: the bridge below turns the bytes into the UART line the unchanged morse_blink core listens to. The core has no reset input, so the
// bridge is reset by the power-on counter, btn1 and fpga.write(0x10, 1) only. Fabric clock is 50 MHz (PLL x16 / 16), required by the Zen Link synchronisers.

module morse_blink_zen4_top (
    input  wire       clk,          // 50 MHz fabric clock from the PLL
    input  wire       btn1,         // Button 1, active low: resets the bridge
    input  wire       link_clk_in,  // Zen Link CLK from the RP2350 (GPIO28)
    input  wire       link_csn_in,  // Zen Link CS_N from the RP2350 (GPIO29)
    input  wire [7:0] link_d_in,    // Zen Link data pins, input side
    output wire [7:0] link_d_out,   // Zen Link data pins, output side
    output wire [7:0] link_d_oe,    // Zen Link data pins, output enable
    output wire       led1          // On-board LED 1, active low
);

    // Power-on reset counter: the bridge is held in reset for 255 clocks after configuration
    reg [7:0] por = 8'd0;
    // Two-flop synchroniser for the button (released = 1)
    reg [1:0] btn_sync = 2'b11;
    // Zen Link control registers: CTRL0 (address 0x10) bit 0 is a software reset the RP2350 can pulse
    wire [31:0] ctrl_flat;
    // Zen Link user bus
    wire [15:0] usr_addr;
    wire usr_wr, usr_rd;
    wire [7:0] usr_wdata, usr_rdata;
    // Active-high reset of the bridge: power-on counter running, button pressed or software reset set
    wire rst = (por != 8'hFF) | ~btn_sync[1] | ctrl_flat[0];
    // Serial line from the bridge into the core (idles high)
    wire rx_line;
    // LED level from the core, 1 = on
    wire led;

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

    // This contains the instantiation for the Zen Link to UART bridge
    zl_uart_bridge #(.BASE(16'h0100), .CPB_DEFAULT(16'd434)) u_bridge (
        .clk(clk), .rst_n(~rst), .usr_addr(usr_addr), .usr_wr(usr_wr), .usr_wdata(usr_wdata), .usr_rd(usr_rd), .usr_rdata(usr_rdata),
        .core_clk(clk), .core_rst_n(~rst), .line_to_core(rx_line), .line_from_core(1'b1));

    // This contains the instantiation for the Morse blinker (unchanged)
    morse_blink #(.CLK(50_000_000), .BAUD_RATE(115200)) u_morse (.clk(clk), .rx(rx_line), .LED(led));

    // LED 1 sinks current: a low pin lights it
    assign led1 = ~led;

endmodule
