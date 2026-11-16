// tb_core.v - feeds the event list into tetris_core and prints the state after every event
// check_core.py replays the same events in the Python model and compares everything
`timescale 1ns/1ps

module tb_core;
    // Number of events (same as N in gen_events.py)
    parameter N = 12000;
    // Clock, 10 ns period
    reg clk = 1'b0;
    always #5 clk = ~clk;
    // Core inputs
    reg rst = 1'b1, restart = 1'b0;
    reg ev_left = 1'b0, ev_right = 1'b0, ev_rot = 1'b0, ev_drop = 1'b0, ev_fall = 1'b0;
    // Core outputs
    wire busy, over;
    wire [199:0] board_o;
    wire [15:0]  mask_o;
    wire [4:0]   x_o, y_o;
    wire [23:0]  score;
    wire [15:0]  lines;
    wire [7:0]   level;

    // This contains the instantiation for the core under test
    tetris_core dut (
        .clk(clk), .rst(rst), .restart(restart),
        .ev_left(ev_left), .ev_right(ev_right), .ev_rot(ev_rot), .ev_drop(ev_drop), .ev_fall(ev_fall),
        .busy(busy), .over(over), .board_o(board_o), .mask_o(mask_o), .x_o(x_o), .y_o(y_o), .score(score), .lines(lines), .level(level)
    );

    // Event list
    reg [7:0]   ev_code [0:N-1];
    reg [199:0] ev_data [0:N-1];
    integer i;

    // This block logs the kind of every new piece (state 3 with operation 4 is the spawn check)
    always @(posedge clk) if (dut.state == 4'd3 && dut.op == 3'd4) $display("K %0d", dut.kind);

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
        end
    endtask

    // Send one event pulse of one clock
    task pulse;
        input [7:0] c;
        begin
            @(negedge clk);
            case (c)
                8'd0: ev_left  = 1'b1;
                8'd1: ev_right = 1'b1;
                8'd2: ev_rot   = 1'b1;
                8'd3: ev_drop  = 1'b1;
                8'd4: ev_fall  = 1'b1;
                8'd5: restart  = 1'b1;
                default: ;
            endcase
            @(negedge clk);
            ev_left = 1'b0; ev_right = 1'b0; ev_rot = 1'b0; ev_drop = 1'b0; ev_fall = 1'b0; restart = 1'b0;
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
            if (ev_code[i] <= 8'd5) begin
                pulse(ev_code[i]);
            end else if (ev_code[i] == 8'd6) begin
                dut.board = ev_data[i];                       // load a board
            end else if (ev_code[i] == 8'd7) begin
                dut.lines = ev_data[i][15:0];                 // set the line count
                dut.level = ev_data[i][15:0] / 10;
                dut.lm    = ev_data[i][15:0] % 10;
            end else begin
                dut.kind = ev_data[i][2:0];                   // place a piece
                dut.rot  = ev_data[i][4:3];
                dut.x    = ev_data[i][9:5];
                dut.y    = ev_data[i][14:10];
            end
            wait_idle;
            $display("E %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %050x %04x",
                     i, ev_code[i], dut.kind, dut.rot, dut.x, dut.y, over, score, lines, level, board_o, mask_o);
        end
        $display("DONE");
        $finish;
    end
endmodule
