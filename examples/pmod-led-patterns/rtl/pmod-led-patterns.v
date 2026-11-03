// Ported from the Vicharak Shrike examples (GPL-2.0) to the Zen 4 (Trion T4F81); logic unchanged, Renesas pad/enable ports removed.
// pmod-led-patterns.v - cycles eight LED patterns on a PMOD LED module, one pattern every 1.5 s at 50 MHz
// (blink, left shift, right shift, alternate, edges-in fill, snake, bounce, breathing fill)

module pmod_led_patterns #(
    parameter CLK_HZ = 50_000_000 // Fabric clock in Hz; every interval below scales with it
) (
    input  wire       clk,      // Fabric clock
    output wire [7:0] led_pmod  // LED levels, 1 = on
);

    // Pattern switch interval: 1.5 s
    localparam T_SWITCH = CLK_HZ * 3 / 2;
    // Pattern 0 step: 0.5 s
    localparam T_BLINK  = CLK_HZ / 2;
    // Patterns 1, 2 and 5 step: 0.2 s
    localparam T_SHIFT  = CLK_HZ / 5;
    // Pattern 4 step: 0.3 s
    localparam T_FILL   = CLK_HZ * 3 / 10;
    // Pattern 6 step: 0.16 s
    localparam T_BOUNCE = CLK_HZ * 4 / 25;
    // Pattern 7 step: 0.4 s
    localparam T_BREATH = CLK_HZ * 2 / 5;

    // Step timer for the current pattern
    reg [31:0] counter = 32'd0;
    // Which pattern is running
    reg [2:0] pattern_select = 3'd0;
    // LED output register
    reg [7:0] led = 8'd0;
    // Timer for the pattern switch
    reg [31:0] pattern_timer = 32'd0;
    // Position of the bouncing LED
    reg [2:0] bounce_pos = 3'd0;
    // Bounce direction, 0 = up
    reg bounce_dir = 1'b0;
    // Snake fill mask
    reg [7:0] snake_mask = 8'b00000001;
    // Breathing fill level
    reg [3:0] breath_level = 4'd0;
    // Breathing direction, 0 = filling
    reg breath_dir = 1'b0;

    // This block steps the active pattern and moves to the next pattern on a timer
    always @(posedge clk) begin
        // Count both timers
        counter <= counter + 1;
        pattern_timer <= pattern_timer + 1;

        // Switch pattern when the switch timer expires
        if (pattern_timer >= T_SWITCH) begin
            // Restart the switch timer
            pattern_timer <= 0;
            // Next pattern, wraps 7 -> 0
            pattern_select <= pattern_select + 1;
        end

        // Run the selected pattern
        case (pattern_select)
            // Pattern 0: blink all LEDs
            3'd0: begin
                if (counter >= T_BLINK) begin
                    led <= ~led;       // Invert all
                    counter <= 0;      // Next step
                end
            end
            // Pattern 1: left shift
            3'd1: begin
                if (counter >= T_SHIFT) begin
                    led <= (led == 0) ? 8'b00000001 : led << 1;  // Shift left, restart from bit 0 when empty
                    counter <= 0;
                end
            end
            // Pattern 2: right shift
            3'd2: begin
                if (counter >= T_SHIFT) begin
                    led <= (led == 0) ? 8'b10000000 : led >> 1;  // Shift right, restart from bit 7 when empty
                    counter <= 0;
                end
            end
            // Pattern 3: alternating pattern
            3'd3: begin
                if (counter >= T_BLINK) begin
                    led <= (led == 8'b10101010) ? 8'b01010101 : 8'b10101010;  // Swap the two halves
                    counter <= 0;
                end
            end
            // Pattern 4: fill from the edges inward
            3'd4: begin
                if (counter >= T_FILL) begin
                    case (led)
                        8'b00000000: led <= 8'b10000001;
                        8'b10000001: led <= 8'b11000011;
                        8'b11000011: led <= 8'b11100111;
                        8'b11100111: led <= 8'b11111111;
                        default:     led <= 8'b00000000;
                    endcase
                    counter <= 0;
                end
            end
            // Pattern 5: snake effect
            3'd5: begin
                if (counter >= T_SHIFT) begin
                    if (snake_mask == 8'b11111111) snake_mask <= 8'b00000001;      // Full: restart
                    else snake_mask <= (snake_mask << 1) | 1;                      // Grow by one LED
                    led <= snake_mask;                                             // Show the current mask
                    counter <= 0;
                end
            end
            // Pattern 6: bounce (ping-pong)
            3'd6: begin
                if (counter >= T_BOUNCE) begin
                    if (!bounce_dir) begin
                        if (bounce_pos < 7) bounce_pos <= bounce_pos + 1;          // Move up
                        else bounce_dir <= 1;                                      // Top reached: turn
                    end else begin
                        if (bounce_pos > 0) bounce_pos <= bounce_pos - 1;          // Move down
                        else bounce_dir <= 0;                                      // Bottom reached: turn
                    end
                    led <= 8'b00000001 << bounce_pos;                              // One LED at the current position
                    counter <= 0;
                end
            end
            // Pattern 7: breathing effect (fill level goes up and down)
            3'd7: begin
                if (counter >= T_BREATH) begin
                    if (!breath_dir) begin
                        if (breath_level < 8) breath_level <= breath_level + 1;    // Fill more
                        else breath_dir <= 1;                                      // Full: turn
                    end else begin
                        if (breath_level > 0) breath_level <= breath_level - 1;    // Fill less
                        else breath_dir <= 0;                                      // Empty: turn
                    end
                    led <= (9'd1 << breath_level) - 1;                              // Thermometer code for the level
                    counter <= 0;
                end
            end
            // Not reachable with a 3-bit select, kept from the original
            default: begin
                pattern_select <= 0;
                counter <= 0;
                led <= 8'b00000000;
                snake_mask <= 8'b00000001;
                bounce_pos <= 0;
                breath_level <= 0;
            end
        endcase
    end

    // Drive the PMOD pins from the LED register
    assign led_pmod = led;

endmodule
