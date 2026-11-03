// tb-ultrasonic-sensor.v - self-checking testbench at 1 MHz (MAX_COUNT = 1166 clocks for 20 cm): a sensor model answers every trigger with an echo of
// a length the test sets. A short echo must raise object_detected, a long echo must clear it, and the trigger must be 10 clocks wide every 60000 clocks.

`timescale 1ns/1ps

module tb_ultrasonic_sensor;

    // Clock
    reg clk = 1'b0;
    // Echo from the sensor model
    reg echo = 1'b0;
    // Outputs
    wire [0:0] trig, object_detected;
    // Echo length in clocks for the next trigger
    integer echo_len = 800;
    // Error counter
    integer errs = 0;
    // Trigger measurement
    integer trig_hi = 0, trig_since = 0, trig_period = 0, trig_seen = 0;
    // Previous trigger
    reg prev_trig = 1'b0;

    // 1 MHz clock
    always #500 clk = ~clk;

    // This contains the instantiation for the design under test
    ultrasonic_sensors #(.NUM_SENSORS(1), .CLK_FREQ(1_000_000), .TRIG_PULSE_US(10), .MAX_DIST_CM(20), .DEBOUNCE_CNT_LIMIT(50)) dut (
        .clk(clk), .echo(echo), .trig(trig), .object_detected(object_detected));

    // This block is the sensor model: 100 clocks after the trigger falls, send an echo of echo_len clocks
    always @(negedge trig[0]) begin
        repeat (100) @(posedge clk);
        echo = 1'b1;
        repeat (echo_len) @(posedge clk);
        echo = 1'b0;
    end

    // This block measures the trigger pulse width and period
    always @(posedge clk) begin
        prev_trig <= trig[0];
        trig_since = trig_since + 1;
        if (trig[0]) trig_hi = trig_hi + 1;
        if (trig[0] && !prev_trig) begin
            if (trig_seen > 0) trig_period = trig_since;
            trig_since = 0; trig_hi = 1; trig_seen = trig_seen + 1;
        end
        if (!trig[0] && prev_trig && trig_seen > 1) begin
            if (trig_hi != 10) begin errs = errs + 1; $display("FAIL: trigger %0d clocks wide", trig_hi); end
            if (trig_period != 60001 && trig_period != 60000) begin errs = errs + 1; $display("FAIL: trigger period %0d", trig_period); end
        end
    end

    // This block runs the test
    initial begin
        // Short echo (800 < 1166): object present after the first measurement plus debounce
        echo_len = 800;
        repeat (80_000) @(posedge clk);
        if (object_detected !== 1'b1) begin errs = errs + 1; $display("FAIL: short echo did not set object_detected"); end
        // Long echo (2000 > 1166): object gone
        echo_len = 2000;
        repeat (130_000) @(posedge clk);
        if (object_detected !== 1'b0) begin errs = errs + 1; $display("FAIL: long echo did not clear object_detected"); end
        // Short again
        echo_len = 500;
        repeat (130_000) @(posedge clk);
        if (object_detected !== 1'b1) begin errs = errs + 1; $display("FAIL: second short echo did not set object_detected"); end
        if (errs == 0) $display("ALL PASS"); else $display("SOME FAILED");
        $finish;
    end

endmodule
