// breathing-led-zen4-top.v - board top for breathing_led on the Zen 4: LED 1 breathes (100 Hz PWM, 8-bit duty ramp). btn1 resets it.
// Fabric clock is 50 MHz (PLL x16 / 16).

module breathing_led_zen4_top (
    input  wire clk,    // 50 MHz fabric clock from the PLL
    input  wire btn1,   // Button 1, active low: reset
    output wire led1    // LED 1, active low
);

    // Power-on reset counter: the controller is held in reset for 255 clocks after configuration
    reg [7:0] por = 8'd0;
    // Two-flop synchroniser for the button (pressed = 1)
    reg [1:0] btn_sync = 2'b00;
    // Controller reset: power-on counter running or button pressed
    wire rst = (por != 8'hFF) | btn_sync[1];
    // PWM output, 1 = LED on
    wire pwm;

    // This block runs the power-on counter and the button synchroniser
    always @(posedge clk) begin
        if (por != 8'hFF) por <= por + 8'd1;  // Count until the end value, then stay
        btn_sync <= {btn_sync[0], ~btn1};     // Button is active low
    end

    // This contains the instantiation for the breathing controller
    breathing_led #(.IN_CLK_HZ(50_000_000), .DEPTH(8), .PWM_FREQ_HZ(100), .RAMP_MULT(2)) u_br (.i_clk(clk), .i_rst(rst), .i_en(1'b1), .o_out(pwm));

    // LED 1 sinks current: a low pin lights it
    assign led1 = ~pwm;

endmodule
