// aes-zen8-top.v - board top for the Vicharak Zen 8 (Trion T8F81, simulated only, never run on hardware): AES-128 engine reached over the Zen Link.
// The Zen Link replaces the UART wires: the bridge below carries the bytes to and from the UART lines of the unchanged aes_top engine, so the UART command protocol of the README is the same.
// Two clocks from the PLL: clk is 50 MHz (Zen Link, bridge registers) and clk_core is 25 MHz (the engine, as before). They meet only in the bridge's dual-clock FIFOs.

module aes_zen8_top (
    input  wire       clk,          // 50 MHz clock from the PLL (Zen Link)
    input  wire       clk_core,     // 25 MHz clock from the PLL (AES engine)
    input  wire       btn1,         // Button 1, active low: press to reset the engine
    input  wire       link_clk_in,  // Zen Link CLK from the RP2350 (GPIO28)
    input  wire       link_csn_in,  // Zen Link CS_N from the RP2350 (GPIO29)
    input  wire [7:0] link_d_in,    // Zen Link data pins, input side
    output wire [7:0] link_d_out,   // Zen Link data pins, output side
    output wire [7:0] link_d_oe,    // Zen Link data pins, output enable
    output wire       led1,         // LED 1, active low: lit while a command is being processed
    output wire       led2          // LED 2, active low: lit after a receive FIFO overflow
);

    // Power-on reset counters, one per clock: each counts up to 255 and the logic of that clock is held in reset until it is full
    reg [7:0] por_l = 8'd0, por_c = 8'd0;
    // Two flip-flops per clock that bring the asynchronous button into the clock domain (reset value 1 = not pressed)
    reg [1:0] bsync_l = 2'b11, bsync_c = 2'b11;
    // Zen Link control registers: CTRL0 (address 0x10) bit 0 is a software reset the RP2350 can pulse
    wire [31:0] ctrl_flat;
    // Zen Link user bus
    wire [15:0] usr_addr;
    wire usr_wr, usr_rd;
    wire [7:0] usr_wdata, usr_rdata;
    // Software reset (CTRL0 bit 0) brought into the engine clock domain
    reg [1:0] sw_c = 2'b00;
    // Reset of the Zen Link side: active while the power-on counter is running
    wire rst_l = (por_l != 8'hFF);
    // Reset of the engine: active while its power-on counter is running
    wire rst_c = (por_c != 8'hFF);
    // Serial lines between the bridge and the engine (idle high)
    wire rx_line, tx_line;
    // Activity indicator from the engine
    wire busy;
    // Error indicator from the engine
    wire err;

    // This block makes the power-on reset of the Zen Link side and adds the button and the software reset as manual resets
    always @(posedge clk) begin
        bsync_l <= {bsync_l[0], btn1};                       // Synchronise the button
        if (!bsync_l[1] || ctrl_flat[0]) por_l <= 8'd0;      // Button or software reset: restart the reset counter
        else if (por_l != 8'hFF) por_l <= por_l + 8'd1;      // Otherwise count up until full
    end

    // This block makes the power-on reset of the engine side and adds the button and the software reset as manual resets
    always @(posedge clk_core) begin
        bsync_c <= {bsync_c[0], btn1};                       // Synchronise the button
        sw_c    <= {sw_c[0], ctrl_flat[0]};                  // Synchronise the software reset
        if (!bsync_c[1] || sw_c[1]) por_c <= 8'd0;           // Button or software reset: restart the reset counter
        else if (por_c != 8'hFF) por_c <= por_c + 8'd1;      // Otherwise count up until full
    end

    // This contains the instantiation for the Zen Link
    zen_link #(.NCTRL(4), .NSTAT(4)) u_link (
        .clk(clk), .rst_n(1'b1), .link_clk_in(link_clk_in), .link_csn_in(link_csn_in),
        .link_d_in(link_d_in), .link_d_out(link_d_out), .link_d_oe(link_d_oe),
        .ctrl_flat(ctrl_flat), .stat_flat(32'd0),
        .usr_addr(usr_addr), .usr_wr(usr_wr), .usr_wdata(usr_wdata), .usr_rd(usr_rd), .usr_rdata(usr_rdata));

    // This contains the instantiation for the Zen Link to UART bridge (217 clocks per bit at 25 MHz = the engine's default 115200 baud)
    zl_uart_bridge #(.BASE(16'h0100), .CPB_DEFAULT(16'd217), .AW_RX(9)) u_bridge (
        .clk(clk), .rst_n(~rst_l), .usr_addr(usr_addr), .usr_wr(usr_wr), .usr_wdata(usr_wdata), .usr_rd(usr_rd), .usr_rdata(usr_rdata),
        .core_clk(clk_core), .core_rst_n(~rst_c), .line_to_core(rx_line), .line_from_core(tx_line));

    // This contains the instantiation for the Zen 8 engine (four S-box lookups per clock, four MixColumns columns per clock), unchanged
    aes_top #(.SB_LANES(4), .MC_PAR(4), .CPB_DEFAULT(217), .IDLE_CLKS(17500000)) u_aes (
        .clk(clk_core), .rst(rst_c), .uart_rx(rx_line), .uart_tx(tx_line), .busy_led(busy), .err_led(err));

    // LED 1 sinks current: a low pin lights it
    assign led1 = ~busy;
    // LED 2 sinks current: a low pin lights it
    assign led2 = ~err;

endmodule
