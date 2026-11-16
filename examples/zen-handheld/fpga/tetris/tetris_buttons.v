// tetris_buttons.v - turns two debounced buttons into game events (same rules as mcu/buttons.py)
//   tap on A (press and release)            -> ev_left
//   tap on B                                -> ev_right
//   A and B pressed within COMBO_MS         -> ev_rot (once, until both are released)
//   one button held longer than HOLD_MS     -> ev_drop (once per press, no move on release)

`default_nettype none

module tetris_buttons #(
    parameter HOLD_MS  = 450,   // press time (ms) that counts as a long press
    parameter COMBO_MS = 120    // largest gap (ms) between the two presses of a rotate combo
) (
    input  wire clk,        // fabric clock
    input  wire tick,       // one-clock pulse every millisecond
    input  wire a_in,       // button A (left), 1 = pressed, already debounced
    input  wire b_in,       // button B (right), 1 = pressed, already debounced
    output reg  ev_left,    // one-clock pulse: move left
    output reg  ev_right,   // one-clock pulse: move right
    output reg  ev_rot,     // one-clock pulse: rotate
    output reg  ev_drop     // one-clock pulse: hard drop
);
    // Button levels as seen by this block, and their values one clock earlier (for edges)
    reg da = 1'b0, db = 1'b0, pa = 1'b0, pb = 1'b0;
    // Milliseconds each button has been down (stops at 1023)
    reg [9:0] ta = 10'd0, tb = 10'd0;
    // 1 once the long press of the current press has dropped the piece
    reg ha = 1'b0, hb = 1'b0;
    // 1 from the rotate combo until both buttons are up
    reg combo = 1'b0;
    // Difference between the two press times in ms
    wire [9:0] diff = (ta > tb) ? (ta - tb) : (tb - ta);

    // This block is the whole button logic: edges, press timers, combo and long press
    // Event outputs are cleared every clock and set for one clock when something happens
    always @(posedge clk) begin
        da <= a_in;                              // sample A
        db <= b_in;                              // sample B
        pa <= da;                                // previous A
        pb <= db;                                // previous B
        ev_left  <= 1'b0;                        // no event by default
        ev_right <= 1'b0;
        ev_rot   <= 1'b0;
        ev_drop  <= 1'b0;
        // Press timers: zero while up, count milliseconds while down
        if (!da) ta <= 10'd0; else if (tick && ta != 10'd1023) ta <= ta + 10'd1;
        if (!db) tb <= 10'd0; else if (tick && tb != 10'd1023) tb <= tb + 10'd1;
        // A new press clears the long-press flag
        if (da && !pa) ha <= 1'b0;
        if (db && !pb) hb <= 1'b0;
        // A release is a tap unless it was a long press or part of the combo
        if (!da && pa && !ha && !combo) ev_left  <= 1'b1;
        if (!db && pb && !hb && !combo) ev_right <= 1'b1;
        // Both down close together: rotate once
        if (da && db && !combo && diff <= COMBO_MS) begin
            combo  <= 1'b1;
            ev_rot <= 1'b1;
        end
        // Long press on one button: drop once
        if (da && !ha && !combo && ta >= HOLD_MS) begin ha <= 1'b1; ev_drop <= 1'b1; end
        if (db && !hb && !combo && tb >= HOLD_MS) begin hb <= 1'b1; ev_drop <= 1'b1; end
        // The combo ends when both buttons are up
        if (!da && !db) combo <= 1'b0;
    end
endmodule

`default_nettype wire
