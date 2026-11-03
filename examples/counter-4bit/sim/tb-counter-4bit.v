// tb-counter-4bit.v - self-checking testbench: counts up, wraps, counts down, and resets asynchronously

`timescale 1ns/1ps

module tb_counter_4bit;

    // Short step so the test is quick
    localparam TICK = 8;
    // Clock
    reg clk = 1'b0;
    // Active-low reset
    reg nreset = 1'b0;
    // Direction
    reg up_down = 1'b1;
    // Counter output
    wire [3:0] count;
    // Error counter
    integer errs = 0;
    // Loop variable
    integer i;
    // Value seen before a step
    reg [3:0] prev_v;

    // 50 MHz clock
    always #10 clk = ~clk;

    // This contains the instantiation for the design under test
    counter_4bit #(.TICK_CLKS(TICK)) dut (.clk(clk), .nreset(nreset), .up_down(up_down), .count(count));

    // This task waits one full step
    task step;
        begin
            repeat (TICK) @(posedge clk);
            #1;
        end
    endtask

    // This block runs the tests
    initial begin
        #55;
        // In reset the count must be zero
        if (count !== 4'd0) begin errs = errs + 1; $display("FAIL: not zero in reset (%0d)", count); end
        // Release reset
        nreset = 1'b1;
        // Count up through the wrap (18 steps)
        for (i = 1; i <= 18; i = i + 1) begin
            prev_v = count;
            step;
            if (count !== prev_v + 4'd1) begin errs = errs + 1; $display("FAIL: up step %0d: %0d -> %0d", i, prev_v, count); end
        end
        // Count down through the wrap (18 steps)
        up_down = 1'b0;
        for (i = 1; i <= 18; i = i + 1) begin
            prev_v = count;
            step;
            if (count !== prev_v - 4'd1) begin errs = errs + 1; $display("FAIL: down step %0d: %0d -> %0d", i, prev_v, count); end
        end
        // Asynchronous reset clears the counter without waiting for a clock edge
        nreset = 1'b0;
        #1;
        if (count !== 4'd0) begin errs = errs + 1; $display("FAIL: async reset (%0d)", count); end
        if (errs == 0) $display("ALL PASS"); else $display("SOME FAILED");
        $finish;
    end

endmodule
