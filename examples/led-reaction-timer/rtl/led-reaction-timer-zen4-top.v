// led-reaction-timer-zen4-top.v - board top for led_reaction_timer on the Zen 4: press button 1 to start a round, LED 1 lights after a random 0 to 5.5 s delay.
// o_signal goes to a header pad (active high). Fabric clock is 50 MHz (PLL x16 / 16).

module led_reaction_timer_zen4_top (
    input  wire clk,       // 50 MHz fabric clock from the PLL
    input  wire btn1,      // Button 1, active low: trigger
    output wire led1,      // LED 1, active low: lit when the delay is over
    output wire o_signal   // Header pad, active high
);

    // LED level from the core
    wire o_led;

    // This contains the instantiation for the reaction timer (the trigger is 1 while the button is pressed)
    led_reaction_timer #(.DELAY_MOD(275_000_000)) u_rt (.clk(clk), .i_trigger(~btn1), .o_led(o_led), .o_signal(o_signal));

    // LED 1 sinks current: a low pin lights it
    assign led1 = ~o_led;

endmodule
