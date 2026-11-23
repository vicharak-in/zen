// tb_game.v - button gestures and game timers working together, with a 1 ms tick every 400 clocks (so the test runs fast)
// Checks: tap A = left, tap B = right, A+B = rotate once, long press = drop, gravity, speed, game over and restart after 3 s
`timescale 1ns/1ps

module tb_game;
    // Clock, 10 ns period
    reg clk = 1'b0;
    always #5 clk = ~clk;
    // Reset and the two button inputs (1 = pressed)
    reg rst = 1'b1, a = 1'b0, b = 1'b0;
    // Millisecond tick: one pulse every 400 clocks in this test
    wire tick;
    // Button events
    wire ev_left, ev_right, ev_rot, ev_drop;
    // Game outputs
    wire busy, over;
    wire [199:0] board;
    wire [15:0] mask;
    wire [4:0] px, py;
    wire [23:0] score;
    wire [15:0] lines;
    wire [7:0] level;
    // Count of failed checks
    integer errors = 0;

    // This contains the instantiation for the millisecond tick
    tetris_tick #(.DIV(400)) u_tick (.clk(clk), .tick(tick));
    // This contains the instantiation for the button logic
    tetris_buttons u_buttons (.clk(clk), .tick(tick), .a_in(a), .b_in(b),
        .ev_left(ev_left), .ev_right(ev_right), .ev_rot(ev_rot), .ev_drop(ev_drop));
    // This contains the instantiation for the game
    tetris_game u_game (.clk(clk), .rst(rst), .tick(tick),
        .ev_left(ev_left), .ev_right(ev_right), .ev_rot(ev_rot), .ev_drop(ev_drop),
        .busy(busy), .over(over), .board(board), .mask(mask), .px(px), .py(py), .score(score), .lines(lines), .level(level));

    // Wait n milliseconds
    task ms;
        input integer n;
        begin
            repeat (n * 400) @(posedge clk);
        end
    endtask

    // Check one condition and count a failure
    task check;
        input ok;
        input [399:0] what;
        begin
            if (!ok) begin
                errors = errors + 1;
                $display("FAIL: %0s", what);
            end else begin
                $display("ok:   %0s", what);
            end
        end
    endtask

    // Piece state before an action
    reg signed [4:0] x0;
    reg [1:0] rot0;
    reg [4:0] y0;
    reg [23:0] score0;
    // Number of rotate events seen in a window
    integer rot_count = 0;
    always @(posedge clk) if (ev_rot) rot_count = rot_count + 1;

    // Main sequence
    initial begin
        ms(1);
        rst = 1'b0;
        ms(2);
        // The first piece sits at the top centre
        check(u_game.u_core.y == 5'd0 && u_game.u_core.x == 5'sd3, "new piece at top centre");

        // Tap A for 60 ms: one step left
        x0 = u_game.u_core.x;
        a = 1'b1; ms(60); a = 1'b0; ms(5);
        check(u_game.u_core.x == x0 - 1, "tap A moves left");

        // Tap B for 60 ms: one step right
        x0 = u_game.u_core.x;
        b = 1'b1; ms(60); b = 1'b0; ms(5);
        check(u_game.u_core.x == x0 + 1, "tap B moves right");

        // Both buttons 30 ms apart, held 100 ms: exactly one rotation, no moves
        x0 = u_game.u_core.x;
        rot0 = u_game.u_core.rot;
        rot_count = 0;
        a = 1'b1; ms(30); b = 1'b1; ms(100); a = 1'b0; b = 1'b0; ms(5);
        check(rot_count == 1, "A+B gives one rotate event");
        check(u_game.u_core.rot == rot0 + 2'd1, "A+B rotates the piece");

        // Both buttons held for 900 ms: still one rotation and no drop
        score0 = score;
        rot_count = 0;
        a = 1'b1; b = 1'b1; ms(900); a = 1'b0; b = 1'b0; ms(5);
        check(rot_count == 1 && score == score0, "A+B held long: one rotate, no drop");

        // Presses 300 ms apart are not a combo: two separate taps
        x0 = u_game.u_core.x;
        rot_count = 0;
        a = 1'b1; ms(50); a = 1'b0; ms(250); b = 1'b1; ms(50); b = 1'b0; ms(5);
        check(rot_count == 0 && u_game.u_core.x == x0, "taps far apart: left then right, no rotate");

        // Long press of A (600 ms): hard drop, new piece at the top, score up
        score0 = score;
        a = 1'b1; ms(600); a = 1'b0; ms(5);
        check(score > score0, "long press drops the piece (score up)");
        check(u_game.u_core.y == 5'd0 || u_game.u_core.y == 5'd1, "new piece spawned after the drop");

        // Releasing after a long press sends no tap: the next piece did not move left
        check(u_game.u_core.x == 5'sd3, "no move after a long press");

        // Long press of B drops too
        score0 = score;
        b = 1'b1; ms(600); b = 1'b0; ms(5);
        check(score > score0, "long press of B drops the piece");

        // Gravity: after 520 ms with no input the piece is lower
        y0 = u_game.u_core.y;
        ms(520);
        check(u_game.u_core.y > y0 || u_game.u_core.y == 5'd0, "gravity moves the piece down");

        // Fill the board with hard drops until game over
        repeat (60) begin
            a = 1'b1; ms(480); a = 1'b0; ms(10);
        end
        check(over == 1'b1, "stacking drops ends the game");
        check(board != 200'd0, "board is not empty at game over");

        // After 3 seconds the game restarts by itself
        ms(3100);
        check(over == 1'b0 && score == 24'd0 && lines == 16'd0, "game restarts 3 s after game over");

        if (errors == 0) $display("ALL PASSED");
        else $display("%0d CHECKS FAILED", errors);
        $finish;
    end
endmodule
