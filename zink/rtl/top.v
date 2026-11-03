// top.v - top level of the Zen Link register bus on the Zen board.
// The MCU controls the two LEDs and reads the two buttons over the link:
//   fpga.write(0x10, v)   CTRL[0] bit 0 = LED1 on, bit 1 = LED2 on
//   fpga.read(0x20)       STAT[0] bit 0 = BTN1 pressed, bit 1 = BTN2 pressed
// The other CTRL / STAT registers and the user bus (0x100 and up) are not used yet.
// Pins (Zen R4): led1 F1 GPIOL_13, led2 E2 GPIOL_14 (both active low, D4 / D5),
//                btn1 C9 GPIOR_15, btn2 D7 GPIOR_16 (both active low, switch to GND).

`default_nettype none

module top (
    input  wire       clk,          // 50 MHz fabric clock from the PLL
    input  wire       link_clk_in,  // Zen Link CLK from the RP2350 (GPIO28)
    input  wire       link_csn_in,  // Zen Link CS_N from the RP2350 (GPIO29)
    input  wire [7:0] link_d_in,    // Zen Link data pins, input side
    output wire [7:0] link_d_out,   // Zen Link data pins, output side
    output wire [7:0] link_d_oe,    // Zen Link data pins, output enable
    input  wire       btn1,         // button 1, active low
    input  wire       btn2,         // button 2, active low
    output wire       led1,         // LED 1 (blue), active low
    output wire       led2          // LED 2 (green), active low
);

    // Registers the MCU writes (4 bytes); only CTRL[0] bits 1:0 are used.
    wire [31:0] ctrl_flat;
    // Registers the MCU reads (4 bytes); only STAT[0] bits 1:0 are used.
    wire [31:0] stat_flat;
    // User bus outputs, unused.
    wire [15:0] usr_addr;
    // User bus write strobe, unused.
    wire        usr_wr;
    // User bus write data, unused.
    wire [7:0]  usr_wdata;
    // User bus read strobe, unused.
    wire        usr_rd;

    // Two-flop synchronisers for the asynchronous buttons (reset value is 0 = not pressed).
    reg [1:0] btn1_sync = 2'b00;
    reg [1:0] btn2_sync = 2'b00;

    // Shift each button through its two synchroniser flops (inverted: pressed = 1).
    always @(posedge clk) begin
        // Button 1, active low.
        btn1_sync <= {btn1_sync[0], ~btn1};
        // Button 2, active low.
        btn2_sync <= {btn2_sync[0], ~btn2};
    end

    // The LEDs sink current to the pin, so a 1 in CTRL turns the LED on with a low pin.
    assign led1 = ~ctrl_flat[0];
    assign led2 = ~ctrl_flat[1];
    // STAT[0]: bit 0 = button 1 pressed, bit 1 = button 2 pressed; the rest read 0.
    assign stat_flat = {24'd0, 6'd0, btn2_sync[1], btn1_sync[1]};

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
        .usr_rdata   (8'd0)
    );

endmodule

`default_nettype wire
