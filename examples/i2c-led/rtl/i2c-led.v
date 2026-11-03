// i2c-led.v - I2C-controlled LED: write byte 0xAA to the slave to switch the LED on and 0xFF to switch it off. A read returns the last byte written.
// Ported from the Shrike example (module "i2c_blink") to the Zen 4. Changes: the Forge pad attributes and the o_clk_en / o_led_en / o_sda_oe pad ports are gone,
// the SDA line is open drain through sda_oe (the Efinity Interface Designer makes the tristate pad from sda_in / sda_out / sda_oe), and r_data_tx starts at 0.
// The i2c_slave library module is the Renesas one, unchanged.

`timescale 1ns / 1ps

module i2c_led #(
    parameter I2C_SLAVE_ADR = 7'h32   // 7-bit I2C address of the slave
) (
    input  wire i_clk,       // Fabric clock
    input  wire i_rst_n,     // Reset, active low
    input  wire i_scl,       // I2C clock from the master
    input  wire i_sda,       // I2C data as read from the pad
    output wire o_sda,       // I2C data to drive when sda_oe is high (constant 0)
    output wire o_sda_oe,    // Pull SDA low when high (open drain)
    output wire o_led        // LED state, 1 = on
);

    // Interrupts from the slave: byte sent, byte received
    wire w_int_tx, w_int_rx;
    // Slave busy flag (not used)
    wire w_busy;
    // Byte received from the master
    wire [7:0] w_data_rx;
    // Byte returned to the master on a read
    reg  [7:0] r_data_tx = 8'h00;
    // LED state
    reg led_on = 1'b0;

    // This contains the instantiation for the Renesas I2C slave
    i2c_slave #(.I2C_SLAVE_ADR(I2C_SLAVE_ADR)) i2c_slave_inst (
        .i_clk(i_clk), .i_rst(~i_rst_n), .i_en(1'b1), .o_busy(w_busy),
        .i_scl(i_scl), .i_sda(i_sda), .o_sda(o_sda), .o_sda_oe(o_sda_oe),
        .i_data_tx(r_data_tx), .o_data_rx(w_data_rx), .o_int_tx(w_int_tx), .o_int_rx(w_int_rx));

    // This block decodes the received byte
    always @(posedge i_clk) begin
        if (~i_rst_n) begin
            led_on <= 1'b0;
        end
        if (w_int_rx) begin
            r_data_tx <= w_data_rx;
            if (w_data_rx == 8'hAA) led_on <= 1'b1;
            else if (w_data_rx == 8'hFF) led_on <= 1'b0;
        end
    end

    assign o_led = led_on;

endmodule
