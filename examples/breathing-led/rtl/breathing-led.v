// Ported from the Vicharak Shrike examples (GPL-2.0) to the Zen 4 (Trion T4F81); logic unchanged, Renesas pad/enable ports removed.
// (c) 2023 Renesas Electronics
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
// OR OTHER DEALINGS IN THE SOFTWARE.
//
// breathing-led.v - PWM breathing LED controller. The controller is the Renesas ForgeFPGA "mcm_breathing_ctrl" macro (MacrocellMode), unchanged;
// the Shrike wrapper that inverted the reset is folded into the port: i_rst is active high here.

module breathing_led #(
    parameter IN_CLK_HZ   = 50_000_000,  // Input clock in Hz
    parameter DEPTH       = 8,           // Depth of the PWM counter in bits
    parameter PWM_FREQ_HZ = 100,         // PWM frequency in Hz
    parameter RAMP_MULT   = 2            // Ramp multiplier
) (
    input  wire i_clk,   // Fabric clock
    input  wire i_rst,   // Reset, active high
    input  wire i_en,    // Enable
    output reg  o_out    // PWM output
);

    // Clocks per PWM step minus the divider reload
    localparam CNT_SLOW = IN_CLK_HZ / PWM_FREQ_HZ / (2**DEPTH);
    // Width of the slow counter
    localparam CNT_SLOW_WIDTH = $clog2(CNT_SLOW);
    // Width of the ramp counter
    localparam CNT_RAMP_WIDTH = $clog2(RAMP_MULT);

    // One-clock enable for the PWM counter
    reg                      r_clk_en   = 1'b0;
    // Slow counter that divides the clock
    reg [CNT_SLOW_WIDTH-1:0] r_cnt_slow = 'h0;
    // PWM counter
    reg [DEPTH-1:0]          r_cnt_pwm  = 'h0;
    // Duty value
    reg [DEPTH-1:0]          r_cnt_duty = 'h0;
    // Ramp counter
    reg [CNT_RAMP_WIDTH:0]   r_cnt_ramp = 'h0;
    // Ramp direction
    reg                      r_dir      = 1'b0;

    // This block divides the clock to make the PWM enable pulse
    always @(posedge i_clk) begin
        // Reset
        if (i_rst) begin
            r_cnt_slow <= 'h0;
            r_clk_en   <= 1'b0;
        end else begin
            if (i_en) begin
                // Default: no pulse
                r_clk_en <= 1'b0;
                // Count up to CNT_SLOW
                if (r_cnt_slow < CNT_SLOW) begin
                    r_cnt_slow <= r_cnt_slow + 1;
                // Reload and pulse
                end else begin
                    r_cnt_slow <= 'h0;
                    r_clk_en   <= 1'b1;
                end
            end
        end
    end

    // This block runs the PWM counter, the ramp counter, the duty value and the direction
    always @(posedge i_clk) begin
        // Reset
        if (i_rst) begin
            r_cnt_pwm  <= 'h0;
            r_cnt_ramp <= 'h0;
            r_cnt_duty <= 'h0;
            r_dir      <= 1'b0;
        end else begin
            if (i_en) begin
                if (r_clk_en) begin
                    // PWM counter step
                    r_cnt_pwm <= r_cnt_pwm + 1;
                    // End of a PWM period
                    if (&r_cnt_pwm) begin
                        r_cnt_pwm  <= 'h0;
                        r_cnt_ramp <= r_cnt_ramp + 1;
                        // End of a ramp step
                        if (r_cnt_ramp >= (RAMP_MULT-1)) begin
                            r_cnt_ramp <= 'h0;
                            r_cnt_duty <= r_cnt_duty + 1;
                            // Duty wrapped: turn around
                            if (&r_cnt_duty) begin
                                r_cnt_duty <= 'h0;
                                r_dir      <= ~r_dir;
                            end
                        end
                    end
                end
            end
        end
    end

    // This block makes the PWM output
    always @(posedge i_clk) begin
        // Reset
        if (i_rst) begin
            o_out <= 1'b0;
        end else begin
            if (i_en) begin
                // Rising ramp: high while pwm < duty; falling ramp: the inverse
                o_out <= (r_dir == 0) ? ((r_cnt_pwm < r_cnt_duty) ? 1:0) : ((r_cnt_pwm < r_cnt_duty) ? 0:1);
            end else begin
                o_out <= 1'b0;
            end
        end
    end

    // PWM output starts low
    initial o_out = 1'b0;

endmodule
