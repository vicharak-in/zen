// runner_core.v - the rules of the platformer ("Chip Runner") in hardware: hero physics, enemies, coins, lives and the flag
// One tick event runs the whole game step in a few hundred clocks, one small step per clock (no wide logic, so it meets 25 MHz).
// Everything here equals model/runner_game.py; the level constants come from mcu/runner_level.py (generated).
`default_nettype none

module runner_core #(
    parameter NC = 20         // number of coins (generated)
) (
    input  wire         clk,          // 25 MHz fabric clock
    input  wire         rst,          // synchronous reset, starts a new game
    input  wire         restart,      // one-clock pulse: new game
    input  wire         ev_tick,      // one-clock pulse: run one game tick
    input  wire         a_in,         // button A held (jump), sampled at the tick
    input  wire         b_in,         // button B held (stand still), sampled at the tick
    output wire         busy,         // 1 while a tick is being worked out
    output reg          over,         // game over (no lives left, or the flag was reached)
    output reg          won,          // the flag was reached
    output wire [10:0]  hero_x,       // hero box left edge (pixels)
    output wire [7:0]   hero_y,       // hero box top edge (pixels)
    output reg          ground,       // the hero stands on something
    output wire [43:0]  ex_o,         // enemy x positions, 11 bits each (enemy k in bits 11k+10:11k)
    output wire [3:0]   alive_o,      // enemy alive flags
    output wire [NC-1:0] coin_o,      // coin collected flags
    output reg  [23:0]  score,        // score
    output reg  [1:0]   lives,        // lives left
    output reg  [7:0]   coins,        // coins collected
    output reg          reset_p       // one-clock pulse: the hero went back to the start
);

    // Level constants (generated)
    //GENERATED_BEGIN consts
    localparam [10:0] START_X = 11'd32;
    localparam [7:0]  START_Y = 8'd146;
    localparam [10:0] GOAL_X  = 11'd1472;
    localparam [43:0] EX_INIT = {11'd1240, 11'd1000, 11'd690, 11'd240};
    //GENERATED_END consts

    // Game numbers, same as the model
    localparam signed [4:0] JUMP    = -5'sd12;     // jump speed
    localparam signed [4:0] CUT     = -5'sd4;      // jump cut-off speed when A is let go
    localparam signed [4:0] MAXFALL = 5'sd10;      // fall limit
    localparam signed [4:0] BOUNCE  = -5'sd6;      // bounce after a stomp
    localparam [1:0] RUN     = 2'd3;        // pixels per tick

    // State machine states
    localparam [3:0] S_START = 4'd0;   // new game
    localparam [3:0] S_IDLE  = 4'd1;   // wait for a tick
    localparam [3:0] S_CTRL  = 4'd2;   // controls and gravity
    localparam [3:0] S_HF    = 4'd3;   // horizontal step: fetch the column on the right
    localparam [3:0] S_HE    = 4'd4;   // horizontal step: move or stop
    localparam [3:0] S_VF    = 4'd5;   // vertical move: fetch the columns under and over the hero
    localparam [3:0] S_VE    = 4'd6;   // vertical step: move or stop
    localparam [3:0] S_PIT   = 4'd7;   // fell into a pit?
    localparam [3:0] S_EM    = 4'd8;   // move enemy ei
    localparam [3:0] S_EC    = 4'd9;   // hero against enemy ei
    localparam [3:0] S_CC    = 4'd10;  // hero against coin ci
    localparam [3:0] S_GL    = 4'd11;  // the flag

    // State and sampled buttons
    reg  [3:0]   state = S_START;
    reg          a_q = 1'b0, b_q = 1'b0, prev_a = 1'b0;
    // Hero position and vertical speed (two's complement)
    reg  [10:0]  x = START_X;
    reg  [7:0]   y = START_Y;
    reg  signed [4:0] vy = 5'sd0;
    // Pixels left to move this tick, horizontally and vertically
    reg  [1:0]   hcnt = 2'd0;
    reg  [3:0]   vcnt = 4'd0;
    // The tile columns fetched for the current step: the one on the left, and the one on the right
    reg  [12:0]  colL = 13'd0, colR = 13'd0;
    // Enemies: positions, directions (1 = left) and alive flags
    reg  [43:0]  ex = {11'd0, 11'd0, 11'd0, 11'd0};
    reg  [3:0]   ed = 4'd0;
    reg  [3:0]   ealive = 4'hF;
    // Coins collected
    reg  [NC-1:0] cgot = {NC{1'b0}};
    // Counters for enemies and coins
    reg  [1:0]   ei = 2'd0;
    reg  [4:0]   ci = 5'd0;

    // The core is busy in every state except idle
    assign busy    = (state != S_IDLE);
    assign hero_x  = x;
    assign hero_y  = y;
    assign ex_o    = ex;
    assign alive_o = ealive;
    assign coin_o  = cgot;

    // The 12 tile bits of a column plus a wall flag in bit 12 (columns past the end of the level are walls)
    function [12:0] colmask;
        input [7:0] col;
        begin
            colmask = 13'h1000;
            case (col)
                //GENERATED_BEGIN cols
                8'd0: colmask = 13'h0C00;
                8'd1: colmask = 13'h0C00;
                8'd2: colmask = 13'h0C00;
                8'd3: colmask = 13'h0C00;
                8'd4: colmask = 13'h0C00;
                8'd5: colmask = 13'h0C00;
                8'd6: colmask = 13'h0C00;
                8'd7: colmask = 13'h0C00;
                8'd8: colmask = 13'h0C00;
                8'd9: colmask = 13'h0C00;
                8'd10: colmask = 13'h0C00;
                8'd11: colmask = 13'h0C00;
                8'd12: colmask = 13'h0C00;
                8'd13: colmask = 13'h0C00;
                8'd14: colmask = 13'h0F00;
                8'd15: colmask = 13'h0C00;
                8'd16: colmask = 13'h0C00;
                8'd17: colmask = 13'h0C00;
                8'd18: colmask = 13'h0C00;
                8'd19: colmask = 13'h0C00;
                8'd20: colmask = 13'h0000;
                8'd21: colmask = 13'h0000;
                8'd22: colmask = 13'h0C00;
                8'd23: colmask = 13'h0C00;
                8'd24: colmask = 13'h0C80;
                8'd25: colmask = 13'h0C80;
                8'd26: colmask = 13'h0C80;
                8'd27: colmask = 13'h0C80;
                8'd28: colmask = 13'h0C80;
                8'd29: colmask = 13'h0C00;
                8'd30: colmask = 13'h0C00;
                8'd31: colmask = 13'h0C00;
                8'd32: colmask = 13'h0C00;
                8'd33: colmask = 13'h0F80;
                8'd34: colmask = 13'h0C00;
                8'd35: colmask = 13'h0C00;
                8'd36: colmask = 13'h0C00;
                8'd37: colmask = 13'h0C00;
                8'd38: colmask = 13'h0C40;
                8'd39: colmask = 13'h0C40;
                8'd40: colmask = 13'h0C40;
                8'd41: colmask = 13'h0C40;
                8'd42: colmask = 13'h0C00;
                8'd43: colmask = 13'h0C00;
                8'd44: colmask = 13'h0C00;
                8'd45: colmask = 13'h0C00;
                8'd46: colmask = 13'h0C00;
                8'd47: colmask = 13'h0000;
                8'd48: colmask = 13'h0000;
                8'd49: colmask = 13'h0000;
                8'd50: colmask = 13'h0C00;
                8'd51: colmask = 13'h0C00;
                8'd52: colmask = 13'h0C80;
                8'd53: colmask = 13'h0C80;
                8'd54: colmask = 13'h0C80;
                8'd55: colmask = 13'h0C80;
                8'd56: colmask = 13'h0C00;
                8'd57: colmask = 13'h0C00;
                8'd58: colmask = 13'h0C00;
                8'd59: colmask = 13'h0C00;
                8'd60: colmask = 13'h0F00;
                8'd61: colmask = 13'h0C00;
                8'd62: colmask = 13'h0C00;
                8'd63: colmask = 13'h0C00;
                8'd64: colmask = 13'h0C00;
                8'd65: colmask = 13'h0C00;
                8'd66: colmask = 13'h0C00;
                8'd67: colmask = 13'h0C00;
                8'd68: colmask = 13'h0C00;
                8'd69: colmask = 13'h0C00;
                8'd70: colmask = 13'h0000;
                8'd71: colmask = 13'h0000;
                8'd72: colmask = 13'h0C00;
                8'd73: colmask = 13'h0C00;
                8'd74: colmask = 13'h0C00;
                8'd75: colmask = 13'h0C00;
                8'd76: colmask = 13'h0F80;
                8'd77: colmask = 13'h0C00;
                8'd78: colmask = 13'h0C00;
                8'd79: colmask = 13'h0C00;
                8'd80: colmask = 13'h0C00;
                8'd81: colmask = 13'h0C00;
                8'd82: colmask = 13'h0E00;
                8'd83: colmask = 13'h0F00;
                8'd84: colmask = 13'h0F80;
                8'd85: colmask = 13'h0FC0;
                8'd86: colmask = 13'h0C00;
                8'd87: colmask = 13'h0C00;
                8'd88: colmask = 13'h0C00;
                8'd89: colmask = 13'h0C00;
                8'd90: colmask = 13'h0C00;
                8'd91: colmask = 13'h0C00;
                8'd92: colmask = 13'h0C00;
                8'd93: colmask = 13'h0C00;
                8'd94: colmask = 13'h0C00;
                8'd95: colmask = 13'h0C00;
                //GENERATED_END cols
                default: colmask = 13'h1000;
            endcase
        end
    endfunction

    // Is the tile in this row solid? A wall column is solid in every row; rows above or below the level are air
    function tile_solid;
        input [12:0] cm;
        input [4:0]  row;
        begin
            tile_solid = cm[12] | ((row < 5'd12) & cm[row[3:0]]);
        end
    endfunction

    // Left limit, right limit and top of enemy k
    reg [10:0] e_lo, e_hi;
    reg [7:0]  e_y;
    always @* begin
        e_lo = 11'd0; e_hi = 11'd0; e_y = 8'd0;
        case (ei)
            //GENERATED_BEGIN enemies
            2'd0: begin e_lo = 11'd240; e_hi = 11'd290; e_y = 8'd150; end
            2'd1: begin e_lo = 11'd690; e_hi = 11'd730; e_y = 8'd150; end
            2'd2: begin e_lo = 11'd1000; e_hi = 11'd1100; e_y = 8'd150; end
            2'd3: begin e_lo = 11'd1240; e_hi = 11'd1290; e_y = 8'd150; end
            //GENERATED_END enemies
            default: ;
        endcase
    end

    // Tile cell of coin ci
    reg [6:0] c_c;
    reg [3:0] c_r;
    always @* begin
        c_c = 7'd0; c_r = 4'd0;
        case (ci)
            //GENERATED_BEGIN coins
            5'd0: begin c_c = 7'd8; c_r = 4'd9; end
            5'd1: begin c_c = 7'd9; c_r = 4'd9; end
            5'd2: begin c_c = 7'd10; c_r = 4'd9; end
            5'd3: begin c_c = 7'd25; c_r = 4'd6; end
            5'd4: begin c_c = 7'd26; c_r = 4'd6; end
            5'd5: begin c_c = 7'd27; c_r = 4'd6; end
            5'd6: begin c_c = 7'd20; c_r = 4'd8; end
            5'd7: begin c_c = 7'd21; c_r = 4'd8; end
            5'd8: begin c_c = 7'd39; c_r = 4'd5; end
            5'd9: begin c_c = 7'd40; c_r = 4'd5; end
            5'd10: begin c_c = 7'd48; c_r = 4'd8; end
            5'd11: begin c_c = 7'd53; c_r = 4'd6; end
            5'd12: begin c_c = 7'd54; c_r = 4'd6; end
            5'd13: begin c_c = 7'd65; c_r = 4'd5; end
            5'd14: begin c_c = 7'd66; c_r = 4'd5; end
            5'd15: begin c_c = 7'd71; c_r = 4'd8; end
            5'd16: begin c_c = 7'd79; c_r = 4'd7; end
            5'd17: begin c_c = 7'd88; c_r = 4'd9; end
            5'd18: begin c_c = 7'd89; c_r = 4'd9; end
            5'd19: begin c_c = 7'd90; c_r = 4'd9; end
            //GENERATED_END coins
            default: ;
        endcase
    end

    // Enemy ei: current x, and whether the hero overlaps its box; the stomp test
    wire [10:0] ex_i  = ex[11*ei +: 11];
    wire        e_ov  = ({1'b0, x} < ex_i + 12'd12) && (x + 12'd12 > ex_i) && ({1'b0, y} < e_y + 9'd10) && (y + 9'd14 > e_y);
    wire        stomp = !vy[4] && (vy != 5'sd0) && ((y + 9'd14 - e_y) <= 9'd12);

    // Hero against the tile of coin ci
    wire [10:0] c_x0 = {c_c, 4'd0};
    wire [7:0]  c_y0 = {c_r, 4'd0};
    wire        c_ov = (x < c_x0 + 12'd16) && (x + 12'd12 > c_x0) && ({1'b0, y} < c_y0 + 9'd16) && (y + 9'd14 > c_y0);

    // Rows of the hero's top and bottom for the right-edge test, and for the vertical tests
    wire [4:0] y_top  = {1'b0, y[7:4]};
    wire [8:0] y_bot9 = y + 9'd13;
    wire [4:0] y_bot  = y_bot9[8:4];
    // Vertical step: the next row of the hero's top (up) or feet (down)
    wire [7:0] y_up   = y - 8'd1;
    wire [4:0] y_up_r = {1'b0, y_up[7:4]};
    wire [8:0] y_dn9  = y + 9'd1 + 9'd13;
    wire [4:0] y_dn_r = y_dn9[8:4];

    // Controls and gravity values
    wire        press = a_q & ~prev_a;
    wire signed [4:0] v1 = (press && ground) ? JUMP : vy;
    wire signed [4:0] v2 = (!a_q && v1 < CUT) ? CUT : v1;
    wire signed [4:0] v3 = (v2 >= MAXFALL - 5'sd1) ? MAXFALL : v2 + 5'sd1;
    // Pixels to move vertically
    wire [4:0] vabs = vy[4] ? (~vy + 5'd1) : vy;

    // A life is lost: the last one ends the game, otherwise the hero starts again
    task lose_life;
        begin
            if (lives == 2'd1) begin
                lives <= 2'd0;
                over  <= 1'b1;
            end else begin
                lives   <= lives - 2'd1;
                x       <= START_X;
                y       <= START_Y;
                vy      <= 5'sd0;
                ground  <= 1'b1;
                reset_p <= 1'b1;
            end
        end
    endtask

    // This block is the game state machine
    // A reset or restart starts a new game; each tick event walks through the states one small step per clock
    always @(posedge clk) begin
        reset_p <= 1'b0;                   // pulse is one clock long
        if (rst || restart) begin
            state <= S_START;              // new game
        end else begin
            case (state)
                // Everything back to the start of a game
                S_START: begin
                    x <= START_X; y <= START_Y; vy <= 5'sd0; ground <= 1'b1; prev_a <= 1'b0;
                    ex <= EX_INIT; ed <= 4'd0; ealive <= 4'hF;
                    cgot <= {NC{1'b0}}; coins <= 8'd0; score <= 24'd0; lives <= 2'd3; over <= 1'b0; won <= 1'b0;
                    state <= S_IDLE;
                end
                // Wait for a tick; ticks are ignored after game over
                S_IDLE: begin
                    if (ev_tick && !over) begin
                        a_q <= a_in; b_q <= b_in;
                        state <= S_CTRL;
                    end
                end
                // Controls: jump, shorter jump, gravity; then the horizontal move (none while B is held)
                S_CTRL: begin
                    prev_a <= a_q;
                    vy     <= v3;
                    ground <= 1'b0;
                    hcnt   <= b_q ? 2'd0 : RUN;
                    state  <= b_q ? S_VF : S_HF;
                end
                // Horizontal step: the column of the tile that the hero's right edge would enter
                S_HF: begin
                    colR  <= colmask((x + 12'd12) >> 4);
                    state <= S_HE;
                end
                // Horizontal step: move one pixel unless a solid tile is in the way
                S_HE: begin
                    if (!(tile_solid(colR, y_top) | tile_solid(colR, y_bot))) begin
                        x     <= x + 11'd1;
                        hcnt  <= hcnt - 2'd1;
                        state <= (hcnt == 2'd1) ? S_VF : S_HF;
                    end else begin
                        state <= S_VF;
                    end
                end
                // Vertical move: the columns under the hero's left and right edges
                S_VF: begin
                    colL  <= colmask(x >> 4);
                    colR  <= colmask((x + 12'd11) >> 4);
                    vcnt  <= vabs[3:0];
                    state <= (vy == 5'sd0) ? S_PIT : S_VE;
                end
                // Vertical step: one pixel, down or up, until blocked or done
                S_VE: begin
                    if (!vy[4]) begin
                        // Falling: the row under the new feet
                        if (tile_solid(colL, y_dn_r) | tile_solid(colR, y_dn_r)) begin
                            ground <= 1'b1;
                            vy     <= 5'sd0;
                            state  <= S_PIT;
                        end else begin
                            y     <= y + 8'd1;
                            vcnt  <= vcnt - 4'd1;
                            state <= (vcnt == 4'd1) ? S_PIT : S_VE;
                        end
                    end else begin
                        // Rising: the row over the new head; the top of the screen is a ceiling
                        if (y == 8'd0 || tile_solid(colL, y_up_r) | tile_solid(colR, y_up_r)) begin
                            vy    <= 5'sd0;
                            state <= S_PIT;
                        end else begin
                            y     <= y - 8'd1;
                            vcnt  <= vcnt - 4'd1;
                            state <= (vcnt == 4'd1) ? S_PIT : S_VE;
                        end
                    end
                end
                // Falling into a pit costs a life; otherwise the enemies move
                S_PIT: begin
                    if (y[7] & y[6]) begin
                        lose_life;
                        state <= S_IDLE;
                    end else begin
                        ei <= 2'd0;
                        state <= S_EM;
                    end
                end
                // Enemy ei walks one pixel and turns at its limits
                S_EM: begin
                    if (ealive[ei]) begin
                        ex[11*ei +: 11] <= ed[ei] ? (ex_i - 11'd1) : (ex_i + 11'd1);
                        if ((ed[ei] ? (ex_i - 11'd1) : (ex_i + 11'd1)) >= e_hi) ed[ei] <= 1'b1;
                        if ((ed[ei] ? (ex_i - 11'd1) : (ex_i + 11'd1)) <= e_lo) ed[ei] <= 1'b0;
                    end
                    if (ei == 2'd3) begin
                        ei <= 2'd0;
                        state <= S_EC;
                    end else ei <= ei + 2'd1;
                end
                // Hero against enemy ei: a stomp from above kills it, any other touch costs a life
                S_EC: begin
                    if (ealive[ei] && e_ov) begin
                        if (stomp) begin
                            ealive[ei] <= 1'b0;
                            score <= score + 24'd100;
                            vy    <= BOUNCE;
                        end else begin
                            lose_life;
                            state <= S_IDLE;
                        end
                    end
                    if (!(ealive[ei] && e_ov && !stomp)) begin
                        if (ei == 2'd3) begin
                            ci <= 5'd0;
                            state <= S_CC;
                        end else ei <= ei + 2'd1;
                    end
                end
                // Hero against coin ci
                S_CC: begin
                    if (!cgot[ci] && c_ov) begin
                        cgot[ci] <= 1'b1;
                        coins <= coins + 8'd1;
                        score <= score + 24'd50;
                    end
                    if (ci == NC - 1) state <= S_GL; else ci <= ci + 5'd1;
                end
                // The flag ends the game with a win
                S_GL: begin
                    if (x >= GOAL_X) begin
                        score <= score + 24'd1000;
                        won   <= 1'b1;
                        over  <= 1'b1;
                    end
                    state <= S_IDLE;
                end
                default: state <= S_START;
            endcase
        end
    end

endmodule

`default_nettype wire
