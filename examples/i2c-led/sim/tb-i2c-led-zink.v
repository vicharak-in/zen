// tb-i2c-led-zink.v - self-checking testbench: a model of the RP2350 bit-bangs I2C through real Zen Link frames (the same steps as zink_i2c.py)
// and writes 0xAA, 0xFF to the slave at 0x32, reads a byte back, and addresses a device that is not there.

`timescale 1ns/1ps

module tb_i2c_led_zink;

    // FPGA clock, 50 MHz
    reg clk = 1'b0;
    // 50 MHz clock
    always #10 clk = ~clk;

    `include "zink-host-model.vh"

    // LED 1 pin
    wire led1;
    // Last acknowledge seen (1 = ACK)
    reg ack;
    // Byte read back
    reg [7:0] rbyte;

    // This contains the instantiation for the design under test
    i2c_led_zen4_top dut (.clk(clk), .btn1(1'b1), .link_clk_in(m_clk), .link_csn_in(m_csn), .link_d_in(d_bus), .link_d_out(f_out), .link_d_oe(f_oe), .led1(led1));

    // Drives the lines: 1 pulls a line low, 0 releases it
    task setl(input scl_low, input sda_low);
        begin wr1(16'h0100, {6'd0, sda_low, scl_low}); end
    endtask

    // Reads the SDA level the slave sees
    task sda_level(output l);
        begin rdn(16'h0100, 1); l = rb[0][1]; end
    endtask

    // START condition
    task i2c_start;
        begin setl(0, 0); setl(0, 1); setl(1, 1); end
    endtask

    // STOP condition
    task i2c_stop;
        begin setl(1, 1); setl(0, 1); setl(0, 0); end
    endtask

    // Sends a byte and sets ack
    task i2c_wbyte(input [7:0] b);
        integer i; reg l;
        begin
            for (i = 7; i >= 0; i = i - 1) begin
                setl(1, ~b[i]); setl(0, ~b[i]); setl(1, ~b[i]);
            end
            setl(1, 0); setl(0, 0); sda_level(l); ack = ~l; setl(1, 0);
        end
    endtask

    // Reads a byte into rbyte and answers with ACK (a = 1) or NACK
    task i2c_rbyte(input a);
        integer i; reg l;
        begin
            rbyte = 8'd0;
            setl(1, 0);
            for (i = 0; i < 8; i = i + 1) begin setl(0, 0); sda_level(l); rbyte = {rbyte[6:0], l}; setl(1, 0); end
            setl(1, a); setl(0, a); setl(1, a);
        end
    endtask

    // Checks the LED 1 pin
    task expect_led1(input e, input [255:0] what);
        begin if (led1 !== e) begin errs = errs + 1; $display("FAIL: %0s: led1=%b expected %b", what, led1, e); end end
    endtask

    // This block runs the test
    initial begin
        #(20 * 400);
        rdn(16'h0000, 2); check8(rb[0], 8'h5A, "link ID"); check8(rb[1], 8'hA5, "link ID_INV");
        rdn(16'h0100, 1); check8(rb[0], 8'h03, "bus idle: both lines high");
        expect_led1(1'b1, "after power-on");
        // Write 0xAA to address 0x32: LED on
        i2c_start; i2c_wbyte(8'h64); check8(ack, 1, "address ACK"); i2c_wbyte(8'hAA); check8(ack, 1, "data ACK"); i2c_stop;
        #(20 * 50); expect_led1(1'b0, "after 0xAA");
        // Write 0xFF: LED off
        i2c_start; i2c_wbyte(8'h64); i2c_wbyte(8'hFF); i2c_stop;
        #(20 * 50); expect_led1(1'b1, "after 0xFF");
        // Read returns the last byte written
        i2c_start; i2c_wbyte(8'h65); check8(ack, 1, "read address ACK"); i2c_rbyte(0); i2c_stop;
        check8(rbyte, 8'hFF, "byte read back");
        // A device that is not there does not answer
        i2c_start; i2c_wbyte(8'h20); check8(ack, 0, "no ACK from 0x10"); i2c_stop;
        if (errs == 0) $display("ALL PASS"); else $display("SOME FAILED");
        $finish;
    end

    // Safety timeout
    initial begin
        #50_000_000;
        $display("FAIL: timeout");
        $finish;
    end

endmodule
