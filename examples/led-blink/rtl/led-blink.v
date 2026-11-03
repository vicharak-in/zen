// Ported from the Vicharak Shrike examples (GPL-2.0) to the Zen 4 (Trion T4F81); logic unchanged, Renesas pad/enable ports removed.
// led-blink.v - toggles an LED once per second (50 MHz clock)

module led_blink #(
    parameter HALF_CLKS = 50_000_000 // Clocks between two toggles (the counter runs one clock past this value)
) (
    input  wire clk, // Fabric clock
    output wire led  // LED level, 1 = on
);

    // Free-running clock counter
    reg [31:0] counter = 32'd0;
    // LED state
    reg led_status = 1'b0;

    // This block counts clocks and toggles the LED when the counter reaches HALF_CLKS
    always @(posedge clk) begin
        // Count one clock
        counter <= counter + 1'b1;
        // End of the interval
        if (counter == HALF_CLKS) begin
            // Flip the LED
            led_status <= !led_status;
            // Start the next interval
            counter <= 32'b0;
        end
    end

    // Drive the LED output from the state register
    assign led = led_status;

endmodule
