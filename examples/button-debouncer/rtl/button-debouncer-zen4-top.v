// button-debouncer-zen4-top.v - board top for button_debouncer on the Zen 4: both on-board buttons are debounced and shown on the LEDs.
// Pressing a button lights its LED once the press has been steady for 10 ms. Fabric clock is 50 MHz (PLL x16 / 16).

module button_debouncer_zen4_top (
    input  wire clk,    // 50 MHz fabric clock from the PLL
    input  wire btn1,   // Button 1, active low
    input  wire btn2,   // Button 2, active low
    output wire led1,   // LED 1, active low: follows button 1
    output wire led2    // LED 2, active low: follows button 2
);

    // Debounced outputs, 1 = pressed
    wire [1:0] deb;

    // This contains the instantiation for the two debouncers (raw input is 1 when pressed)
    button_debouncer #(.NUM_PORTS(2), .DEBOUNCE_CNT_LIMIT(500_000)) u_deb (.clk(clk), .i_pulse({~btn2, ~btn1}), .o_pulse(deb));

    // LEDs sink current: a low pin lights them
    assign led1 = ~deb[0];
    assign led2 = ~deb[1];

endmodule
