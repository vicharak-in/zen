// tb-button-debouncer.v - self-checking testbench: bounces shorter than the limit are ignored, a steady level is accepted after the limit

`timescale 1ns/1ps

module tb_button_debouncer;

    // Short limit so the test is quick
    localparam LIMIT = 20;
    // Clock
    reg clk = 1'b0;
    // Raw inputs
    reg [1:0] raw = 2'b00;
    // Debounced outputs
    wire [1:0] deb;
    // Error counter
    integer errs = 0;
    // Loop variable
    integer i;

    // 50 MHz clock
    always #10 clk = ~clk;

    // This contains the instantiation for the design under test
    button_debouncer #(.NUM_PORTS(2), .DEBOUNCE_CNT_LIMIT(LIMIT)) dut (.clk(clk), .i_pulse(raw), .o_pulse(deb));

    // This block runs the tests
    initial begin
        repeat (5) @(posedge clk);
        // Bouncing channel 0: ten short pulses of 5 clocks, each shorter than LIMIT
        for (i = 0; i < 10; i = i + 1) begin
            raw[0] = 1'b1; repeat (5) @(posedge clk);
            raw[0] = 1'b0; repeat (5) @(posedge clk);
        end
        repeat (LIMIT * 2) @(posedge clk);
        if (deb[0] !== 1'b0) begin errs = errs + 1; $display("FAIL: bounce accepted"); end
        // Steady press on channel 0 and channel 1 (channel 1 starts later)
        raw[0] = 1'b1;
        repeat (LIMIT - 3) @(posedge clk);
        if (deb[0] !== 1'b0) begin errs = errs + 1; $display("FAIL: accepted too early"); end
        raw[1] = 1'b1;
        repeat (10) @(posedge clk);
        if (deb[0] !== 1'b1) begin errs = errs + 1; $display("FAIL: steady press not accepted on 0"); end
        if (deb[1] !== 1'b0) begin errs = errs + 1; $display("FAIL: channel 1 accepted too early"); end
        repeat (LIMIT + 5) @(posedge clk);
        if (deb !== 2'b11) begin errs = errs + 1; $display("FAIL: both should be pressed, got %b", deb); end
        // Release both: accepted after the limit
        raw = 2'b00;
        repeat (LIMIT + 5) @(posedge clk);
        if (deb !== 2'b00) begin errs = errs + 1; $display("FAIL: release not accepted, got %b", deb); end
        if (errs == 0) $display("ALL PASS"); else $display("SOME FAILED");
        $finish;
    end

endmodule
