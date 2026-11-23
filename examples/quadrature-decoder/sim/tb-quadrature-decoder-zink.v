// tb-quadrature-decoder-zink.v - self-checking testbench: a model of the RP2350 turns on the test encoder through the Zen Link, steps it 12 counts forward and 3 back,
// and reads the 8-byte packets (0xAA, position, speed, angle, flags) back through the Zen Link. UPDATE_MS is 1 so a packet comes about every millisecond.

`timescale 1ns/1ps

module tb_quadrature_decoder_zink;

    // FPGA clock, 50 MHz
    reg clk = 1'b0;
    // 50 MHz clock
    always #10 clk = ~clk;

    `include "zink-host-model.vh"

    // LED 1 pin
    wire led1;
    // Test encoder phase (Gray code index)
    integer ph = 0;
    // Loop variables
    integer i, n, found;
    // Packet fields
    reg signed [15:0] pos;
    // Last packet seen
    reg [7:0] flags;

    // This contains the instantiation for the design under test
    quadrature_decoder_zen4_top #(.CLK_FREQ(50_000_000), .UPDATE_MS(1), .CPR(4000)) dut (.clk(clk), .btn1(1'b1), .link_clk_in(m_clk), .link_csn_in(m_csn), .link_d_in(d_bus), .link_d_out(f_out), .link_d_oe(f_oe),
        .enc_a(1'b0), .enc_b(1'b0), .led1(led1));

    // One test-encoder step through CTRL1: forward goes 00 -> 01 -> 11 -> 10 (A,B), reverse the other way
    task step(input fwd);
        reg a, b;
        begin
            ph = (ph + (fwd ? 1 : 3)) % 4;
            case (ph) 0: begin a = 0; b = 0; end 1: begin a = 0; b = 1; end 2: begin a = 1; b = 1; end default: begin a = 1; b = 0; end endcase
            wr1(16'h0011, {5'd0, b, a, 1'b1});
            #(20 * 100);
        end
    endtask

    // Reads every waiting byte into rb[0..n-1] and returns n
    task drain;
        begin
            rdn(16'h0102, 1); n = rb[0];
            if (n > 0) rdn(16'h0180, n);
        end
    endtask

    // This block runs the test
    initial begin
        #(20 * 400);
        rdn(16'h0000, 2); check8(rb[0], 8'h5A, "link ID"); check8(rb[1], 8'hA5, "link ID_INV");
        // Turn on the test encoder and take 12 steps forward
        for (i = 0; i < 12; i = i + 1) step(1);
        // Wait for a packet, then look for the final position in everything that arrived
        #(2_500_000);
        drain;
        found = 0;
        for (i = 0; i + 7 < n; i = i + 1) begin
            if (rb[i] == 8'hAA && {rb[i+1], rb[i+2]} == 16'd12 && rb[i+7][0] == 1'b1) found = 1;
        end
        if (!found) begin errs = errs + 1; $display("FAIL: no packet with position 12 and forward flag in %0d bytes", n); end
        // Three steps back
        for (i = 0; i < 3; i = i + 1) step(0);
        #(2_500_000);
        drain;
        found = 0;
        for (i = 0; i + 7 < n; i = i + 1) begin
            if (rb[i] == 8'hAA && {rb[i+1], rb[i+2]} == 16'd9 && rb[i+7][0] == 1'b0) found = 1;
        end
        if (!found) begin errs = errs + 1; $display("FAIL: no packet with position 9 and reverse flag in %0d bytes", n); end
        if (errs == 0) $display("ALL PASS"); else $display("SOME FAILED");
        $finish;
    end

    // Safety timeout
    initial begin
        #200_000_000;
        $display("FAIL: timeout");
        $finish;
    end

endmodule
