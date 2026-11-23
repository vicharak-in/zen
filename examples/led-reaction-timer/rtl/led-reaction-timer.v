// Ported from the Vicharak Shrike examples (GPL-2.0) to the Zen 4 (Trion T4F81); logic unchanged, Renesas pad/enable ports removed.
// led-reaction-timer.v - press the trigger, wait a random delay (0 to about 5.5 s at 50 MHz), then the LED and signal pin go high.
// Change from the Shrike version: the "% 275_000_000" is written as one conditional subtraction, which is exactly the same for a 29-bit value
// (2^29 < 2 * 275_000_000) and avoids a divider. RAND_BITS must satisfy DELAY_MOD <= 2^RAND_BITS <= 2 * DELAY_MOD for the fold to be a true modulo.

module led_reaction_timer #(
    parameter DELAY_MOD = 275_000_000, // Delay range in clocks
    parameter RAND_BITS = 29           // Random bits used (29 for the default range; the testbench uses fewer for a short range)
) (
    input  wire clk,        // Fabric clock
    input  wire i_trigger,  // Trigger input, active high (a rising edge starts a round)
    output wire o_led,      // Goes low on trigger and high when the delay ends
    output wire o_signal    // Same as o_led, for an external signal
);

    // Free-running counter, its value at the press seeds the random number
    reg [31:0] r_free_ctr = 32'd0;
    // Two-flop synchroniser for the trigger
    reg [1:0] r_trig_sync = 2'b00;
    // Pseudo-random shift register
    reg [31:0] r_lfsr = 32'h12345678;
    // Remaining delay in clocks
    reg [28:0] r_delay = 29'd0;
    // High while the delay runs
    reg r_running = 1'b0;
    // LED level
    reg r_led = 1'b0;

    // Rising edge of the synchronised trigger
    wire w_trig_rise = r_trig_sync[0] & ~r_trig_sync[1];
    // LFSR feedback bit
    wire w_fb = r_lfsr[31] ^ r_lfsr[21] ^ r_lfsr[1] ^ r_lfsr[0];
    // Random value folded into the delay range (same result as modulo DELAY_MOD for 29-bit values)
    wire [28:0] w_rand = ({{(29-RAND_BITS){1'b0}}, r_lfsr[RAND_BITS-1:0]} >= DELAY_MOD) ? ({{(29-RAND_BITS){1'b0}}, r_lfsr[RAND_BITS-1:0]} - DELAY_MOD) : {{(29-RAND_BITS){1'b0}}, r_lfsr[RAND_BITS-1:0]};

    // This block runs the free counter and synchronises the trigger
    always @(posedge clk) begin
        // Free-running counter
        r_free_ctr <= r_free_ctr + 1'b1;
        // Synchronise the trigger input
        r_trig_sync <= {r_trig_sync[0], i_trigger};
    end

    // This block seeds the LFSR from the free counter at each press and shifts it otherwise
    always @(posedge clk) begin
        // New round: seed from the free counter (a fixed value if it happens to be zero)
        if (w_trig_rise) r_lfsr <= (r_free_ctr == 0) ? 32'h12345678 : r_free_ctr;
        // Otherwise keep shifting
        else r_lfsr <= {r_lfsr[30:0], w_fb};
    end

    // This block starts the delay on a press and counts it down
    always @(posedge clk) begin
        // New round: load the delay and switch the LED off
        if (w_trig_rise) begin
            r_delay   <= w_rand;
            r_running <= 1'b1;
            r_led     <= 1'b0;
        // Delay running
        end else if (r_running) begin
            // Delay over: LED on
            if (r_delay == 0) begin
                r_led     <= 1'b1;
                r_running <= 1'b0;
            // Still counting down
            end else begin
                r_delay <= r_delay - 1'b1;
            end
        end
    end

    // LED and signal outputs
    assign o_led    = r_led;
    assign o_signal = r_led;

endmodule
