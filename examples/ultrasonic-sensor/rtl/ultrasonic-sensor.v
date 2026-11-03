// ultrasonic-sensor.v - HC-SR04 style range detector: sends a 10 us trigger every 60 ms, times the echo, and reports whether the object is closer than MAX_DIST_CM.
// Original: (c) Vicharak Computers PVT LTD 2025, Upendra Reddi (Shrike-Lite example). Ported to the Zen 4 with the logic unchanged.
// Changes from the Shrike version:
//   - MAX_COUNT is computed with integer maths (the original used the real number 0.0343 / 2) and gives the same 58309 clocks for 20 cm at 50 MHz
//   - the 60 ms trigger period is written as CLK_FREQ / 1_000_000 * 60_000 so it cannot overflow a 32-bit integer
//   - DEBOUNCE_CNT_LIMIT is a parameter (default 500_000 clocks = 10 ms at 50 MHz) so the testbench can shorten it
//   - object_detected starts at 0
// The echo input must already be synchronised to clk (the board top does this).

module ultrasonic_sensor #(
    parameter CLK_FREQ          = 50_000_000, // Fabric clock in Hz
    parameter TRIG_PULSE_US     = 10,         // Trigger pulse width in microseconds
    parameter MAX_DIST_CM       = 20,         // Objects closer than this count as detected
    parameter DEBOUNCE_CNT_LIMIT = 500_000    // Clocks a new result must hold before the output follows
) (
    input  wire clk,                    // Fabric clock
    input  wire echo,                   // Echo from the sensor (synchronised)
    output reg  trig,                   // Trigger to the sensor
    output reg  object_detected = 1'b0  // High when an object is in range
);

    // Largest echo length in clocks: distance * 2 / (0.0343 cm per us) * clocks per us, in integer form (the sound speed 0.0343 cm/us is 343 / 10000)
    localparam MAX_COUNT = (MAX_DIST_CM * 20000 * (CLK_FREQ / 1_000_000)) / 343;
    // Trigger period in clocks (60 ms)
    localparam TRIG_PERIOD = (CLK_FREQ / 1_000_000) * 60_000;
    // Trigger pulse width in clocks
    localparam TRIG_CLKS = TRIG_PULSE_US * (CLK_FREQ / 1_000_000);

    // Length of the echo being measured
    reg [31:0] echo_count = 0;
    // Echo one clock ago, for the edge detect
    reg        echo_prev = 0;
    // Clock counter of the trigger period
    reg [31:0] trig_counter = 0;
    // Raw detection result of the last echo
    reg        detect = 0;
    // Debounce counter
    reg [31:0] debounce_clk_cnt = 0;

    // This block generates the trigger pulse (TRIG_PULSE_US every 60 ms)
    always @(posedge clk) begin
        if (trig_counter < TRIG_PERIOD) trig_counter <= trig_counter + 1;
        else trig_counter <= 0;

        if (trig_counter < TRIG_CLKS) trig <= 1;
        else trig <= 0;
    end

    // This block measures the echo pulse
    always @(posedge clk) begin
        echo_prev <= echo;

        // Rising edge of echo: start counting. While echo is high: keep counting
        if (~echo_prev && echo) echo_count <= 0;
        else if (echo) echo_count <= echo_count + 1;

        // Falling edge of echo: compare with the limit
        if (echo_prev && ~echo) begin
            if (echo_count <= MAX_COUNT) detect <= 1;
            else detect <= 0;
        end
    end

    // This block removes glitches: the output follows the result only after it has been stable for DEBOUNCE_CNT_LIMIT clocks
    always @(posedge clk) begin
        if ((object_detected != detect) && (debounce_clk_cnt < DEBOUNCE_CNT_LIMIT)) begin
            debounce_clk_cnt <= debounce_clk_cnt + 1;
        end else if (debounce_clk_cnt == DEBOUNCE_CNT_LIMIT) begin
            object_detected <= detect;
            debounce_clk_cnt <= 0;
        end else begin
            debounce_clk_cnt <= 0;
        end
    end

endmodule
