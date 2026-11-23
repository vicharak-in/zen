// tb-pmod-led-blink.v - self-checking testbench: all eight outputs flip together every HALF_CLKS+1 clocks

`timescale 1ns/1ps

module tb_pmod_led_blink;

    // Short interval so the test is quick
    localparam HALF = 15;
    // Clock
    reg clk = 1'b0;
    // Outputs of the design
    wire [7:0] led;
    // Error counter
    integer errs = 0;
    // Flips seen
    integer flips = 0;
    // Previous output value
    reg [7:0] prev = 8'h00;

    // 50 MHz clock
    always #10 clk = ~clk;

    // This contains the instantiation for the design under test
    pmod_led_blink #(.HALF_CLKS(HALF)) dut (.clk(clk), .led_pmod(led));

    // This block checks that every change is a full inversion
    always @(posedge clk) begin
        // Output changed
        if (led !== prev) begin
            // Must be 00 -> FF or FF -> 00
            if (led !== ~prev) begin errs = errs + 1; $display("FAIL: partial change %h -> %h", prev, led); end
            flips <= flips + 1;
            prev <= led;
        end
    end

    // This block ends the test after a few intervals
    initial begin
        #(20 * (HALF + 1) * 6);
        if (flips < 4) begin errs = errs + 1; $display("FAIL: only %0d flips", flips); end
        if (errs == 0) $display("ALL PASS"); else $display("SOME FAILED");
        $finish;
    end

endmodule
