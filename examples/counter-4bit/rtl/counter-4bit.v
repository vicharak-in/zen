// Ported from the Vicharak Shrike examples (GPL-2.0) to the Zen 4 (Trion T4F81); logic unchanged, Renesas pad/enable ports removed.
// counter-4bit.v - 4-bit up/down counter that steps once per second at 50 MHz (up_down = 1 counts up)

module counter_4bit #(
    parameter TICK_CLKS = 50_000_000 // Clocks per count step
) (
    input  wire       clk,      // Fabric clock
    input  wire       nreset,   // Active-low asynchronous reset
    input  wire       up_down,  // 1 = count up, 0 = count down
    output wire [3:0] count     // Counter value
);

    // Counter value register
    reg [3:0] counter_reg;
    // Clocks elapsed in the current step
    reg [25:0] time_steps;

    // Counter value to the output
    assign count = counter_reg;

    // This block waits TICK_CLKS clocks and then steps the counter up or down
    always @(posedge clk or negedge nreset) begin
        // Reset branch
        if (!nreset) begin
            counter_reg <= 4'h0;   // Start at zero
            time_steps  <= 26'd0;  // Restart the step timer
        end else begin
            // End of the step
            if (time_steps >= TICK_CLKS - 1) begin
                time_steps <= 26'd0;                       // Restart the step timer
                if (up_down) counter_reg <= counter_reg + 4'd1;   // Count up
                else         counter_reg <= counter_reg - 4'd1;   // Count down
            end else begin
                time_steps <= time_steps + 26'd1;          // Keep waiting
            end
        end
    end

endmodule
