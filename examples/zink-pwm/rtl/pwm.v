// pwm.v - an 8-bit PWM generator. It knows nothing about zink: a clock, a duty value, one output.
//
// A free-running 8-bit counter counts 0..255. The output is high while the counter is below duty,
// so over every 256 clocks the output is high for exactly `duty` clocks:
//   duty = 0    always low (off)
//   duty = 128  high half the time
//   duty = 255  high 255 of 256 clocks (almost always on)
// At 50 MHz one period is 5.12 us (195 kHz), far too fast for the eye to see, so an LED just looks dimmer or brighter.

`default_nettype none

module pwm (
    input  wire       clk,   // fabric clock
    input  wire [7:0] duty,  // 0 = off, 255 = almost fully on
    output wire       out    // PWM output, active high
);

    // Free-running period counter (wraps from 255 to 0).
    reg [7:0] count = 8'd0;

    // Count up every clock.
    always @(posedge clk) begin
        // Wraps by itself at 8 bits.
        count <= count + 8'd1;
    end

    // High while the counter is below the duty value.
    assign out = (count < duty);

endmodule

`default_nettype wire
