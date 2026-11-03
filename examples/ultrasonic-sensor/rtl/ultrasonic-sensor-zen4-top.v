// ultrasonic-sensor-zen4-top.v - board top for ultrasonic_sensor on the Zen 4: one HC-SR04 on three header pads, LED 1 lights when an object is in range.
// The HC-SR04 runs on 5 V: use a level shifter (or divider) on echo, the header pads are 3.3 V only.
// Fabric clock is 50 MHz (PLL x16 / 16).

module ultrasonic_sensor_zen4_top (
    input  wire clk,              // 50 MHz fabric clock from the PLL
    input  wire echo,             // Header pad: echo from the sensor (level shifted)
    output wire trig,             // Header pad: trigger to the sensor
    output wire object_detected,  // Header pad: object in range
    output wire led1              // On-board LED 1, active low: object in range
);

    // Two-flop synchroniser for the asynchronous echo input
    reg [1:0] echo_sync = 2'b00;

    // This block synchronises the echo input
    always @(posedge clk) echo_sync <= {echo_sync[0], echo};

    // This contains the instantiation for the sensor
    ultrasonic_sensors #(.NUM_SENSORS(1), .CLK_FREQ(50_000_000), .TRIG_PULSE_US(10), .MAX_DIST_CM(20)) u_us (
        .clk(clk), .echo(echo_sync[1]), .trig(trig), .object_detected(object_detected));

    // LED 1 sinks current: a low pin lights it
    assign led1 = ~object_detected;

endmodule
