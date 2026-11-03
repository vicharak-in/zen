// tb-morse-blink-zink.v - self-checking testbench: a model of the RP2350 sends the letter E (one dot, 200 ms on at 50 MHz) over a real Zen Link frame and watches LED 1.

`timescale 1ns/1ps

module tb_morse_blink_zink;

    // FPGA clock, 50 MHz
    reg clk = 1'b0;
    // 50 MHz clock
    always #10 clk = ~clk;

    `include "zink-host-model.vh"

    // LED 1 pin
    wire led1;

    // This contains the instantiation for the design under test
    morse_blink_zen4_top dut (.clk(clk), .btn1(1'b1), .link_clk_in(m_clk), .link_csn_in(m_csn), .link_d_in(d_bus), .link_d_out(f_out), .link_d_oe(f_oe), .led1(led1));

    // Checks the LED 1 pin
    task expect_led1(input e, input [255:0] what);
        begin if (led1 !== e) begin errs = errs + 1; $display("FAIL: %0s: led1=%b expected %b", what, led1, e); end end
    endtask

    // This block runs the test
    initial begin
        #(20 * 400);
        rdn(16'h0000, 2); check8(rb[0], 8'h5A, "link ID"); check8(rb[1], 8'hA5, "link ID_INV");
        expect_led1(1'b1, "idle");
        // The letter E is one dot: 200 ms on, then off
        wr1(16'h0100, "E");
        #(434 * 20 * 14);
        #(20_000_000);
        expect_led1(1'b0, "20 ms into the dot");
        #(100_000_000);
        expect_led1(1'b0, "120 ms into the dot");
        #(180_000_000);
        expect_led1(1'b1, "300 ms after E (dot over)");
        // A byte that is not a letter or digit leaves the LED off
        wr1(16'h0100, "!");
        #(434 * 20 * 14);
        #(20_000_000);
        expect_led1(1'b1, "ignored byte");
        if (errs == 0) $display("ALL PASS"); else $display("SOME FAILED");
        $finish;
    end

    // Safety timeout
    initial begin
        #1_000_000_000;
        $display("FAIL: timeout");
        $finish;
    end

endmodule
