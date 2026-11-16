// chess_fpga_top.v - board top for Zen Chess (Zen 4 / Trion T4F81): the whole game runs in the FPGA
// Button A is btn2 and button B is btn1; the RP2350 only reads the game state over the Zen Link (see chess_regs.v) and draws it
// Same port list as zink_aes_top.v, so the zink_aes peri.xml and sdc work after renaming to the project name
// Fabric clock: 25 MHz (PLL x16 / 32), as in zink_aes.sdc

`default_nettype none

module chess_fpga_top (
    input  wire       clk,          // 25 MHz fabric clock from the PLL
    input  wire       link_clk_in,  // Zen Link CLK from the RP2350
    input  wire       link_csn_in,  // Zen Link CS_N from the RP2350
    input  wire [7:0] link_d_in,    // Zen Link data pins, input side
    output wire [7:0] link_d_out,   // Zen Link data pins, output side
    output wire [7:0] link_d_oe,    // Zen Link data pins, output enable
    input  wire       btn1,         // Button B (stand still), active low
    input  wire       btn2,         // Button A (jump), active low
    output wire       led1,         // LED 1, active low: lit while btn1 is pressed
    output wire       led2          // LED 2, active low: lit while btn2 is pressed
);
    // Debounced levels of the two buttons (1 = pressed)
    wire pressed1;
    wire pressed2;
    // Power-on reset: low for the first clocks, so the game starts from a known state
    reg [3:0] por = 4'd0;
    wire rst = ~por[3];
    // Millisecond tick
    wire tick;
    // Game outputs
    wire          busy, over;
    wire [40*8-1:0] state;
    wire [31:0]   svc_o;           // service status read by the RP2350
    // Counts finished ticks so the MCU can detect a frame that changed while it was reading
    reg  [6:0]    seq = 7'd0;
    reg           busy_q = 1'b0;
    // Zen Link control and status words (not used by this design)
    wire [31:0] ctrl_flat;
    wire [31:0] stat_flat = 32'd0;
    // User bus between the link and the register map
    wire [15:0] usr_addr;
    wire        usr_wr;
    wire [7:0]  usr_wdata;
    wire        usr_rd;
    wire [7:0]  usr_rdata;

    // LEDs are active low, so a low pin lights the LED while the button is pressed
    assign led1 = ~pressed1;
    assign led2 = ~pressed2;

    // This block releases the power-on reset after 8 clocks and counts finished game ticks
    always @(posedge clk) begin
        if (por[3] == 1'b0) por <= por + 4'd1;          // run the reset counter until it reaches 8
        busy_q <= busy;                                 // previous busy
        if (busy_q && !busy) seq <= seq + 7'd1;         // a tick just finished
    end

    // Unused inputs of the user bus are tied off here so the linter stays quiet
    wire _unused = ^{usr_rd, ctrl_flat, over};

    // This contains the instantiation for the debouncer of button B (btn1)
    btn_debounce u_db1 (
        .clk(clk), .btn_raw_n(btn1), .pressed(pressed1)
    );

    // This contains the instantiation for the debouncer of button A (btn2)
    btn_debounce u_db2 (
        .clk(clk), .btn_raw_n(btn2), .pressed(pressed2)
    );

    // This contains the instantiation for the millisecond tick
    tetris_tick #(.DIV(25000)) u_tick (
        .clk(clk), .tick(tick)
    );

    // This contains the instantiation for the game
    chess_game u_game (
        .clk(clk), .rst(rst), .tick(tick), .a_held(pressed2), .b_held(pressed1),
        .busy(busy), .over(over), .state(state),
        .u_wr(usr_wr), .u_addr(usr_addr), .u_wdata(usr_wdata), .svc_o(svc_o)
    );

    // This contains the instantiation for the register map
    chess_regs u_regs (
        .addr(usr_addr), .buttons({pressed2, pressed1}), .state(state), .seq(seq), .busy(busy), .svc(svc_o), .rdata(usr_rdata)
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
