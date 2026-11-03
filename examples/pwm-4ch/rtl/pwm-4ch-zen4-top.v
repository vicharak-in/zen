// pwm-4ch-zen4-top.v - board top for pwm_4ch on the Zen 4: eight header pads (LED 0..3 breathe in turn, LED 4..7 blink), LED 1 shows channel 0 and LED 2 shows channel 4.
// btn1 restarts the sequence. Fabric clock is 50 MHz (PLL x16 / 16); the Shrike version assumed 44.5 MHz.

module pwm_4ch_zen4_top (
    input  wire       clk,    // 50 MHz fabric clock from the PLL
    input  wire       btn1,   // Button 1, active low: restart
    output wire [7:0] led,    // Header pads for eight LEDs, active high
    output wire       led1,   // On-board LED 1, active low: channel 0
    output wire       led2    // On-board LED 2, active low: channel 4
);

    // Power-on reset counter: the engine is held in reset for 255 clocks after configuration
    reg [7:0] por = 8'd0;
    // Two-flop synchroniser for the button (released = 1)
    reg [1:0] btn_sync = 2'b11;
    // Active-low reset: power-on counter running or button pressed
    wire nreset = (por == 8'hFF) & btn_sync[1];

    // This block runs the power-on counter and the button synchroniser
    always @(posedge clk) begin
        if (por != 8'hFF) por <= por + 8'd1;  // Count until the end value, then stay
        btn_sync <= {btn_sync[0], btn1};      // Synchronise the button
    end

    // This contains the instantiation for the four-channel demo
    pwm_4ch #(.IN_CLK_HZ(50_000_000), .DEPTH(8)) u_pwm (.nreset(nreset), .clk(clk), .led(led));

    // LEDs sink current: a low pin lights them
    assign led1 = ~led[0];
    assign led2 = ~led[4];

endmodule
