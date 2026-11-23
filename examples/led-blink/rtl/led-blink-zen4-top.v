// led-blink-zen4-top.v - board top for led_blink on the Vicharak Zen 4 (Trion T4F81): blinks LED 1 once per second.
// Fabric clock is 50 MHz (50 MHz oscillator on GPIOL_20 through the PLL, x16 / 16, set up in Efinity Interface Designer).

module led_blink_zen4_top (
    input  wire clk,  // 50 MHz fabric clock from the PLL
    output wire led1  // LED 1, active low: a low pin lights it
);

    // LED level from the core, 1 = on
    wire led;

    // This contains the instantiation for the blinker
    led_blink #(.HALF_CLKS(50_000_000)) u_blink (.clk(clk), .led(led));

    // LED 1 sinks current: a low pin lights it
    assign led1 = ~led;

endmodule
