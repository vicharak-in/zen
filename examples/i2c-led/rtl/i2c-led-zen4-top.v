// i2c-led-zen4-top.v - board top for i2c_led on the Zen 4: the FPGA is an I2C slave (address 0x32), LED 1 follows the 0xAA / 0xFF writes.
// The Zen Link replaces the I2C wires: the pins block below lets the RP2350 pull SCL and SDA of the unchanged i2c_led core low or release them, and read them back.
// btn1 resets the slave, and so does fpga.write(0x10, 1). Fabric clock is 50 MHz (PLL x16 / 16), required by the Zen Link synchronisers.

module i2c_led_zen4_top (
    input  wire       clk,          // 50 MHz fabric clock from the PLL
    input  wire       btn1,         // Button 1, active low: reset
    input  wire       link_clk_in,  // Zen Link CLK from the RP2350 (GPIO28)
    input  wire       link_csn_in,  // Zen Link CS_N from the RP2350 (GPIO29)
    input  wire [7:0] link_d_in,    // Zen Link data pins, input side
    output wire [7:0] link_d_out,   // Zen Link data pins, output side
    output wire [7:0] link_d_oe,    // Zen Link data pins, output enable
    output wire       led1          // On-board LED 1, active low
);

    // Power-on reset counter: the slave is held in reset for 255 clocks after configuration
    reg [7:0] por = 8'd0;
    // Two-flop synchroniser for the button (released = 1)
    reg [1:0] btn_sync = 2'b11;
    // Zen Link control registers: CTRL0 (address 0x10) bit 0 is a software reset the RP2350 can pulse
    wire [31:0] ctrl_flat;
    // Zen Link user bus
    wire [15:0] usr_addr;
    wire usr_wr, usr_rd;
    wire [7:0] usr_wdata, usr_rdata;
    // Active-low reset: power-on counter running, button pressed or software reset set
    wire rst_n = (por == 8'hFF) & btn_sync[1] & ~ctrl_flat[0];
    // I2C lines between the pins block and the slave
    wire scl, sda, sda_out, sda_oe;
    // LED state from the core, 1 = on
    wire led;

    // This block runs the power-on counter and the button synchroniser (SCL and SDA are synchronised inside the I2C slave)
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

    // This contains the instantiation for the Zen Link to I2C pins block
    zl_i2c_pins #(.BASE(16'h0100)) u_pins (
        .clk(clk), .rst_n(rst_n), .usr_addr(usr_addr), .usr_wr(usr_wr), .usr_wdata(usr_wdata), .usr_rd(usr_rd), .usr_rdata(usr_rdata),
        .scl(scl), .sda(sda), .slave_sda_oe(sda_oe));

    // This contains the instantiation for the I2C LED slave (unchanged)
    i2c_led #(.I2C_SLAVE_ADR(7'h32)) u_i2c (.i_clk(clk), .i_rst_n(rst_n), .i_scl(scl), .i_sda(sda), .o_sda(sda_out), .o_sda_oe(sda_oe), .o_led(led));

    // LED 1 sinks current: a low pin lights it
    assign led1 = ~led;

endmodule
