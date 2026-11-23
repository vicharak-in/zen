// pll-counter.v - 4-bit counter on the PLL clock with a selectable rate, port of the Shrike pll_oscillator example (Renesas AN-003 "How to drive PLL from OSC", GPL-2.0).
//
// The Shrike example drives the SLG47910 PLL through the PLL_CTRL_* pins (select, bypass, REFDIV/FBDIV/POSTDIV) and counts on the PLL output.
// The Trion T4F81 PLL has fixed settings chosen in Efinity (no run-time control pins), so the run-time part is done in fabric instead:
// `rate` picks how many fabric clocks one counter step takes, which gives the same visible effect (the counter pins change frequency while the design runs).
// rate 0 = every clock (the "bypass" case, the counter pin 0 toggles at clk / 2), 1 = clk / 4 steps, 2 = clk / 16, 3 = clk / 64.

module pll_counter (
    input  wire       clk,     // PLL output clock
    input  wire       rst_n,   // Active low reset
    input  wire [1:0] rate,    // Counter step rate, 0 = fastest
    output reg  [3:0] counter  // Free-running counter
);

    // Prescaler
    reg [5:0] pre = 6'd0;
    // Prescaler terminal count for the selected rate
    wire [5:0] top = (rate == 2'd0) ? 6'd0 : (rate == 2'd1) ? 6'd3 : (rate == 2'd2) ? 6'd15 : 6'd63;

    // This block runs the prescaler and the counter
    always @(posedge clk) begin
        if (!rst_n) begin
            pre     <= 6'd0;
            counter <= 4'd0;
        end else if (pre >= top) begin
            pre     <= 6'd0;
            counter <= counter + 4'd1;
        end else
            pre <= pre + 6'd1;
    end

endmodule
