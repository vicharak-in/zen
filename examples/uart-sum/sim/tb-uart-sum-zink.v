// tb-uart-sum-zink.v - self-checking testbench: a model of the RP2350 sends two bytes over real Zen Link frames and reads the sum back, three times.

`timescale 1ns/1ps

module tb_uart_sum_zink;

    // FPGA clock, 50 MHz
    reg clk = 1'b0;
    // 50 MHz clock
    always #10 clk = ~clk;

    `include "zink-host-model.vh"

    // LED 1 pin
    wire led1;

    // This contains the instantiation for the design under test
    uart_sum_zen4_top dut (.clk(clk), .btn1(1'b1), .link_clk_in(m_clk), .link_csn_in(m_csn), .link_d_in(d_bus), .link_d_out(f_out), .link_d_oe(f_oe), .led1(led1));

    // Sends two operands and checks the sum that comes back
    task add(input [7:0] a, input [7:0] b);
        begin
            wr1(16'h0100, a); wr1(16'h0100, b);
            // Two frames out, the core adds, one frame back
            #(434 * 20 * 40);
            rdn(16'h0102, 1); check8(rb[0], 8'h01, "one reply waiting");
            rdn(16'h0100, 1); check8(rb[0], a + b, "sum");
            rdn(16'h0102, 1); check8(rb[0], 8'h00, "nothing waiting after the read");
        end
    endtask

    // This block runs the test
    initial begin
        #(20 * 400);
        rdn(16'h0000, 2); check8(rb[0], 8'h5A, "link ID"); check8(rb[1], 8'hA5, "link ID_INV");
        add(8'd1, 8'd2);
        add(8'd100, 8'd155);
        add(8'd200, 8'd100);
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
