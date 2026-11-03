// ultrasonic-sensors.v - NUM_SENSORS copies of ultrasonic_sensor side by side (the "top" of the Shrike example, renamed and without the pad/enable ports)

module ultrasonic_sensors #(
    parameter NUM_SENSORS        = 1,          // Number of sensors
    parameter CLK_FREQ           = 50_000_000, // Fabric clock in Hz
    parameter TRIG_PULSE_US      = 10,         // Trigger pulse width in microseconds
    parameter MAX_DIST_CM        = 20,         // Detection range in cm
    parameter DEBOUNCE_CNT_LIMIT = 500_000     // Debounce time in clocks
) (
    input  wire                   clk,              // Fabric clock
    input  wire [NUM_SENSORS-1:0] echo,             // Echo inputs (synchronised)
    output wire [NUM_SENSORS-1:0] trig,             // Trigger outputs
    output wire [NUM_SENSORS-1:0] object_detected   // In-range flags
);

    genvar i;
    generate
        for (i = 0; i < NUM_SENSORS; i = i + 1) begin : ULTRASONIC_SENSOR
            // This contains the instantiation for one sensor channel
            ultrasonic_sensor #(.CLK_FREQ(CLK_FREQ), .TRIG_PULSE_US(TRIG_PULSE_US), .MAX_DIST_CM(MAX_DIST_CM), .DEBOUNCE_CNT_LIMIT(DEBOUNCE_CNT_LIMIT)) SENSOR_INST (
                .clk(clk), .echo(echo[i]), .trig(trig[i]), .object_detected(object_detected[i]));
        end
    endgenerate

endmodule
