// tb_runner_game.v - tests the timers and buttons around the platformer core: start pause, tick rate, jump, standing still, death pause, restart after game over
`timescale 1ns/1ps

module tb_runner_game;
    // Clock, 10 ns period; one "millisecond" is 100 clocks here so the test runs fast
    reg clk = 1'b0;
    always #5 clk = ~clk;
    reg rst = 1'b1;
    reg tick = 1'b0;
    reg [6:0] c = 7'd0;
    // This block makes a pulse every 100 clocks
    always @(posedge clk) begin
        c <= (c == 7'd99) ? 7'd0 : c + 7'd1;
        tick <= (c == 7'd99);
    end
    reg a_held = 1'b0, b_held = 1'b0;
    wire busy, over, won, ground;
    wire [10:0] hero_x;
    wire [7:0] hero_y;
    wire [43:0] ex;
    wire [3:0] alive;
    wire [19:0] coin;
    wire [23:0] score;
    wire [1:0] lives;
    wire [7:0] coins;
    // This contains the instantiation for the game under test
    runner_game #(.NC(20)) dut (
        .clk(clk), .rst(rst), .tick(tick), .a_held(a_held), .b_held(b_held),
        .busy(busy), .over(over), .won(won), .hero_x(hero_x), .hero_y(hero_y), .ground(ground),
        .ex(ex), .alive(alive), .coin(coin), .score(score), .lives(lives), .coins(coins)
    );

    integer fails = 0;
    integer k;
    reg [7:0] ymin;
    // Wait n "milliseconds"
    task ms;
        input integer n;
        begin
            repeat (n * 100) @(posedge clk);
        end
    endtask
    // Check a condition and count a failure
    task check;
        input ok;
        input [255:0] what;
        begin
            if (!ok) begin
                $display("FAIL: %0s (x=%0d y=%0d lives=%0d over=%0d)", what, hero_x, hero_y, lives, over);
                fails = fails + 1;
            end
        end
    endtask

    initial begin
        repeat (4) @(posedge clk);
        rst = 1'b0;
        // 1. nothing moves during the first second
        ms(950);
        check(hero_x == 11'd32, "hero waits during the start pause");
        // 2. after the pause the hero runs 3 pixels per tick, one tick every 33 ms
        ms(60 + 33 * 10);
        check(hero_x >= 11'd32 + 30 && hero_x <= 11'd32 + 36, "hero runs 3 pixels per tick");
        // 3. B held: the hero stands still
        b_held = 1'b1;
        ms(40);
        k = hero_x;
        ms(33 * 6);
        check(hero_x == k, "B stops the hero");
        b_held = 1'b0;
        // 4. A press: the hero rises and lands again on the ground
        ymin = 8'd255;
        a_held = 1'b1;
        for (k = 0; k < 60; k = k + 1) begin
            ms(33);
            if (hero_y < ymin) ymin = hero_y;
            if (k == 15) a_held = 1'b0;
        end
        check(ymin < 8'd100, "A makes the hero jump");
        check(hero_y == 8'd146 || hero_y >= 8'd190, "hero is back on the ground after the jump");
        // 5. a fall into a pit costs a life and starts the pause
        dut.u_core.x = 11'd330; dut.u_core.y = 8'd190; dut.u_core.vy = 5'd5; dut.u_core.ground = 1'b0;
        ms(80);
        check(lives == 2'd2, "a pit costs a life");
        check(hero_x == 11'd32, "hero is back at the start");
        ms(800);
        check(hero_x == 11'd32, "pause after losing a life");
        // 6. game over: after 3 s the game restarts
        dut.u_core.lives = 2'd1; dut.u_core.over = 1'b1;
        ms(2900);
        check(over, "game over stays for a while");
        ms(300);
        check(!over && lives == 2'd3 && hero_x == 11'd32, "restart after game over");
        if (fails == 0) $display("ALL PASSED"); else $display("FAILED %0d", fails);
        $finish;
    end
endmodule
