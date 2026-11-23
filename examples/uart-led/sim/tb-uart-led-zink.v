// tb-uart-led-zink.v - self-checking testbench: a model of the RP2350 sends 0xAB, 0x11, 0xFF, 0xAB over real Zen Link frames into the board top and watches LED 1.

`timescale 1ns/1ps

module tb_uart_led_zink;

    // FPGA clock, 50 MHz
    reg clk = 1'b0;
    // 50 MHz clock
    always #10 clk = ~clk;

    `include "zink-host-model.vh"

    // LED 1 pin
    wire led1;

    // This contains the instantiation for the design under test
    uart_led_zen4_top dut (.clk(clk), .btn1(1'b1), .link_clk_in(m_clk), .link_csn_in(m_csn), .link_d_in(d_bus), .link_d_out(f_out), .link_d_oe(f_oe), .led1(led1));

    // Sends one byte through the link and waits for the UART frame to finish
    task send(input [7:0] b);
        begin wr1(16'h0100, b); #(434 * 20 * 12); end
    endtask

    // Checks the LED 1 pin
    task expect_led1(input e, input [255:0] what);
        begin if (led1 !== e) begin errs = errs + 1; $display("FAIL: %0s: led1=%b expected %b", what, led1, e); end end
    endtask

    // This block runs the test
    initial begin
        #(20 * 400);
        rdn(16'h0000, 2); check8(rb[0], 8'h5A, "link ID"); check8(rb[1], 8'hA5, "link ID_INV");
        expect_led1(1'b1, "after power-on");
        send(8'hAB); expect_led1(1'b0, "after 0xAB");
        send(8'h11); expect_led1(1'b0, "after 0x11");
        send(8'hFF); expect_led1(1'b1, "after 0xFF");
        send(8'hAB); expect_led1(1'b0, "after second 0xAB");
        // Software reset through CTRL0 turns the LED off
        wr1(16'h0010, 8'h01); wr1(16'h0010, 8'h00); #(20 * 20);
        expect_led1(1'b1, "after software reset");
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
