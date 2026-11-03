// tb-led-blink.v - self-checking testbench: the LED must toggle every HALF_CLKS+1 clocks

`timescale 1ns/1ps

module tb_led_blink;

    // Short interval so the test is quick
    localparam HALF = 20;
    // Clock
    reg clk = 1'b0;
    // LED from the design
    wire led;
    // Error counter
    integer errs = 0;
    // Clocks counted between edges
    integer n = 0;
    // Edges seen
    integer edges = 0;
    // Previous LED value
    reg prev = 1'b0;

    // 50 MHz clock
    always #10 clk = ~clk;

    // This contains the instantiation for the design under test
    led_blink #(.HALF_CLKS(HALF)) dut (.clk(clk), .led(led));

    // This block measures the spacing between LED edges
    always @(posedge clk) begin
        // Count clocks since the last edge
        n <= n + 1;
        // An edge happened
        if (led !== prev) begin
            // Skip the first edge, it has no previous edge to measure against
            if (edges > 0 && n != HALF + 1) begin
                errs = errs + 1;
                $display("FAIL: edge spacing %0d, expected %0d", n, HALF + 1);
            end
            edges <= edges + 1;
            n <= 1;
            prev <= led;
        end
    end

    // This block ends the test after six edges
    initial begin
        #(20 * (HALF + 1) * 8);
        if (edges < 6) begin errs = errs + 1; $display("FAIL: only %0d edges", edges); end
        if (errs == 0) $display("ALL PASS"); else $display("SOME FAILED");
        $finish;
    end

endmodule
