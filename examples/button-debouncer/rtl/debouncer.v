// Ported from the Vicharak Shrike examples (GPL-2.0) to the Zen 4 (Trion T4F81); logic unchanged, Renesas pad/enable ports removed.
// debouncer.v - one-channel switch debouncer: the output only follows the input after the input has been steady for DEBOUNCE_CNT_LIMIT clocks
// Original author: Upendra Reddi (Vicharak Computers); the stray comma in the port list is removed.

module debouncer #(
    parameter DEBOUNCE_CNT_LIMIT = 500_000 // Steady time in clocks (10 ms at 50 MHz)
) (
    input  wire clk,      // Fabric clock
    input  wire i_pulse,  // Raw switch input
    output wire o_pulse   // Debounced output
);

    // Width of the steady-time counter
    localparam CNT_WIDTH = $clog2(DEBOUNCE_CNT_LIMIT + 1);

    // Clocks the input has differed from the output
    reg [CNT_WIDTH-1:0] r_clk_cnt = 0;
    // Debounced value
    reg r_pulse = 1'b0;

    // Debounced value to the output
    assign o_pulse = r_pulse;

    // This block times how long the input differs from the output and accepts it once it is steady
    always @(posedge clk) begin
        // Input differs and the timer is still running: count
        if ((i_pulse != r_pulse) && (r_clk_cnt < DEBOUNCE_CNT_LIMIT)) begin
            r_clk_cnt <= r_clk_cnt + 1;
        // Timer expired: accept the new value
        end else if (r_clk_cnt == DEBOUNCE_CNT_LIMIT) begin
            r_pulse   <= i_pulse;
            r_clk_cnt <= 0;
        // Input matches the output again (a bounce): restart the timer
        end else begin
            r_clk_cnt <= 0;
        end
    end

endmodule
