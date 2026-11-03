// tb-breathing-led.v - self-checking testbench at a reduced clock and 4-bit depth: the duty must rise during the first half and fall during the second half
// (IN_CLK_HZ is chosen so CNT_SLOW is not a power of two: the controller's slow counter is only $clog2(CNT_SLOW) bits wide, so a power of two would never reload)

`timescale 1ns/1ps

module tb_breathing_led;

    // Clock
    reg clk = 1'b0;
    // Reset
    reg rst = 1'b1;
    // PWM output
    wire out;
    // Error counter
    integer errs = 0;
    // High and total clock counts for four windows: {dir 0, dir 1} x {duty low, duty high}
    integer hi_lo0 = 0, tot_lo0 = 0, hi_hi0 = 0, tot_hi0 = 0, hi_lo1 = 0, tot_lo1 = 0, hi_hi1 = 0, tot_hi1 = 0;

    // 50 MHz clock
    always #10 clk = ~clk;

    // This contains the instantiation for the design under test
    breathing_led #(.IN_CLK_HZ(4800), .DEPTH(4), .PWM_FREQ_HZ(100), .RAMP_MULT(2)) dut (.i_clk(clk), .i_rst(rst), .i_en(1'b1), .o_out(out));

    // This block sorts every clock into a window by direction and duty and counts the high clocks
    always @(posedge clk) begin
        if (!rst) begin
            if (dut.r_dir == 0 && dut.r_cnt_duty <= 3)  begin tot_lo0 = tot_lo0 + 1; hi_lo0 = hi_lo0 + out; end
            if (dut.r_dir == 0 && dut.r_cnt_duty >= 12) begin tot_hi0 = tot_hi0 + 1; hi_hi0 = hi_hi0 + out; end
            if (dut.r_dir == 1 && dut.r_cnt_duty <= 3)  begin tot_lo1 = tot_lo1 + 1; hi_lo1 = hi_lo1 + out; end
            if (dut.r_dir == 1 && dut.r_cnt_duty >= 12) begin tot_hi1 = tot_hi1 + 1; hi_hi1 = hi_hi1 + out; end
        end
    end

    // This block runs two full ramps and checks the fractions
    initial begin
        repeat (10) @(posedge clk);
        rst = 1'b0;
        repeat (16 * 2 * 16 * 4 * 2 + 600) @(posedge clk);
        if (tot_lo0 == 0 || tot_hi0 == 0 || tot_lo1 == 0 || tot_hi1 == 0) begin errs = errs + 1; $display("FAIL: a window was never reached"); end
        // Rising ramp: low duty gives less light than high duty
        if (!(hi_lo0 * tot_hi0 < hi_hi0 * tot_lo0)) begin errs = errs + 1; $display("FAIL: rising ramp not rising (%0d/%0d vs %0d/%0d)", hi_lo0, tot_lo0, hi_hi0, tot_hi0); end
        // Falling ramp: the opposite
        if (!(hi_lo1 * tot_hi1 > hi_hi1 * tot_lo1)) begin errs = errs + 1; $display("FAIL: falling ramp not falling (%0d/%0d vs %0d/%0d)", hi_lo1, tot_lo1, hi_hi1, tot_hi1); end
        // Reset forces the output low
        rst = 1'b1;
        repeat (3) @(posedge clk);
        if (out !== 1'b0) begin errs = errs + 1; $display("FAIL: output not low in reset"); end
        if (errs == 0) $display("ALL PASS"); else $display("SOME FAILED");
        $finish;
    end

endmodule
