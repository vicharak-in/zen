// tb-led-reaction-timer.v - self-checking testbench: after a trigger the LED goes low and returns high within DELAY_MOD clocks,
// the delay differs between presses, and it matches the original modulo for a sweep of values.

`timescale 1ns/1ps

module tb_led_reaction_timer;

    // Small delay range
    localparam MODV = 1500;
    // Clock
    reg clk = 1'b0;
    // Trigger
    reg trig = 1'b0;
    // Outputs
    wire led, sig;
    // Error counter
    integer errs = 0;
    // Measured delay
    integer d, d1, d2, d3;
    // Loop variable
    integer i;

    // 50 MHz clock
    always #10 clk = ~clk;

    // This contains the instantiation for the design under test
    led_reaction_timer #(.DELAY_MOD(MODV), .RAND_BITS(11)) dut (.clk(clk), .i_trigger(trig), .o_led(led), .o_signal(sig));

    // This task presses the trigger for a few clocks and measures clocks until the LED is high
    task round;
        output integer delay;
        begin
            @(posedge clk); trig = 1'b1;
            repeat (4) @(posedge clk);
            trig = 1'b0;
            delay = 0;
            // LED must drop right after the press
            repeat (2) @(posedge clk);
            if (led !== 1'b0) begin errs = errs + 1; $display("FAIL: LED not low after trigger"); end
            while (led !== 1'b1 && delay < MODV + 50) begin @(posedge clk); delay = delay + 1; end
            if (led !== 1'b1) begin errs = errs + 1; $display("FAIL: LED never came back"); end
            if (sig !== led) begin errs = errs + 1; $display("FAIL: signal differs from LED"); end
            repeat (20) @(posedge clk);
        end
    endtask

    // This block runs the tests
    initial begin
        repeat (1000) @(posedge clk);          // let the free counter run so the seed is not the default
        round(d1);
        repeat (333) @(posedge clk);
        round(d2);
        repeat (777) @(posedge clk);
        round(d3);
        if (d1 > MODV + 5 || d2 > MODV + 5 || d3 > MODV + 5) begin errs = errs + 1; $display("FAIL: delay beyond range %0d %0d %0d", d1, d2, d3); end
        if (d1 == d2 && d2 == d3) begin errs = errs + 1; $display("FAIL: delay did not change between rounds"); end
        // The folded value must equal the modulo of the original for every 11-bit input
        for (i = 0; i < 2048; i = i + 1) begin
            force dut.r_lfsr = i;
            #1;
            if (dut.w_rand !== (i % MODV)) begin errs = errs + 1; $display("FAIL: fold %0d -> %0d, expected %0d", i, dut.w_rand, i % MODV); end
            release dut.r_lfsr;
        end
        if (errs == 0) $display("ALL PASS"); else $display("SOME FAILED");
        $finish;
    end

endmodule
