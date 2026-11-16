// tb_runner_core.v - feeds the event list into runner_core and prints the state after every event
// check_runner.py replays the same events in the Python model and compares everything
`timescale 1ns/1ps

module tb_runner_core;
    // Number of events (same as N in gen_events.py) and coins (same as NC in the level)
    parameter N = 20000;
    parameter NC = 20;
    // Clock, 10 ns period
    reg clk = 1'b0;
    always #5 clk = ~clk;
    // Core inputs
    reg rst = 1'b1, restart = 1'b0, ev_tick = 1'b0, a_in = 1'b0, b_in = 1'b0;
    // Core outputs
    wire busy, over, won, ground, reset_p;
    wire [10:0] hero_x;
    wire [7:0] hero_y;
    wire [43:0] ex_o;
    wire [3:0] alive_o;
    wire [NC-1:0] coin_o;
    wire [23:0] score;
    wire [1:0] lives;
    wire [7:0] coins;

    // This contains the instantiation for the core under test
    runner_core dut (
        .clk(clk), .rst(rst), .restart(restart), .ev_tick(ev_tick), .a_in(a_in), .b_in(b_in),
        .busy(busy), .over(over), .won(won), .hero_x(hero_x), .hero_y(hero_y), .ground(ground),
        .ex_o(ex_o), .alive_o(alive_o), .coin_o(coin_o), .score(score), .lives(lives), .coins(coins), .reset_p(reset_p)
    );

    // Event list
    reg [7:0]  ev_code [0:N-1];
    reg [63:0] ev_data [0:N-1];
    integer i, k, n;
    // Longest tick in clocks (printed at the end)
    integer longest = 0, cycles = 0;

    // Wait until the core is idle again (stops the run if it hangs)
    task wait_idle;
        integer t;
        begin
            t = 0;
            @(negedge clk);
            while (dut.state != 4'd1 && t < 3000) begin
                @(negedge clk);
                t = t + 1;
            end
            if (t >= 3000) begin
                $display("TIMEOUT at event %0d", i);
                $finish;
            end
            if (t > longest) longest = t;
        end
    endtask

    // Send a tick or restart pulse of one clock
    task pulse;
        input [7:0] c;
        input [1:0] ab;
        begin
            @(negedge clk);
            a_in = ab[0]; b_in = ab[1];
            if (c == 8'd0) ev_tick = 1'b1; else restart = 1'b1;
            @(negedge clk);
            ev_tick = 1'b0; restart = 1'b0;
        end
    endtask

    // Main sequence: reset, then every event, printing the state after each
    initial begin
        $readmemh("events_code.hex", ev_code);
        $readmemh("events_data.hex", ev_data);
        repeat (4) @(negedge clk);
        rst = 1'b0;
        wait_idle;
        for (i = 0; i < N; i = i + 1) begin
            case (ev_code[i])
                8'd0: pulse(8'd0, ev_data[i][1:0]);
                8'd1: pulse(8'd1, 2'd0);
                8'd2: begin
                    dut.x = ev_data[i][10:0]; dut.y = ev_data[i][18:11]; dut.vy = ev_data[i][23:19];
                    dut.ground = ev_data[i][24]; dut.prev_a = ev_data[i][25];
                end
                8'd3: begin
                    k = ev_data[i][1:0];
                    dut.ex[11*k +: 11] = ev_data[i][12:2]; dut.ed[k] = ev_data[i][13]; dut.ealive[k] = ev_data[i][14];
                end
                8'd4: begin
                    dut.cgot = ev_data[i][NC-1:0];
                    n = 0;
                    for (k = 0; k < NC; k = k + 1) n = n + ev_data[i][k];
                    dut.coins = n;
                end
                default: begin
                    dut.lives = ev_data[i][1:0]; dut.over = ev_data[i][2]; dut.score = ev_data[i][26:3];
                end
            endcase
            wait_idle;
            $display("E %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0h",
                     i, ev_code[i], hero_x, hero_y, $signed(dut.vy), ground, dut.prev_a,
                     ex_o[10:0], ex_o[21:11], ex_o[32:22], ex_o[43:33], dut.ed, alive_o,
                     score, lives, coins, over, won, coin_o);
        end
        $display("LONGEST %0d", longest);
        $display("DONE");
        $finish;
    end
endmodule
