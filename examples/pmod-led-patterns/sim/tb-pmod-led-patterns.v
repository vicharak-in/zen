// tb-pmod-led-patterns.v - self-checking testbench at CLK_HZ = 1000: every pattern must run, the outputs must never be X,
// and pattern 0 (blink) may only show 00 or FF in the first cycle.

`timescale 1ns/1ps

module tb_pmod_led_patterns;

    // Scaled clock rate: all intervals shrink by 50000
    localparam HZ = 1000;
    // Clock
    reg clk = 1'b0;
    // Outputs of the design
    wire [7:0] led;
    // Error counter
    integer errs = 0;
    // Patterns seen (bit i set when pattern i changed the LEDs)
    reg [7:0] seen = 8'd0;
    // Previous LED value
    reg [7:0] prev_led = 8'd0;

    // 50 MHz clock
    always #10 clk = ~clk;

    // This contains the instantiation for the design under test
    pmod_led_patterns #(.CLK_HZ(HZ)) dut (.clk(clk), .led_pmod(led));

    // This block checks the invariants every clock
    always @(posedge clk) begin
        // Outputs must be known
        if (^led === 1'bx) begin errs = errs + 1; $display("FAIL: X on led at %0t", $time); end
        // Record which pattern produced a change
        if (led !== prev_led) seen[dut.pattern_select] <= 1'b1;
        // In the first cycle the blink pattern only shows all-off or all-on (later cycles start from the leftover of pattern 7, as in the original)
        if (dut.pattern_select == 3'd0 && $time < 20 * (HZ * 3 / 2) && led !== 8'h00 && led !== 8'hFF) begin errs = errs + 1; $display("FAIL: blink pattern shows %h", led); end
        // Remember the value
        prev_led <= led;
    end

    // This block runs the simulation long enough for two full pattern cycles
    initial begin
        #(20 * (HZ * 3 / 2) * 17);
        if (seen !== 8'hFF) begin errs = errs + 1; $display("FAIL: patterns that never changed the LEDs: %b", ~seen); end
        if (errs == 0) $display("ALL PASS"); else $display("SOME FAILED");
        $finish;
    end

endmodule
