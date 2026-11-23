// zink_pwm_top.v - glue that connects two PWM channels to zink and to the two LEDs.
//   fpga.write(0x10, d)   CTRL0 = brightness of LED1 (0 off .. 255 full)
//   fpga.write(0x11, d)   CTRL1 = brightness of LED2 (0 off .. 255 full)
// Reading 0x10 / 0x11 gives back the value last written. No STAT registers are used.
// Same port list as rtl/top.v of the base example, so the existing peri.xml and sdc work unchanged.

`default_nettype none

module zink_pwm_top (
    input  wire       clk,          // 50 MHz fabric clock from the PLL
    input  wire       link_clk_in,  // Zen Link CLK from the RP2350 (GPIO28)
    input  wire       link_csn_in,  // Zen Link CS_N from the RP2350 (GPIO29)
    input  wire [7:0] link_d_in,    // Zen Link data pins, input side
    output wire [7:0] link_d_out,   // Zen Link data pins, output side
    output wire [7:0] link_d_oe,    // Zen Link data pins, output enable
    input  wire       btn1,         // button 1 (unused, kept so the pin setup is shared)
    input  wire       btn2,         // button 2 (unused, kept so the pin setup is shared)
    output wire       led1,         // LED 1, active low
    output wire       led2          // LED 2, active low
);

    // Registers the MCU writes: CTRL0 = duty 1, CTRL1 = duty 2.
    wire [31:0] ctrl_flat;
    // Registers the MCU reads: all zero (the CTRL registers read back what was written).
    wire [31:0] stat_flat = 32'd0;
    // User bus outputs, unused.
    wire [15:0] usr_addr;
    // User bus write strobe, unused.
    wire        usr_wr;
    // User bus write data, unused.
    wire [7:0]  usr_wdata;
    // User bus read strobe, unused.
    wire        usr_rd;

    // PWM outputs, active high.
    wire pwm1, pwm2;

    // This contains the instantiation for u_pwm1 (LED1 brightness).
    pwm u_pwm1 (
        .clk  (clk),
        .duty (ctrl_flat[7:0]),
        .out  (pwm1)
    );

    // This contains the instantiation for u_pwm2 (LED2 brightness).
    pwm u_pwm2 (
        .clk  (clk),
        .duty (ctrl_flat[15:8]),
        .out  (pwm2)
    );

    // The LEDs sink current, so a high PWM output means a low pin.
    assign led1 = ~pwm1;
    assign led2 = ~pwm2;

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
