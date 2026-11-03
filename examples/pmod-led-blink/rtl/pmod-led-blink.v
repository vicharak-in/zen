// Ported from the Vicharak Shrike examples (GPL-2.0) to the Zen 4 (Trion T4F81); logic unchanged, Renesas pad/enable ports removed.
// pmod-led-blink.v - toggles all eight PMOD LEDs together once per second

module pmod_led_blink #(
    parameter HALF_CLKS = 50_000_000 // Clocks between two toggles
) (
    input  wire       clk,      // Fabric clock
    output wire [7:0] led_pmod  // LED levels, 1 = on
);

    // Free-running clock counter
    reg [31:0] counter = 32'd0;
    // LED pattern, all eight bits toggle together
    reg [7:0] led = 8'd0;

    // This block counts clocks and inverts the pattern when the counter reaches HALF_CLKS
    always @(posedge clk) begin
        // Count one clock
        counter <= counter + 1'b1;
        // End of the interval
        if (counter == HALF_CLKS) begin
            // Flip every LED
            led <= ~led;
            // Start the next interval
            counter <= 32'b0;
        end
    end

    // Drive the PMOD pins from the pattern register
    assign led_pmod = led;

endmodule
