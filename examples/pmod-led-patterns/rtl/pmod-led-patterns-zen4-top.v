// pmod-led-patterns-zen4-top.v - board top for pmod_led_patterns on the Zen 4: eight header pads run the patterns, LED 1 mirrors bit 0.
// Fabric clock is 50 MHz (PLL x16 / 16).

module pmod_led_patterns_zen4_top (
    input  wire       clk,       // 50 MHz fabric clock from the PLL
    output wire [7:0] led_pmod,  // Header pads for an 8-LED PMOD module, active high
    output wire       led1       // On-board LED 1, active low
);

    // This contains the instantiation for the pattern generator
    pmod_led_patterns #(.CLK_HZ(50_000_000)) u_pat (.clk(clk), .led_pmod(led_pmod));

    // LED 1 sinks current: a low pin lights it
    assign led1 = ~led_pmod[0];

endmodule
