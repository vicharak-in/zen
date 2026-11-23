// tb-pwm-4ch.v - self-checking testbench at 80 kHz fabric clock and 3-bit depth: LED 0..3 must be active one after the other,
// never at the same time as another channel, and LED 4..7 must each blink five times (the original's behaviour: five high pulses per blink phase)

`timescale 1ns/1ps

module tb_pwm_4ch;

    // Clock
    reg clk = 1'b0;
    // Active-low reset
    reg nreset = 1'b0;
    // LED outputs
    wire [7:0] led;
    // Error counter
    integer errs = 0;
    // Number of clocks each LED was high
    integer hi [0:7];
    // Rising edges per LED
    integer rise [0:7];
    // Previous LED value
    reg [7:0] prev = 8'd0;
    // Loop variables
    integer i, k;

    // 50 MHz clock
    always #10 clk = ~clk;

    // This contains the instantiation for the design under test
    pwm_4ch #(.IN_CLK_HZ(80_000), .DEPTH(3)) dut (.nreset(nreset), .clk(clk), .led(led));

    // This block counts high clocks and rising edges, and checks that LED n is only active in phase n
    always @(posedge clk) begin
        for (k = 0; k < 8; k = k + 1) begin
            if (led[k]) hi[k] = hi[k] + 1;
            if (led[k] && !prev[k]) rise[k] = rise[k] + 1;
            // An LED may only be active while its own phase (or, for the blink LEDs, any phase from 4 on) is enabled; breathing LEDs only in their own phase
            if (nreset && k < 4 && led[k] && dut.seq_counter != k) begin
                // The PWM output register lags the phase by a clock or two, so allow the first clocks after the switch
                if (dut.seq_counter != k + 1 || hi[k+1] > 0) begin errs = errs + 1; $display("FAIL: LED %0d active in phase %0d", k, dut.seq_counter); end
            end
        end
        prev <= led;
    end

    // This block runs the test
    initial begin
        for (i = 0; i < 8; i = i + 1) begin hi[i] = 0; rise[i] = 0; end
        repeat (10) @(posedge clk);
        nreset = 1'b1;
        // Four breathing phases (about 100k clocks each at most) plus the four blink phases (400k + 200k + 100k + 50k clocks) plus margin
        repeat (1_500_000) @(posedge clk);
        for (i = 0; i < 4; i = i + 1) if (hi[i] == 0) begin errs = errs + 1; $display("FAIL: breathing LED %0d never lit", i); end
        for (i = 4; i < 8; i = i + 1) if (rise[i] < 5) begin errs = errs + 1; $display("FAIL: blink LED %0d rose only %0d times", i, rise[i]); end
        if (dut.seq_counter !== 3'd4) begin errs = errs + 1; $display("FAIL: sequence counter %0d, expected 4", dut.seq_counter); end
        if (errs == 0) $display("ALL PASS"); else $display("SOME FAILED");
        $finish;
    end

endmodule
