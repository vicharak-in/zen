// Ported from the Vicharak Shrike examples (GPL-2.0) to the Zen 4 (Trion T4F81); logic unchanged, Renesas pad/enable ports removed.
// The breathing controller below is derived from Renesas ForgeFPGA MacrocellMode output (c) 2023 Renesas Electronics, MIT-style licence as in ../../breathing_led/rtl/breathing_led.v.
//
// pwm-4ch.v - "sequential breathing" demo: LED 0..3 breathe one after the other (50, 100, 500, 1000 Hz PWM), then LED 4..7 blink at 1, 2, 4 and 8 Hz.
// Behaviour kept from the original: after the four breathing phases the sequence counter stays at 4 and the blink phase repeats forever.
// Changes from the Shrike version: the blink intervals scale with IN_CLK_HZ (same values at 50 MHz) and done[7:4] is tied to 0 (it was left undriven).

module pwm_4ch #(
    parameter IN_CLK_HZ = 50_000_000, // Fabric clock in Hz
    parameter DEPTH     = 8           // PWM counter depth in bits
) (
    input  wire       nreset,   // Reset, active low
    input  wire       clk,      // Fabric clock
    output wire [7:0] led       // LED 0..3 breathing, LED 4..7 blinking, active high
);

    // Half periods of the blink phases (1, 2, 4 and 8 Hz)
    localparam BLINK_1HZ = IN_CLK_HZ / 2;
    localparam BLINK_2HZ = IN_CLK_HZ / 4;
    localparam BLINK_4HZ = IN_CLK_HZ / 8;
    localparam BLINK_8HZ = IN_CLK_HZ / 16;

    // Which of the eight phases is enabled
    reg [2:0]  seq_counter  = 3'd0;
    // Clock counter of the blink phases
    reg [26:0] blink_counter = 27'd0;
    // Number of toggles in the current blink phase
    reg [3:0]  blink_count  = 4'd0;
    // State of the blink machine
    reg [2:0]  state        = 3'd0;
    // Blink level
    reg        r_led        = 1'b0;
    // Blink LEDs 4..7
    reg        led_4 = 1'b0, led_5 = 1'b0, led_6 = 1'b0, led_7 = 1'b0;
    // Breathing LEDs 0..3
    wire       led_0, led_1, led_2, led_3;
    // Done pulses of the breathing channels (channels 4..7 do not breathe)
    wire [7:0] done;
    // Any channel finished: move to the next phase
    wire       next = |done;
    // One-hot enable of the current phase
    wire [7:0] en = 8'b1 << seq_counter;

    // Bits 4..7 of done are not driven by a channel
    assign done[7:4] = 4'b0000;
    // Outputs
    assign led = {led_7, led_6, led_5, led_4, led_3, led_2, led_1, led_0};

    // This block steps to the next phase when a channel reports done
    always @(posedge clk) begin
        // Reset
        if (!nreset) seq_counter <= 0;
        // Next phase
        else if (next) seq_counter <= seq_counter + 1;
    end

    // This block runs the blink phases for LED 4..7
    always @(posedge clk) begin
        // Reset
        if (!nreset) begin
            state <= 3'b000; blink_counter <= 0; blink_count <= 0; r_led <= 0;
            led_4 <= 0; led_5 <= 0; led_6 <= 0; led_7 <= 0;
        end else begin
            case (state)
                // Idle: wait for the phase enable of LED 4
                3'b000: begin
                    blink_counter <= 0; blink_count <= 0; r_led <= 0;
                    led_4 <= 0; led_5 <= 0; led_6 <= 0; led_7 <= 0;
                    if (en[4]) state <= 3'b001;
                end
                // LED 4 at 1 Hz
                3'b001: begin
                    if (blink_counter == BLINK_1HZ) begin
                        blink_counter <= 0;
                        r_led <= ~r_led;
                        if (blink_count == 9) begin state <= 3'b010; r_led <= 0; blink_count <= 0; end
                        else blink_count <= blink_count + 1;
                    end else blink_counter <= blink_counter + 1;
                    led_4 <= r_led;
                end
                // LED 5 at 2 Hz
                3'b010: begin
                    if (blink_counter == BLINK_2HZ) begin
                        blink_counter <= 0;
                        r_led <= ~r_led;
                        if (blink_count == 9) begin state <= 3'b011; r_led <= 0; blink_count <= 0; end
                        else blink_count <= blink_count + 1;
                    end else blink_counter <= blink_counter + 1;
                    led_5 <= r_led;
                end
                // LED 6 at 4 Hz
                3'b011: begin
                    if (blink_counter == BLINK_4HZ) begin
                        blink_counter <= 0;
                        r_led <= ~r_led;
                        if (blink_count == 9) begin state <= 3'b100; r_led <= 0; blink_count <= 0; end
                        else blink_count <= blink_count + 1;
                    end else blink_counter <= blink_counter + 1;
                    led_6 <= r_led;
                end
                // LED 7 at 8 Hz, then back to idle
                3'b100: begin
                    if (blink_counter == BLINK_8HZ) begin
                        blink_counter <= 0;
                        r_led <= ~r_led;
                        if (blink_count == 9) begin state <= 3'b000; r_led <= 0; blink_count <= 0; end
                        else blink_count <= blink_count + 1;
                    end else blink_counter <= blink_counter + 1;
                    led_7 <= r_led;
                end
                default: state <= 3'b000;
            endcase
        end
    end

    // This contains the instantiation for breathing channel 0 (50 Hz PWM)
    breathing #(.IN_CLK_HZ(IN_CLK_HZ), .DEPTH(DEPTH), .PWM_FREQ_HZ(50),   .RAMP_MULT(1)) breathing_led0 (.clk(clk), .nreset(nreset), .en(en[0]), .out(led_0), .done(done[0]));
    // This contains the instantiation for breathing channel 1 (100 Hz PWM)
    breathing #(.IN_CLK_HZ(IN_CLK_HZ), .DEPTH(DEPTH), .PWM_FREQ_HZ(100),  .RAMP_MULT(1)) breathing_led1 (.clk(clk), .nreset(nreset), .en(en[1]), .out(led_1), .done(done[1]));
    // This contains the instantiation for breathing channel 2 (500 Hz PWM)
    breathing #(.IN_CLK_HZ(IN_CLK_HZ), .DEPTH(DEPTH), .PWM_FREQ_HZ(500),  .RAMP_MULT(2)) breathing_led2 (.clk(clk), .nreset(nreset), .en(en[2]), .out(led_2), .done(done[2]));
    // This contains the instantiation for breathing channel 3 (1000 Hz PWM)
    breathing #(.IN_CLK_HZ(IN_CLK_HZ), .DEPTH(DEPTH), .PWM_FREQ_HZ(1000), .RAMP_MULT(2)) breathing_led3 (.clk(clk), .nreset(nreset), .en(en[3]), .out(led_3), .done(done[3]));

endmodule

// One breathing channel: the Renesas breathing controller plus a "done" pulse when the duty ramp turns around (custom part of the original)
module breathing #(
    parameter IN_CLK_HZ   = 50_000_000, // Input clock in Hz
    parameter DEPTH       = 8,          // PWM counter depth in bits
    parameter PWM_FREQ_HZ = 400,        // PWM frequency in Hz
    parameter RAMP_MULT   = 1           // Ramp multiplier
) (
    input  wire clk,      // Fabric clock
    input  wire nreset,   // Reset, active low
    input  wire en,       // Enable
    output reg  out,      // PWM output
    output wire done      // One-clock pulse when the ramp finishes
);

    // Clocks per PWM step
    localparam CNT_SLOW = IN_CLK_HZ / PWM_FREQ_HZ / (2**DEPTH);
    // Width of the slow counter
    localparam CNT_SLOW_WIDTH = $clog2(CNT_SLOW);
    // Width of the ramp counter
    localparam CNT_RAMP_WIDTH = $clog2(RAMP_MULT);

    // One-clock enable for the PWM counter
    reg clk_en = 1'b0;
    // Slow counter
    reg [CNT_SLOW_WIDTH-1:0] cnt_slow_reg = 'h0;
    // PWM counter
    reg [DEPTH-1:0] cnt_pwm_reg = 'h0;
    // Duty value
    reg [DEPTH-1:0] cnt_duty_reg = 'h0;
    // Ramp counter
    reg [CNT_RAMP_WIDTH:0] cnt_ramp_reg = 'h0;
    // Ramp direction
    reg dir_reg = 1'b0;
    // Delayed copies of the direction for the falling-edge detect
    reg [1:0] dir_fedge = 2'b00;

    // This block divides the clock to make the PWM enable pulse
    always @(posedge clk) begin
        if (!nreset) begin
            cnt_slow_reg <= 'h0;
            clk_en <= 1'b0;
        end else begin
            if (en) begin
                clk_en <= 1'b0;
                if (cnt_slow_reg < CNT_SLOW) cnt_slow_reg <= cnt_slow_reg + 1;
                else begin cnt_slow_reg <= 'h0; clk_en <= 1'b1; end
            end
        end
    end

    // This block runs the PWM counter, the ramp counter, the duty value and the direction
    always @(posedge clk) begin
        if (!nreset) begin
            cnt_pwm_reg <= 'h0; cnt_ramp_reg <= 'h0; cnt_duty_reg <= 'h0; dir_reg <= 1'b0;
        end else begin
            if (en) begin
                if (clk_en) begin
                    cnt_pwm_reg <= cnt_pwm_reg + 1;
                    if (&cnt_pwm_reg) begin
                        cnt_pwm_reg <= 'h0;
                        cnt_ramp_reg <= cnt_ramp_reg + 1;
                        if (cnt_ramp_reg >= (RAMP_MULT-1)) begin
                            cnt_ramp_reg <= 'h0;
                            cnt_duty_reg <= cnt_duty_reg + 1;
                            if (&cnt_duty_reg) begin cnt_duty_reg <= 'h0; dir_reg <= ~dir_reg; end
                        end
                    end
                end
            end
        end
    end

    // This block makes the PWM output
    always @(posedge clk) begin
        if (!nreset) out <= 1'b0;
        else if (en) out <= (dir_reg==0) ? ((cnt_pwm_reg<cnt_duty_reg) ? 1:0) : ((cnt_pwm_reg<cnt_duty_reg) ? 0:1);
        else out <= 1'b0;
    end

    // This block delays the direction for the falling-edge detect
    always @(posedge clk) begin
        if (!nreset) dir_fedge <= 'h0;
        else begin dir_fedge[0] <= dir_reg; dir_fedge[1] <= dir_fedge[0]; end
    end

    // Done pulse on the falling edge of the direction
    assign done = ~dir_fedge[0] & dir_fedge[1];

    // PWM output starts low
    initial out = 1'b0;

endmodule
