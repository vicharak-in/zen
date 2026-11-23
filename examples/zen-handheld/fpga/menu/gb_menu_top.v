// gb_menu_top.v - the menu bitstream of the Zen handheld (Zen 4, Trion T4F81): only the two buttons and the Zen Link
// The RP2350 shows the game menu and reads the buttons from register 0x140 (bit0 = btn1, bit1 = btn2, 1 = pressed); register 0x141 is the bitstream ID (1 = menu)
// Same port list as the games, so the same peri.xml and sdc work after renaming to the project name
// Fabric clock: 25 MHz (PLL x16 / 32), as in zink_aes.sdc

`default_nettype none

module gb_menu_top (
    input  wire       clk,          // 25 MHz fabric clock from the PLL
    input  wire       link_clk_in,  // Zen Link CLK from the RP2350
    input  wire       link_csn_in,  // Zen Link CS_N from the RP2350
    input  wire [7:0] link_d_in,    // Zen Link data pins, input side
    output wire [7:0] link_d_out,   // Zen Link data pins, output side
    output wire [7:0] link_d_oe,    // Zen Link data pins, output enable
    input  wire       btn1,         // Button B, active low
    input  wire       btn2,         // Button A, active low
    output wire       led1,         // LED 1, active low: lit while btn1 is pressed
    output wire       led2          // LED 2, active low: lit while btn2 is pressed
);
    // Debounced levels of the two buttons (1 = pressed)
    wire pressed1;
    wire pressed2;
    // Zen Link control and status words (not used by this design)
    wire [31:0] ctrl_flat;
    wire [31:0] stat_flat = 32'd0;
    // User bus between the link and the register map
    wire [15:0] usr_addr;
    wire        usr_wr;
    wire [7:0]  usr_wdata;
    wire        usr_rd;
    reg  [7:0]  usr_rdata;

    // LEDs are active low, so a low pin lights the LED while the button is pressed
    assign led1 = ~pressed1;
    assign led2 = ~pressed2;

    // This block is the register map: 0x140 gives the buttons, 0x141 the bitstream ID (1 = menu), every other address reads zero
    always @* begin
        usr_rdata = 8'd0;                                  // Default: unmapped address reads zero
        if (usr_addr == 16'h0140) usr_rdata = {6'd0, pressed2, pressed1};   // Bit 0 = btn1, bit 1 = btn2
        if (usr_addr == 16'h0141) usr_rdata = 8'd1;        // Menu ID
    end

    // Unused inputs of the user bus are tied off here so the linter stays quiet
    wire _unused = ^{usr_wr, usr_rd, usr_wdata, ctrl_flat};

    // This contains the instantiation for the debouncer of btn1
    btn_debounce u_db1 (
        .clk(clk), .btn_raw_n(btn1), .pressed(pressed1)
    );

    // This contains the instantiation for the debouncer of btn2
    btn_debounce u_db2 (
        .clk(clk), .btn_raw_n(btn2), .pressed(pressed2)
    );

    // This contains the instantiation for the Zen Link slave
    zen_link #(
        .NCTRL (4),
        .NSTAT (4)
    ) u_link (
        .clk         (clk),
        .rst_n       (1'b1),
        .link_clk_in (link_clk_in),
        .link_csn_in (link_csn_in),
        .link_d_in   (link_d_in),
        .link_d_out  (link_d_out),
        .link_d_oe   (link_d_oe),
        .ctrl_flat   (ctrl_flat),
        .stat_flat   (stat_flat),
        .usr_addr    (usr_addr),
        .usr_wr      (usr_wr),
        .usr_wdata   (usr_wdata),
        .usr_rd      (usr_rd),
        .usr_rdata   (usr_rdata)
    );

endmodule

`default_nettype wire
