// tetris_core.v - the Tetris game rules in hardware: board, falling piece, rotation with wall kicks, 7-bag, line clear, score and level
// The same rules as model/tetris_game.py (the reference model): the simulation in fpga/sim compares the two cell by cell
// Small on purpose: one board row is read and one row is written per clock, so every test takes a few clocks
// Events come in as one-clock pulses; the core works on one event at a time and shows busy while it does
// Outputs: the locked board (bit i = row * 10 + column, row 0 is the top) and the falling piece as a 4x4 mask with its x and y;
// the RP2350 draws the piece onto the board (mcu/frame.py)

`default_nettype none

module tetris_core (
    input  wire         clk,       // fabric clock
    input  wire         rst,       // synchronous reset: starts a new game
    input  wire         restart,   // one-clock pulse: starts a new game
    input  wire         ev_left,   // one-clock pulse: move the piece left
    input  wire         ev_right,  // one-clock pulse: move the piece right
    input  wire         ev_rot,    // one-clock pulse: rotate the piece clockwise
    input  wire         ev_drop,   // one-clock pulse: hard drop
    input  wire         ev_fall,   // one-clock pulse: gravity step
    output wire         busy,      // 1 while the core is working on an event
    output reg          over,      // 1 when a new piece did not fit
    output wire [199:0] board_o,   // locked cells, bit i = row * 10 + column
    output wire [15:0]  mask_o,    // falling piece, bit (row * 4 + column) of its 4x4 box
    output wire [4:0]   x_o,       // column of the box's left edge (two's complement)
    output wire [4:0]   y_o,       // row of the box's top edge
    output reg  [23:0]  score,     // score so far
    output reg  [15:0]  lines,     // lines cleared so far
    output reg  [7:0]   level      // level, goes up every 10 lines
);

    // State machine states
    localparam [3:0] S_START = 4'd0;   // clear everything for a new game
    localparam [3:0] S_IDLE  = 4'd1;   // wait for an event
    localparam [3:0] S_TEST  = 4'd2;   // test a position against the board, one box row per clock (4 clocks)
    localparam [3:0] S_DEC   = 4'd3;   // act on the test result
    localparam [3:0] S_LOCK  = 4'd4;   // write the piece into the board, one row per clock
    localparam [3:0] S_CSCAN = 4'd5;   // find and remove full rows, one row per clock
    localparam [3:0] S_CFILL = 4'd6;   // fill the top with empty rows
    localparam [3:0] S_SCORE = 4'd7;   // add the line points, repeated level + 1 times
    localparam [3:0] S_SPAWN = 4'd8;   // pick the next piece from the 7-bag
    localparam [3:0] S_WAIT  = 4'd10;  // one idle clock after locking, so the last row write has landed before the scan reads
    localparam [3:0] S_TEST2 = 4'd9;   // second half of a test clock: collect the overlap of the row read in S_TEST

    // What the position test is for
    localparam [2:0] OP_MOVE  = 3'd0;  // sideways move
    localparam [2:0] OP_ROT   = 3'd1;  // rotation with wall kicks
    localparam [2:0] OP_FALL  = 3'd2;  // gravity step
    localparam [2:0] OP_DROP  = 3'd3;  // one row of a hard drop
    localparam [2:0] OP_SPAWN = 3'd4;  // check that a new piece fits

    // Current state and the operation being tested
    reg  [3:0]   state = S_START;
    reg  [2:0]   op    = OP_MOVE;
    // Locked cells: 20 rows of 10 bits, row r is board[10*r +: 10]
    reg  [199:0] board = 200'd0;
    // Falling piece: kind 0..6 (I, O, T, S, Z, J, L) and rotation 0..3
    reg  [2:0]   kind  = 3'd0;
    reg  [1:0]   rot   = 2'd0;
    // Falling piece: column and row of the top-left corner of its 4x4 box
    reg  signed [4:0] x = 5'sd3;
    reg  [4:0]   y     = 5'd0;
    // Direction of the pending sideways move (1 = left)
    reg          dx_neg = 1'b0;
    // Which wall kick is being tried (0..4)
    reg  [2:0]   kick_idx = 3'd0;
    // Box row being tested or written (0..3), and 1 once any tested row overlapped
    reg  [1:0]   tk = 2'd0;
    reg          hit_acc = 1'b0;
    // Row being scanned and row being written while full rows are removed
    reg  [4:0]   rd = 5'd0;
    reg  [4:0]   wr = 5'd0;
    // Number of full rows found
    reg  [2:0]   nclr = 3'd0;
    // Remaining repeats of the line points
    reg  [7:0]   sc_rem = 8'd0;
    // Lines since the last level change (0..9)
    reg  [3:0]   lm = 4'd0;
    // Pieces already used from the current 7-bag
    reg  [6:0]   bag = 7'd0;
    // Free-running pseudo random generator
    reg  [31:0]  lfsr = 32'hACE1BEEF;

    // The core is busy in every state except idle
    assign busy = (state != S_IDLE);

    // Piece shapes: 16-bit mask of the 4x4 box, bit (row * 4 + column), for each kind and rotation (made by fpga/sim/gen_pieces.py from the Python model)
    function [15:0] pmask;
        input [2:0] k;   // piece kind
        input [1:0] r;   // rotation
        begin
            case ({k, r})
                5'd0: pmask = 16'h000F;   // kind 0, rotation 0
                5'd1: pmask = 16'h1111;   // kind 0, rotation 1
                5'd2: pmask = 16'h000F;   // kind 0, rotation 2
                5'd3: pmask = 16'h1111;   // kind 0, rotation 3
                5'd4: pmask = 16'h0033;   // kind 1, rotation 0
                5'd5: pmask = 16'h0033;   // kind 1, rotation 1
                5'd6: pmask = 16'h0033;   // kind 1, rotation 2
                5'd7: pmask = 16'h0033;   // kind 1, rotation 3
                5'd8: pmask = 16'h0072;   // kind 2, rotation 0
                5'd9: pmask = 16'h0232;   // kind 2, rotation 1
                5'd10: pmask = 16'h0027;   // kind 2, rotation 2
                5'd11: pmask = 16'h0131;   // kind 2, rotation 3
                5'd12: pmask = 16'h0036;   // kind 3, rotation 0
                5'd13: pmask = 16'h0231;   // kind 3, rotation 1
                5'd14: pmask = 16'h0036;   // kind 3, rotation 2
                5'd15: pmask = 16'h0231;   // kind 3, rotation 3
                5'd16: pmask = 16'h0063;   // kind 4, rotation 0
                5'd17: pmask = 16'h0132;   // kind 4, rotation 1
                5'd18: pmask = 16'h0063;   // kind 4, rotation 2
                5'd19: pmask = 16'h0132;   // kind 4, rotation 3
                5'd20: pmask = 16'h0071;   // kind 5, rotation 0
                5'd21: pmask = 16'h0322;   // kind 5, rotation 1
                5'd22: pmask = 16'h0047;   // kind 5, rotation 2
                5'd23: pmask = 16'h0113;   // kind 5, rotation 3
                5'd24: pmask = 16'h0074;   // kind 6, rotation 0
                5'd25: pmask = 16'h0223;   // kind 6, rotation 1
                5'd26: pmask = 16'h0017;   // kind 6, rotation 2
                5'd27: pmask = 16'h0311;   // kind 6, rotation 3
                default: pmask = 16'h0000;
            endcase
        end
    endfunction

    // Horizontal shift of wall kick number n: 0, -1, +1, -2, +2 (same order as the Python model)
    function signed [4:0] kick_val;
        input [2:0] n;   // kick number
        begin
            case (n)
                3'd0:    kick_val =  5'sd0;
                3'd1:    kick_val = -5'sd1;
                3'd2:    kick_val =  5'sd1;
                3'd3:    kick_val = -5'sd2;
                default: kick_val =  5'sd2;
            endcase
        end
    endfunction

    // Shape of the piece as it is now
    wire [15:0] mc = pmask(kind, rot);
    // Outputs for the RP2350
    assign board_o = board;
    assign mask_o  = mc;
    assign x_o     = x;
    assign y_o     = y;

    // This block picks the position to test: the piece moved, rotated or dropped one row, depending on the operation
    // It is combinational; outside the test the position is simply the piece itself
    reg [1:0]        c_rot;   // rotation to test
    reg signed [4:0] c_x;     // column to test
    reg [4:0]        c_y;     // row to test
    always @* begin
        c_rot = rot;                                                 // default: the piece as it is
        c_x   = x;                                                   // default column
        c_y   = y;                                                   // default row
        if (state == S_TEST || state == S_DEC) begin
            case (op)
                OP_MOVE: c_x = dx_neg ? (x - 5'sd1) : (x + 5'sd1);   // one column left or right
                OP_ROT: begin
                    c_rot = rot + 2'd1;                              // next rotation
                    c_x   = x + kick_val(kick_idx);                  // with the current wall kick
                end
                OP_FALL, OP_DROP: c_y = y + 5'd1;                    // one row down
                default: ;                                           // spawn check: the piece itself
            endcase
        end
    end

    // Shape at the tested rotation, and the shift of the box into the extended row (column + 3)
    wire [15:0] mt = pmask(kind, c_rot);
    wire [4:0]  px = c_x + 5'sd3;

    // The one board read port: while testing or locking it reads box row tk of the piece, otherwise the scan row rd
    // A row at or below the floor reads as full
    wire [5:0] row_a  = (state == S_TEST || state == S_LOCK)
                        ? ({1'b0, (state == S_TEST) ? c_y : y} + {4'd0, tk})
                        : {1'b0, rd};
    wire [9:0] rd_row = (row_a < 6'd20) ? board[10*row_a[4:0] +: 10] : 10'h3FF;

    // Collision of box row tk: the piece row shifted into an extended row that has walls on both sides (bits 0-2 and 13-19)
    wire [3:0]  nib_t    = mt[4*tk +: 4];
    wire [19:0] ext      = {7'h7F, rd_row, 3'h7};
    wire [19:0] pc       = {16'd0, nib_t} << px;
    // The shifted piece row and the extended board row are stored at the end of S_TEST, the overlap is taken in S_TEST2
    reg  [19:0] pc_r  = 20'd0;
    reg  [19:0] ext_r = 20'd0;
    wire        hit_term = |(pc_r & ext_r);
    // Result of the whole test: valid in S_DEC
    wire        hit      = hit_acc;

    // The piece row of box row tk at the piece column, used when the piece is locked
    wire [3:0] nib_l = mc[4*tk +: 4];
    wire [9:0] lrow  = {6'd0, nib_l} << x[3:0];

    // This block decides the one board write of this clock (the board has a single write port)
    reg         we;      // write a row
    reg  [4:0]  waddr;   // which row
    reg  [9:0]  wdata;   // the new row value
    reg         clr;     // clear the whole board
    always @* begin
        we    = 1'b0;                                              // no write by default
        waddr = 5'd0;
        wdata = 10'd0;
        clr   = 1'b0;
        case (state)
            S_START: clr = 1'b1;                                   // new game: empty board
            S_LOCK: begin
                we    = (row_a < 6'd20) && (nib_l != 4'd0);        // piece row on the board
                waddr = row_a[4:0];
                wdata = rd_row | lrow;                             // add the piece cells
            end
            S_CSCAN: if (rd_row != 10'h3FF && wr != rd) begin
                we    = 1'b1;                                      // keep this row, moved down
                waddr = wr;
                wdata = rd_row;
            end
            S_CFILL: if (wr < 5'd20) begin
                we    = 1'b1;                                      // empty row at the top
                waddr = wr;
                wdata = 10'd0;
            end
            default: ;
        endcase
    end

    // The write is registered: it is decided in one clock and done in the next, which keeps the read-to-write path short
    reg         we_r    = 1'b0;
    reg  [4:0]  waddr_r = 5'd0;
    reg  [9:0]  wdata_r = 10'd0;
    reg         clr_r   = 1'b0;
    // This block performs the board write one clock after it was decided: clear everything, or write one row
    always @(posedge clk) begin
        we_r    <= we;                                             // remember the write of this clock
        waddr_r <= waddr;
        wdata_r <= wdata;
        clr_r   <= clr;
        if (clr_r) board <= 200'd0;                                // clear
        else if (we_r) board[10*waddr_r +: 10] <= wdata_r;         // write one row
    end

    // Points for the number of rows cleared at once (before the level multiplier)
    reg [9:0] pts;
    // This block turns the row count into points
    always @* begin
        case (nclr)
            3'd1:    pts = 10'd100;
            3'd2:    pts = 10'd300;
            3'd3:    pts = 10'd500;
            default: pts = 10'd800;
        endcase
    end

    // Piece candidate from the random generator: three spread bits, 7 is rejected
    wire [2:0] cand = {lfsr[20], lfsr[9], lfsr[3]};

    // This block is the game state machine
    // Every clock the random generator steps; a reset or restart starts a new game; otherwise the state decides what happens
    always @(posedge clk) begin
        lfsr <= {lfsr[30:0], lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0]};     // step the random generator
        if (rst || restart) begin
            state <= S_START;                                              // new game
        end else begin
            case (state)
                // Clear the score and the bag (the board is cleared by the write block), then pick the first piece
                S_START: begin
                    score <= 24'd0;        // no points
                    lines <= 16'd0;        // no lines
                    lm    <= 4'd0;         // no lines in this level
                    level <= 8'd0;         // level 0
                    over  <= 1'b0;         // game is on
                    bag   <= 7'd0;         // empty bag
                    state <= S_SPAWN;      // first piece
                end
                // Wait for an event; events are ignored after game over
                // Each event starts a position test (S_TEST) for what it wants to do
                S_IDLE: begin
                    if (!over) begin
                        tk <= 2'd0;                                // test from box row 0
                        hit_acc <= 1'b0;                           // nothing overlapped yet
                        if (ev_drop) begin op <= OP_DROP; state <= S_TEST; end                      // hard drop
                        else if (ev_rot) begin op <= OP_ROT; kick_idx <= 3'd0; state <= S_TEST; end // rotate, first kick
                        else if (ev_left) begin op <= OP_MOVE; dx_neg <= 1'b1; state <= S_TEST; end // move left
                        else if (ev_right) begin op <= OP_MOVE; dx_neg <= 1'b0; state <= S_TEST; end // move right
                        else if (ev_fall) begin op <= OP_FALL; state <= S_TEST; end                 // gravity
                    end
                end
                // Test the position one box row per clock
                S_TEST: begin
                    pc_r  <= pc;                                   // store the shifted piece row
                    ext_r <= ext;                                  // store the board row with walls
                    state <= S_TEST2;
                end
                // Collect the overlap of this box row, then go on to the next row
                S_TEST2: begin
                    hit_acc <= hit_acc | hit_term;                 // remember any overlap
                    if (tk == 2'd3) state <= S_DEC;                // all four rows done
                    else begin tk <= tk + 2'd1; state <= S_TEST; end // next box row
                end
                // Act on the test result
                S_DEC: begin
                    case (op)
                        // Sideways move: take it only if the new place is free
                        OP_MOVE: begin
                            if (!hit) x <= c_x;
                            state <= S_IDLE;
                        end
                        // Rotation: take the first wall kick that fits
                        OP_ROT: begin
                            if (!hit) begin
                                x     <= c_x;                      // kicked column
                                rot   <= c_rot;                    // new rotation
                                state <= S_IDLE;
                            end else if (kick_idx == 3'd4) begin
                                state <= S_IDLE;                   // no kick fits: leave the piece as it is
                            end else begin
                                kick_idx <= kick_idx + 3'd1;       // try the next kick
                                tk <= 2'd0; hit_acc <= 1'b0;
                                state <= S_TEST;
                            end
                        end
                        // Gravity: one row down, or land
                        OP_FALL: begin
                            if (!hit) begin
                                y <= y + 5'd1;
                                state <= S_IDLE;
                            end else begin
                                tk <= 2'd0;
                                state <= S_LOCK;                   // landed
                            end
                        end
                        // Hard drop: one row at a time, 2 points per row, then land
                        OP_DROP: begin
                            if (!hit) begin
                                y     <= y + 5'd1;
                                score <= score + 24'd2;
                                tk <= 2'd0; hit_acc <= 1'b0;
                                state <= S_TEST;                   // test the next row
                            end else begin
                                tk <= 2'd0;
                                state <= S_LOCK;                   // landed
                            end
                        end
                        // The new piece must fit, otherwise the game is over
                        default: begin
                            over  <= hit;
                            state <= S_IDLE;
                        end
                    endcase
                end
                // Write the piece into the board, one box row per clock (the write block does the writing), then scan for full rows from the bottom
                S_LOCK: begin
                    if (tk == 2'd3) begin
                        rd    <= 5'd19;        // scan from the bottom row
                        wr    <= 5'd19;        // write position
                        nclr  <= 3'd0;         // no full rows yet
                        state <= S_WAIT;
                    end else begin
                        tk <= tk + 2'd1;
                    end
                end
                // One clock for the last locked row to reach the board, then the scan starts
                S_WAIT: state <= S_CSCAN;
                // Scan one row per clock: full rows are dropped, the others move down to the write position
                S_CSCAN: begin
                    if (rd_row == 10'h3FF) nclr <= nclr + 3'd1;      // full row: count it, do not copy it
                    else wr <= wr - 5'd1;                            // kept row: next write position
                    if (rd == 5'd0) state <= S_CFILL;                // last row done
                    else rd <= rd - 5'd1;                            // next row up
                end
                // Fill the rows above the write position with empty rows
                S_CFILL: begin
                    if (wr < 5'd20) begin
                        wr <= wr - 5'd1;                             // the write block empties this row
                    end else begin
                        sc_rem <= level;                             // level + 1 additions in total
                        state  <= (nclr == 3'd0) ? S_SPAWN : S_SCORE;
                    end
                end
                // Score = points * (level + 1) by repeated addition, then count the lines and update the level
                S_SCORE: begin
                    score <= score + {14'd0, pts};
                    if (sc_rem == 8'd0) begin
                        lines <= lines + {13'd0, nclr};              // total lines
                        if ({1'b0, lm} + {2'd0, nclr} >= 5'd10) begin
                            lm    <= lm + {1'b0, nclr} - 4'd10;      // wrap the tens counter
                            level <= level + 8'd1;                   // next level
                        end else begin
                            lm <= lm + {1'b0, nclr};
                        end
                        state <= S_SPAWN;
                    end else begin
                        sc_rem <= sc_rem - 8'd1;                     // more additions to do
                    end
                end
                // Pick the next piece: a random kind that is not yet used in this bag, then test that it fits
                S_SPAWN: begin
                    if (bag == 7'h7F) begin
                        bag <= 7'd0;                                 // bag empty: refill
                    end else if (cand != 3'd7 && !bag[cand]) begin
                        kind  <= cand;                               // take it
                        bag[cand] <= 1'b1;                           // mark it used
                        rot   <= 2'd0;                               // first orientation
                        x     <= 5'sd3;                              // top centre
                        y     <= 5'd0;
                        op    <= OP_SPAWN;                           // test that it fits
                        tk    <= 2'd0;
                        hit_acc <= 1'b0;
                        state <= S_TEST;
                    end
                end
                default: state <= S_START;
            endcase
        end
    end

endmodule

`default_nettype wire
