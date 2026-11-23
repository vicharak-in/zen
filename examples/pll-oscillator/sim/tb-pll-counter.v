// tb-pll-counter.v - self-checking testbench: for each rate the counter step period must be 1, 4, 16 and 64 clocks, the counter must wrap 15 -> 0 and reset must clear it.

`timescale 1ns/1ps

module tb_pll_counter;

    // Clock
    reg clk = 1'b0;
    // Reset, active low
    reg rst_n = 1'b0;
    // Rate select
    reg [1:0] rate = 2'd0;
    // Counter output
    wire [3:0] counter;
    // Error counter
    integer errs = 0;
    // Clocks between steps
    integer n, r, k, expect_period;
    // Previous counter value
    reg [3:0] prev;

    // 50 MHz clock
    always #10 clk = ~clk;

    // This contains the instantiation for the design under test
    pll_counter dut (.clk(clk), .rst_n(rst_n), .rate(rate), .counter(counter));

    // This block runs the test
    initial begin
        repeat (4) @(posedge clk);
        #1;
        if (counter !== 4'd0) begin errs = errs + 1; $display("FAIL: counter not 0 in reset"); end
        rst_n = 1'b1;
        for (r = 0; r < 4; r = r + 1) begin
            // Select the rate and start over from reset
            rst_n = 1'b0; rate = r[1:0]; repeat (3) @(posedge clk); #1; rst_n = 1'b1;
            expect_period = 1 << (2 * r);
            prev = counter;
            // Watch 20 steps, which also covers the wrap from 15 to 0
            for (k = 0; k < 20; k = k + 1) begin
                n = 0;
                while (counter === prev && n < 1000) begin @(posedge clk); #1; n = n + 1; end
                if (n != expect_period) begin errs = errs + 1; $display("FAIL: rate %0d step %0d took %0d clocks, expected %0d", r, k, n, expect_period); end
                if (counter !== ((prev + 4'd1) & 4'hF)) begin errs = errs + 1; $display("FAIL: rate %0d counter went %0d -> %0d", r, prev, counter); end
                prev = counter;
            end
        end
        // Reset in the middle of counting
        rate = 2'd0; repeat (5) @(posedge clk); rst_n = 1'b0; repeat (2) @(posedge clk); #1;
        if (counter !== 4'd0) begin errs = errs + 1; $display("FAIL: reset did not clear the counter"); end
        if (errs == 0) $display("ALL PASS"); else $display("SOME FAILED");
        $finish;
    end

endmodule
