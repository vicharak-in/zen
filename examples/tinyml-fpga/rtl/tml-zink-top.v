// tml-zink-top.v - board top for tinyml-fpga on the Zen 4 (Trion T4F81, 50 MHz fabric clock).
// The RP2350 reaches the TinyML engine through the Zen Link pins (D0..D7, CLK, CS_N) with fpga.write / fpga.read, see tml-zink.v for the map.
// Same port list as the other Zink examples, so the Zink peri.xml and sdc work unchanged.
//   STAT0 (0x20) mirrors the engine STATUS byte, so fpga.read(0x20) works as well as fpga.read(0x101).
//   led1 = busy, led2 = error (both active low). btn1 resets the engine.

`default_nettype none

module tml_zink_top #(
    parameter W_AW = 12, // Weight RAM address width (Zen 4: 12 = 4 KB)
    parameter B_AW = 10  // Bias RAM address width (1 KB)
) (
    input  wire       clk,          // 50 MHz fabric clock from the PLL
    input  wire       link_clk_in,  // Zen Link CLK from the RP2350 (GPIO28)
    input  wire       link_csn_in,  // Zen Link CS_N from the RP2350 (GPIO29)
    input  wire [7:0] link_d_in,    // Zen Link data pins, input side
    output wire [7:0] link_d_out,   // Zen Link data pins, output side
    output wire [7:0] link_d_oe,    // Zen Link data pins, output enable
    input  wire       btn1,         // button 1, active low: reset the engine
    input  wire       btn2,         // button 2 (unused, kept so the pin setup is shared)
    output wire       led1,         // LED 1, active low: lit while a run is in progress
    output wire       led2          // LED 2, active low: lit after an error
);

    // Registers the MCU writes (unused here, the engine uses the user bus)
    wire [31:0] ctrl_flat;
    // Registers the MCU reads: STAT0 = engine status
    wire [31:0] stat_flat;
    // User bus signals between the link and the engine
    wire [15:0] usr_addr;
    wire        usr_wr;
    wire [7:0]  usr_wdata;
    wire        usr_rd;
    wire [7:0]  usr_rdata;
    // Engine status byte
    wire [7:0]  status;

    // Power-on reset counter: holds the engine in reset for 255 clocks after configuration
    reg  [7:0] por = 8'd0;
    // Two-flop synchroniser for the button (pressed = 1)
    reg  [1:0] btn_sync = 2'b00;
    // Reset for the engine: power-on counter running or button pressed
    wire       rst = (por != 8'hFF) | btn_sync[1];

    // This block runs the power-on counter and the button synchroniser
    always @(posedge clk) begin
        if (por != 8'hFF) por <= por + 8'd1;     // Count until the end value, then stay
        btn_sync <= {btn_sync[0], ~btn1};        // Button is active low
    end

    // STAT0 carries the status byte, the other status registers read 0
    assign stat_flat = {24'd0, status};
    // LEDs sink current: low pin = on
    assign led1 = ~status[0];
    assign led2 = ~status[2];

    // This contains the instantiation for the TinyML engine
    tml_zink #(.W_AW(W_AW), .B_AW(B_AW)) u_tml (
        .clk(clk), .rst(rst),
        .usr_addr(usr_addr), .usr_wr(usr_wr), .usr_wdata(usr_wdata), .usr_rd(usr_rd), .usr_rdata(usr_rdata),
        .status_o(status)
    );

    // This contains the instantiation for u_link
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
