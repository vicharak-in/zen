// tetris_game.v - the game core plus its timers: gravity (speeds up with the level) and the restart after game over

`default_nettype none

module tetris_game (
    input  wire         clk,       // fabric clock
    input  wire         rst,       // synchronous reset
    input  wire         tick,      // one-clock pulse every millisecond
    input  wire         ev_left,   // button events
    input  wire         ev_right,
    input  wire         ev_rot,
    input  wire         ev_drop,
    output wire         busy,      // core is working on an event
    output wire         over,      // game over
    output wire [199:0] board,     // locked cells
    output wire [15:0]  mask,      // falling piece, 4x4 box mask
    output wire [4:0]   px,        // falling piece column
    output wire [4:0]   py,        // falling piece row
    output wire [23:0]  score,     // score
    output wire [15:0]  lines,     // lines cleared
    output wire [7:0]   level      // level
);
    // Gravity step pulse and restart pulse for the core
    reg ev_fall = 1'b0;
    reg restart = 1'b0;
    // Milliseconds since the last gravity step, and since game over
    reg [9:0]  gcnt = 10'd0;
    reg [11:0] ocnt = 12'd0;

    // Milliseconds between gravity steps: 500 - 40 * level, never below 80 (same as the Python model)
    reg [9:0] g_ms;
    // This block turns the level into the gravity period
    always @* begin
        case (level)
            8'd0:  g_ms = 10'd500;
            8'd1:  g_ms = 10'd460;
            8'd2:  g_ms = 10'd420;
            8'd3:  g_ms = 10'd380;
            8'd4:  g_ms = 10'd340;
            8'd5:  g_ms = 10'd300;
            8'd6:  g_ms = 10'd260;
            8'd7:  g_ms = 10'd220;
            8'd8:  g_ms = 10'd180;
            8'd9:  g_ms = 10'd140;
            8'd10: g_ms = 10'd100;
            default: g_ms = 10'd80;
        endcase
    end

    // This block counts milliseconds for gravity, and for the 3 second pause after game over
    // Gravity and restart are one-clock pulses into the core
    always @(posedge clk) begin
        ev_fall <= 1'b0;                          // no pulse by default
        restart <= 1'b0;
        if (rst || restart) begin
            gcnt <= 10'd0;                        // new game: restart both timers
            ocnt <= 12'd0;
        end else if (tick) begin
            if (gcnt + 10'd1 >= g_ms) begin
                gcnt    <= 10'd0;                 // gravity period over
                ev_fall <= 1'b1;                  // one gravity step
            end else begin
                gcnt <= gcnt + 10'd1;
            end
            if (over) begin
                if (ocnt == 12'd2999) begin
                    ocnt    <= 12'd0;
                    restart <= 1'b1;              // 3 seconds after game over: new game
                end else begin
                    ocnt <= ocnt + 12'd1;
                end
            end else begin
                ocnt <= 12'd0;
            end
        end
    end

    // This contains the instantiation for the game core
    tetris_core u_core (
        .clk(clk), .rst(rst), .restart(restart),
        .ev_left(ev_left), .ev_right(ev_right), .ev_rot(ev_rot), .ev_drop(ev_drop), .ev_fall(ev_fall),
        .busy(busy), .over(over), .board_o(board), .mask_o(mask), .x_o(px), .y_o(py), .score(score), .lines(lines), .level(level)
    );
endmodule

`default_nettype wire
