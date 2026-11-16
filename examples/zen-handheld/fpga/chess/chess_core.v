// chess_core.v - the rules of "Chess" in hardware: all legal moves (castling, en passant, promotion), check, checkmate, stalemate,
// the 50-move and too-little-material draws, the cursor that lets two buttons pick any move, and the computer's search (DEPTH plies).
// One clock does one small step. The move generator walks the squares and directions; a candidate move is played on a copy of the board
// and kept only when the mover's king is not attacked afterwards (the attack scan walks the rays and knight jumps from the king).
// Everything here equals model/chess_game.py.
`default_nettype none

module chess_core #(
    parameter DEPTH = 1,            // plies of position storage (the game position only; the RP2350 borrows it while it searches, see svc_o)
    parameter TWO_P = 0             // 1 = two players only (the computer is never asked), used by the regression bench
) (
    input  wire         clk,        // 25 MHz fabric clock
    input  wire         rst,        // synchronous reset, starts a new game
    input  wire         restart,    // one-clock pulse: new game
    input  wire         ev_tick,    // one-clock pulse: look at the buttons
    input  wire         a_in,       // button A held
    input  wire         b_in,       // button B held
    output wire         busy,       // 1 while a tick is being worked out
    output wire         over,       // game over (mate or draw)
    output wire         hold_p,     // one-clock pulse: ask for a pause (not used by this game)
    output wire [40*8-1:0] state_o, // state bytes, same layout as pack() of the model
    input  wire         u_wr,       // user bus write strobe from the Zen Link
    input  wire [15:0]  u_addr,     // user bus address
    input  wire [7:0]   u_wdata,    // user bus write data
    output wire [31:0]  svc_o       // service status {mv_p, mv_t, mv_f, flags}: flags bit0 move ready, bit4 upload error, bit1 list done, bit2 computer to move, bit3 game over
);
    localparam P = DEPTH + 1;       // plies kept on the search stack (small data)
    localparam B = DEPTH;           // plies whose whole board is kept (the last ply is only counted)

    // States: top level
    localparam [5:0] S_START = 6'd0,  S_IDLE = 6'd1,  S_EV = 6'd2,    S_BT0 = 6'd3,   S_BT1 = 6'd4,   S_BT2 = 6'd5,   S_IM = 6'd6;
    // States: apply a move
    localparam [5:0] S_APMK  = 6'd7,  S_APC  = 6'd8;
    // States: write a move square by square
    localparam [5:0] K_1 = 6'd36, K_2 = 6'd37, K_3 = 6'd38, K_4 = 6'd39, K_5 = 6'd40, K_J = 6'd41, G_EVAL2 = 6'd42, G_RD = 6'd43, K_0 = 6'd44, K_0B = 6'd45;
    // States: move generator
    localparam [5:0] G_SQ    = 6'd10, G_ADDR = 6'd11, G_EVAL = 6'd12, G_C0 = 6'd13,   G_C1 = 6'd14,   G_C2 = 6'd15,   G_C3 = 6'd16;
    localparam [5:0] G_MK    = 6'd17, G_JUDGE = 6'd18, G_ADV = 6'd19, G_LEG = 6'd20,  G_END = 6'd21,  G_FIN = 6'd22;
    // States: attack scan
    localparam [5:0] A_INIT  = 6'd24, A_ADDR = 6'd25, A_EVAL = 6'd26, A_DONE = 6'd27;
    // States: search
    localparam [5:0] S_SRCH  = 6'd30, S_NODE = 6'd31, S_NODE2 = 6'd32, S_RET = 6'd33, S_PAR = 6'd34, S_ROOT = 6'd35;
    // What the generator does with every legal move
    localparam [2:0] GM_NODE = 3'd0, GM_FIRST = 3'd1, GM_NEXTP = 3'd2, GM_NEXTD = 3'd3, GM_FSEL = 3'd4, GM_DUMP = 3'd5, GM_SVC = 3'd6;
    // Service state: a legal move of the RP2350's scratch position is held until the RP2350 asks for the next one
    localparam [5:0] SV_WAIT = 6'd46;
    // Phases of the cursor
    localparam [1:0] PH_PIECE = 2'd0, PH_DEST = 2'd1, PH_MODE = 2'd3;
    // Game status
    localparam [2:0] ST_NORMAL = 3'd0, ST_CHECK = 3'd1, ST_MATED = 3'd2, ST_STALE = 3'd3, ST_D50 = 3'd4, ST_DMAT = 3'd5;
    localparam signed [15:0] MATE = 16'sd30000;
    localparam signed [15:0] NEG  = -16'sd32000;
    // Start position: square 0 (a1) in the low nibble
    localparam [255:0] START_BD = 256'hcabedbac99999999000000000000000000000000000000001111111142365324;

    // ---- State -------------------------------------------------------------------------------------------------------------------
    reg  [5:0]  state = S_START;
    reg  [15:0] lfsr = 16'hACE1;
    // Search stack: one position per ply (board, castling, en passant, king squares, material)
    reg  [256*B-1:0] bds = {B{256'd0}};
    reg  [4*P-1:0]   castv = {P{4'd0}};
    reg  [P-1:0]     epvv = {P{1'b0}};
    reg  [6*P-1:0]   epsv = {P{6'd0}}, kwv = {P{6'd0}}, kbv = {P{6'd0}};
    reg  [16*P-1:0]  matv = {P{16'd0}};
    // Per ply search values: best score, any legal move, in check, and the generator registers saved while a child is searched
    reg  [16*P-1:0]  bestv = {P{16'd0}};
    reg  [P-1:0]     anyv = {P{1'b0}}, chkv = {P{1'b0}};
    reg  [30*P-1:0]  stkv = {P{30'd0}};
    reg  [1:0]  pl = 2'd0;                    // current ply
    // Service interface (the RP2350 sends a position, the generator hands back its legal moves one by one, the RP2350 sends the computer's move)
    reg         sv_lock = 1'b0;                 // the RP2350 is searching: the buttons are ignored until it plays its move
    reg         sv_go = 1'b0, sv_next = 1'b0, sv_valid = 1'b0, sv_done = 1'b0;
    reg  [5:0]  bw_cnt = 6'd0;                  // board bytes written since the last position (must be 32 when the details arrive)
    reg         bad_up = 1'b0;                  // the last position upload did not have exactly 32 board bytes
    reg         pm_go = 1'b0;                   // the computer's move was sent
    reg  [5:0]  pm_f = 6'd0, pm_t = 6'd0;
    reg  [1:0]  pm_p = 2'd0;
    // Game values
    reg         side0 = 1'b0;                 // side to move at ply 0 (0 white, 1 black)
    reg  [7:0]  half = 8'd0;                  // half-move clock
    reg         over_r = 1'b0, mode = 1'b0;
    reg  [1:0]  phase = PH_MODE;
    reg  [2:0]  status = ST_NORMAL;
    reg  [7:0]  last_f = 8'd255, last_t = 8'd255, sel_from = 8'd255;
    reg         prev_a = 1'b0, prev_b = 1'b0, chord = 1'b0;
    // Cursor move
    reg  [5:0]  cur_f = 6'd0, cur_t = 6'd0;
    reg  [1:0]  cur_p = 2'd0;
    reg         cur_v = 1'b0;
    // Generator
    reg  [2:0]  gmode = GM_FIRST;
    reg  [6:0]  gs = 7'd0;                    // square being generated (64 = done)
    reg  [3:0]  gd = 4'd0;                    // direction or slot
    reg  [2:0]  gk = 3'd1;                    // step along a ray
    reg  [1:0]  gpr = 2'd0;                   // promotion variant
    reg         cray = 1'b0, cprom = 1'b0;    // the ray goes on, the candidate is a promotion
    reg  [5:0]  tsq = 6'd0, msq = 6'd0;       // target square and the square in between (double pawn push)
    reg         tv = 1'b0;                    // target on the board
    reg  [5:0]  mv_f = 6'd0, mv_t = 6'd0;     // candidate move
    reg  [1:0]  mv_p = 2'd0;
    // Played candidate (copy of the position after the move)
    reg  [255:0] tbd = 256'd0;
    reg          mk_ap = 1'b0;               // the move being written is played for real (else it is a candidate)
    reg  [3:0]  tcas = 4'd0;
    reg         tepv = 1'b0;
    reg  [5:0]  teps = 6'd0, tkw = 6'd0, tkb = 6'd0;
    reg  signed [15:0] tmat = 16'sd0;
    reg         tirr = 1'b0;
    // Attack scan
    reg  [5:0]  asq = 6'd0;
    reg         acol = 1'b0, ahit = 1'b0;
    reg  [4:0]  ad = 5'd0;
    reg  [2:0]  ak = 3'd1;
    reg  [5:0]  aret = S_IDLE;
    reg  [5:0]  asq_t = 6'd0;
    reg         atv = 1'b0;
    // Passes of the cursor
    reg         after = 1'b0, havef = 1'b0, anyl_g = 1'b0, chk_g = 1'b0;
    reg  [5:0]  fst_f = 6'd0, fst_t = 6'd0;
    reg  [1:0]  fst_p = 2'd0;
    // Search
    reg  signed [15:0] ret = 16'sd0, rbest = NEG;
    reg  [5:0]  rm_f = 6'd0, rm_t = 6'd0;
    reg  [1:0]  rm_p = 2'd0;
    reg  [5:0]  rb_f = 6'd0, rb_t = 6'd0;       // best root move so far
    reg  [1:0]  rb_p = 2'd0;
    // Insufficient material scan
    reg  [6:0]  isq = 7'd0;
    reg  [3:0]  iminor = 4'd0;
    reg         ibad = 1'b0;

    assign busy   = (state != S_IDLE);
    assign over   = over_r;
    assign hold_p = 1'b0;
    // Status for the RP2350: the computer is to move when the game waits for it
    assign svc_o = {6'd0, mv_p, 2'd0, mv_t, 2'd0, mv_f, 3'd0, bad_up, over_r, (state == S_IDLE && !mode && side0 && !over_r && !pm_go && !sv_go), sv_done, sv_valid};

    // ---- Offsets into the per-ply vectors (case tables instead of multipliers) ------------------------------------------------------
    wire [1:0] pn = pl + 2'd1;
    wire [1:0] pb = (pl > B - 1) ? (B - 1) : pl;                       // ply whose board is read
    // Offsets of ply pl and ply pl+1 for widths 4, 6, 16, 30 and 256 (constants only: shifts and adds)
    wire [9:0] o4  = {pl, 2'b00},           o4n  = {pn, 2'b00};
    wire [9:0] o6  = {pl, 2'b00} + {pl, 1'b0}, o6n = {pn, 2'b00} + {pn, 1'b0};
    wire [9:0] o16 = {pl, 4'b0000},         o16n = {pn, 4'b0000};
    wire [9:0] o30 = {pl, 5'b00000} - {pl, 1'b0}, o30n = {pn, 5'b00000} - {pn, 1'b0};
    wire [9:0] ob  = {pb, 8'h00}, obn = {pn, 8'h00};

    // ---- Current ply views --------------------------------------------------------------------------------------------------------
    wire [255:0] bdc   = bds[ob +: 256];
    wire [3:0]   castc = castv[o4 +: 4];
    wire         epvc  = epvv[pl];
    wire [5:0]   epsc  = epsv[o6 +: 6];
    wire [5:0]   kwc   = kwv[o6 +: 6];
    wire [5:0]   kbc   = kbv[o6 +: 6];
    wire signed [15:0] matc = matv[o16 +: 16];
    wire         gside = side0 ^ pl[0];
    wire [5:0]   ksq_c = gside ? kbc : kwc;

    // ---- The one read port of the game board: one 64-to-1 selector serves every state that looks at a square --------------------------
    reg  [5:0] rsq;
    // This block picks the square the port reads in the current state
    always @* begin
        case (state)
            G_EVAL:  rsq = tsq;                 // target of the candidate
            G_EVAL2: rsq = msq;                 // square in between (double pawn push)
            K_0:     rsq = mv_f;                // moving piece
            K_0B:    rsq = mv_t;                // piece on the target
            S_IM:    rsq = isq[5:0];            // material scan
            default: rsq = gs[5:0];             // generator square (G_SQ, G_RD)
        endcase
    end
    wire [3:0] rd = bdc[4*rsq +: 4];
    // Pieces latched for the move being written
    reg  [3:0] pcr = 4'd0, tcr = 4'd0;
    // Piece of the generator square (kept for the whole square)
    reg  [3:0] gpcr = 4'd0;

    // ---- State bytes ---------------------------------------------------------------------------------------------------------------
    wire [255:0] bd0 = bds[255:0];
    wire [7:0] b_frm = (over_r || phase == PH_MODE || (phase == PH_PIECE && !cur_v)) ? 8'd255 :
                       (phase == PH_PIECE) ? {2'd0, cur_f} : (cur_v ? {2'd0, cur_f} : sel_from);
    wire [7:0] b_to  = (over_r || phase == PH_MODE || phase == PH_PIECE || !cur_v) ? 8'd255 : {2'd0, cur_t};
    wire [7:0] b_pr  = (over_r || phase != PH_DEST || !cur_v) ? 8'd0 : {6'd0, cur_p};
    assign state_o = {half, last_t, last_f, b_pr, b_to, b_frm,
                      over_r, mode, phase, status, side0,
                      (epvv[0] ? epsv[2:0] : 3'd0), epvv[0], castv[3:0], bd0};

    // ---- Move play and square arithmetic --------------------------------------------------------------------------------------------
    wire         k_ep, k_cas;
    wire [5:0]   k_cap, k_rkf, k_rkt;
    wire [3:0]   k_newp, k_rook;
    wire [3:0]   ncas;
    wire         nepv;
    wire [5:0]   neps, nkw, nkb;
    wire signed [15:0] nmat;
    wire         nirr;
    // This contains the instantiation for the move player
    chess_make u_make (
        .pc(pcr), .tc(tcr), .frm(mv_f), .to(mv_t), .promo(mv_p), .castle(castc), .epv(epvc), .eps(epsc), .mat(matc), .ksqw(kwc), .ksqb(kbc),
        .is_ep_o(k_ep), .capsq_o(k_cap), .newp_o(k_newp), .cas_o(k_cas), .rk_f_o(k_rkf), .rk_t_o(k_rkt), .rook_o(k_rook), .ncastle(ncas), .nepv(nepv), .neps(neps), .nmat(nmat), .nksqw(nkw), .nksqb(nkb), .irrev(nirr)
    );

    // A step of -1, 0 or +1 times a distance, without a multiplier
    function signed [5:0] scale(input signed [1:0] st, input signed [4:0] dist);
        scale = (st == 2'sd1) ? {dist[4], dist} : ((st == -2'sd1) ? -{dist[4], dist} : 6'sd0);
    endfunction
    // Direction steps: N, NE, E, SE, S, SW, W, NW
    function signed [1:0] dff(input [2:0] d);
        case (d)
            3'd1, 3'd2, 3'd3: dff = 2'sd1;
            3'd5, 3'd6, 3'd7: dff = -2'sd1;
            default: dff = 2'sd0;
        endcase
    endfunction
    function signed [1:0] drf(input [2:0] d);
        case (d)
            3'd0, 3'd1, 3'd7: drf = 2'sd1;
            3'd3, 3'd4, 3'd5: drf = -2'sd1;
            default: drf = 2'sd0;
        endcase
    endfunction
    // Knight jumps
    function signed [2:0] knf(input [2:0] i);
        case (i)
            3'd0: knf = 3'sd1;  3'd1: knf = 3'sd2;  3'd2: knf = 3'sd2;  3'd3: knf = 3'sd1;
            3'd4: knf = -3'sd1; 3'd5: knf = -3'sd2; 3'd6: knf = -3'sd2; default: knf = -3'sd1;
        endcase
    endfunction
    function signed [2:0] knr(input [2:0] i);
        case (i)
            3'd0: knr = 3'sd2;  3'd1: knr = 3'sd1;  3'd2: knr = -3'sd1; 3'd3: knr = -3'sd2;
            3'd4: knr = -3'sd2; 3'd5: knr = -3'sd1; 3'd6: knr = 3'sd1;  default: knr = 3'sd2;
        endcase
    endfunction

    // Generator: the piece on square gs and the step to its target
    wire [2:0] gt   = gpcr[2:0];
    wire       slider = (gt == 3'd3) || (gt == 3'd4) || (gt == 3'd5);
    wire [2:0] sdir = (gt == 3'd3) ? {gd[1:0], 1'b1} : ((gt == 3'd4) ? {gd[1:0], 1'b0} : gd[2:0]);
    wire signed [2:0] pdr = gside ? -3'sd1 : 3'sd1;
    wire signed [4:0] kk5 = (gt == 3'd6) ? 5'sd1 : $signed({2'b00, gk});
    reg  signed [4:0] xf, xr;
    // This block picks the file and rank step of the current candidate
    always @* begin
        xf = 5'sd0; xr = 5'sd0;
        case (gt)
            3'd1: begin
                case (gd[1:0])
                    2'd0: begin xf = 5'sd0;  xr = pdr; end
                    2'd1: begin xf = 5'sd0;  xr = gside ? -5'sd2 : 5'sd2; end
                    2'd2: begin xf = -5'sd1; xr = pdr; end
                    default: begin xf = 5'sd1; xr = pdr; end
                endcase
            end
            3'd2: begin xf = knf(gd[2:0]); xr = knr(gd[2:0]); end
            default: begin xf = scale(dff(sdir), kk5); xr = scale(drf(sdir), kk5); end
        endcase
    end
    wire signed [5:0] nf6 = $signed({3'b000, gs[2:0]}) + xf;
    wire signed [5:0] nr6 = $signed({3'b000, gs[5:3]}) + xr;
    wire        tv_n  = (nf6 >= 0) && (nf6 <= 7) && (nr6 >= 0) && (nr6 <= 7);
    // Number of directions or slots of the piece
    wire [3:0] glim = (gt == 3'd1) ? 4'd4 : ((gt == 3'd2) ? 4'd8 : ((gt == 3'd3 || gt == 3'd4) ? 4'd4 : ((gt == 3'd5) ? 4'd8 : 4'd10)));
    // Candidate classification (target square tsq read one clock after it was computed)
    wire [3:0] tocc  = rd;                      // read port at the target square (state G_EVAL)
    wire       t_empty = (tocc == 4'd0);
    wire       t_enemy = !t_empty && (tocc[3] != gside);
    wire       p_start = gside ? (gs[5:3] == 3'd6) : (gs[5:3] == 3'd1);
    wire       p_last  = gside ? (tsq[5:3] == 3'd0) : (tsq[5:3] == 3'd7);
    reg        acc;
    // This block decides whether the candidate is a move to test
    always @* begin
        if (gt == 3'd1) begin
            case (gd[1:0])
                2'd0: acc = tv && t_empty;
                2'd1: acc = tv && p_start && t_empty;      // the square in between is checked next, in G_EVAL2
                default: acc = tv && (t_enemy || (t_empty && epvc && epsc == tsq));
            endcase
        end else begin
            acc = tv && (t_empty || t_enemy);
        end
    end
    // Castling: squares and rights
    wire [5:0] cbase = gside ? 6'd56 : 6'd0;
    wire       c_rs  = gside ? castc[2] : castc[0];
    wire       c_rl  = gside ? castc[3] : castc[1];
    wire [3:0] own_r = {gside, 3'd4};
    // Squares of the home rank of the side to move (rank 1 for white, rank 8 for black) by file
    function [3:0] home(input [255:0] bd, input blk, input [2:0] f);
        home = blk ? bd[4*(56 + f) +: 4] : bd[4*f +: 4];
    endfunction
    wire       c_ok_s = c_rs && (home(bdc, gside, 3'd5) == 4'd0) && (home(bdc, gside, 3'd6) == 4'd0) && (home(bdc, gside, 3'd7) == own_r);
    wire       c_ok_l = c_rl && (home(bdc, gside, 3'd1) == 4'd0) && (home(bdc, gside, 3'd2) == 4'd0) &&
                        (home(bdc, gside, 3'd3) == 4'd0) && (home(bdc, gside, 3'd0) == own_r);

    // ---- Attack scan geometry -------------------------------------------------------------------------------------------------------
    wire signed [5:0] anf = $signed({3'b000, asq[2:0]}) + ((ad < 5'd8) ? scale(dff(ad[2:0]), $signed({2'b00, ak})) : knf(ad[2:0]));
    wire signed [5:0] anr = $signed({3'b000, asq[5:3]}) + ((ad < 5'd8) ? scale(drf(ad[2:0]), $signed({2'b00, ak})) : knr(ad[2:0]));
    wire        atv_n = (anf >= 0) && (anf <= 7) && (anr >= 0) && (anr <= 7);
    wire [3:0]  aocc  = tbd[4*asq_t +: 4];
    wire        a_mine = (aocc != 4'd0) && (aocc[3] == acol);
    wire [2:0]  aty   = aocc[2:0];
    wire        a_pawn_dir = acol ? (ad == 5'd1 || ad == 5'd7) : (ad == 5'd3 || ad == 5'd5);
    wire        a_att = a_mine && ((aty == 3'd5) || (aty == 3'd4 && !ad[0]) || (aty == 3'd3 && ad[0]) ||
                                   (ak == 3'd1 && aty == 3'd6) || (ak == 3'd1 && aty == 3'd1 && a_pawn_dir));

    // ---- Search helpers ---------------------------------------------------------------------------------------------------------------
    wire signed [15:0] leaf = gside ? -matc : matc;
    wire signed [15:0] best_c = bestv[o16 +: 16];
    wire signed [15:0] node_val = !anyv[pl] ? (chkv[pl] ? (-MATE + {14'd0, pl}) : 16'sd0) : best_c;
    wire signed [15:0] par_score = -ret;
    wire signed [15:0] par_root  = -ret + $signed({14'd0, lfsr[1:0]});
    wire [29:0] stk_save = {gs, gd, gk, gpr, cray, cprom, mv_f, mv_t};
    wire [29:0] stk_load = stkv[o30 +: 30];

    // Buttons released alone (a release after both were down together does not count)
    wire a_rel = prev_a && !a_in && !chord;
    wire b_rel = prev_b && !b_in && !chord;
    // Rank of the square in between (double pawn push) and the next value of the random generator
    wire [2:0] mr = gs[5:3] + pdr[2:0];
    wire [15:0] lfsr_next = (lfsr >> 1) ^ (lfsr[0] ? 16'hB400 : 16'h0000);
    // Same move as the cursor move
    wire same_cur = cur_v && (mv_f == cur_f) && (mv_t == cur_t) && (mv_p == cur_p);

    // ---- Write port of the move copy: which square gets which piece in the states K_1..K_5 ------------------------------------------
    reg        wen;
    reg  [5:0] wsq;
    reg  [3:0] wval;
    // This block picks the square, the piece and whether to write in each write state
    always @* begin
        wen = 1'b0; wsq = mv_f; wval = 4'd0;
        case (state)
            K_1: begin wen = 1'b1; wsq = mv_f; wval = 4'd0; end
            K_2: begin wen = 1'b1; wsq = mv_t; wval = k_newp; end
            K_3: begin wen = 1'b1; wsq = k_cap; wval = 4'd0; end
            K_4: begin wen = 1'b1; wsq = k_rkf; wval = 4'd0; end
            K_5: begin wen = 1'b1; wsq = k_rkt; wval = k_rook; end
            default: ;
        endcase
    end

    // ---- Game state machine --------------------------------------------------------------------------------------------------------------
    // This block is the whole chess machine; a reset or restart starts a new game, otherwise one state per clock
    always @(posedge clk) begin
        if (rst || restart) begin
            state <= S_START;                                   // new game
        end else begin
            case (state)
                // New game: start position and the mode choice screen
                S_START: begin
                    bds[255:0] <= START_BD; castv[3:0] <= 4'd15; epvv[0] <= 1'b0; epsv[5:0] <= 6'd0;
                    kwv[5:0] <= 6'd4; kbv[5:0] <= 6'd60; matv[15:0] <= 16'd0;
                    side0 <= 1'b0; half <= 8'd0; over_r <= 1'b0; mode <= (TWO_P != 0); phase <= PH_MODE; status <= ST_NORMAL;
                    last_f <= 8'd255; last_t <= 8'd255; sel_from <= 8'd255;
                    prev_a <= 1'b0; prev_b <= 1'b0; chord <= 1'b0; cur_v <= 1'b0; pl <= 2'd0;
                    sv_lock <= 1'b0; sv_go <= 1'b0; sv_next <= 1'b0; sv_valid <= 1'b0; sv_done <= 1'b0; pm_go <= 1'b0;
                    state <= S_IDLE;
                end
                // Wait for a tick; ticks are ignored after the game is over
                S_IDLE: begin
                    // A position from the RP2350: list its legal moves on ply 1 (the game position on ply 0 is left alone)
                    if (sv_go) begin
                        sv_go <= 1'b0; sv_next <= 1'b0; sv_lock <= 1'b1; pl <= 2'd0; gmode <= GM_SVC; gs <= 7'd0; state <= bad_up ? S_IDLE : G_SQ;
                        if (bad_up) sv_done <= 1'b1;               // a broken upload is not listed: done at once with the error flag
                    // The computer's move from the RP2350: play it in the game
                    end else if (pm_go) begin
                        pm_go <= 1'b0; sv_lock <= 1'b0;
                        if (!over_r && !mode && side0) begin mv_f <= pm_f; mv_t <= pm_t; mv_p <= pm_p; state <= S_APMK; end
                    end else if (ev_tick && !over_r && !sv_lock) state <= S_EV;
                end
                // A tick: look at the buttons (they count on release) and do what the phase asks
                S_EV: begin
                    chord <= (a_in && b_in) ? 1'b1 : ((!a_in && !b_in) ? 1'b0 : chord);
                    prev_a <= a_in; prev_b <= b_in; pl <= 2'd0;
                    if (phase == PH_MODE) begin
                        if (a_rel) begin if (TWO_P == 0) mode <= ~mode; state <= S_IDLE; end
                        else if (b_rel) state <= S_BT0;
                        else state <= S_IDLE;
                    end else if (!mode && side0) begin
                        state <= S_IDLE;                         // the computer's turn: the RP2350 sends its move, the buttons do nothing
                    end else if (phase == PH_PIECE) begin
                        if (a_rel) begin gmode <= GM_NEXTP; after <= 1'b0; havef <= 1'b0; gs <= 7'd0; state <= G_SQ; end
                        else if (b_rel) begin sel_from <= {2'd0, cur_f}; phase <= PH_DEST; state <= S_IDLE; end
                        else state <= S_IDLE;
                    end else begin
                        if (a_rel) begin gmode <= GM_NEXTD; after <= !cur_v; gs <= 7'd0; state <= G_SQ; end
                        else if (b_rel) begin
                            if (!cur_v) begin gmode <= GM_FSEL; phase <= PH_PIECE; gs <= 7'd0; state <= G_SQ; end
                            else begin mv_f <= cur_f; mv_t <= cur_t; mv_p <= cur_p; state <= S_APMK; end
                        end else state <= S_IDLE;
                    end
                end
                // Start of a turn: is the king in check
                S_BT0: begin
                    pl <= 2'd0; tbd <= bdc; asq <= side0 ? kbv[5:0] : kwv[5:0]; acol <= ~side0; aret <= S_BT1; state <= A_INIT;
                end
                // Find the first legal move (and whether there is one)
                S_BT1: begin
                    chk_g <= ahit; gmode <= GM_FIRST; anyl_g <= 1'b0; cur_v <= 1'b0; gs <= 7'd0; state <= G_SQ;
                end
                // Status: no move is mate or stalemate, then the 50-move rule, then too little material, else check or normal
                S_BT2: begin
                    phase <= PH_PIECE; sel_from <= 8'd255;
                    if (!anyl_g) begin status <= chk_g ? ST_MATED : ST_STALE; over_r <= 1'b1; state <= S_IDLE; end
                    else if (half >= 8'd100) begin status <= ST_D50; over_r <= 1'b1; state <= S_IDLE; end
                    else begin isq <= 7'd0; iminor <= 4'd0; ibad <= 1'b0; state <= S_IM; end
                end
                // Count the pieces: any pawn, rook or queen, or more than one knight or bishop means play goes on
                S_IM: begin
                    if (isq[6]) begin
                        if (!ibad && iminor <= 4'd1) begin status <= ST_DMAT; over_r <= 1'b1; end
                        else status <= chk_g ? ST_CHECK : ST_NORMAL;
                        state <= S_IDLE;
                    end else begin
                        if (rd[2:0] == 3'd1 || rd[2:0] == 3'd4 || rd[2:0] == 3'd5) ibad <= 1'b1;
                        if (rd[2:0] == 3'd2 || rd[2:0] == 3'd3) iminor <= (iminor == 4'd15) ? iminor : iminor + 4'd1;
                        isq <= isq + 7'd1;
                    end
                end
                // Play the move in mv_f, mv_t, mv_p on a copy
                S_APMK: begin
                    tbd <= bdc; mk_ap <= 1'b1; state <= K_0;
                end
                // Make it the game position, the other side moves, then the next turn begins
                S_APC: begin
                    bds[255:0] <= tbd; castv[3:0] <= tcas; epvv[0] <= tepv; epsv[5:0] <= teps; kwv[5:0] <= tkw; kbv[5:0] <= tkb; matv[15:0] <= tmat;
                    side0 <= ~side0;
                    half <= tirr ? 8'd0 : ((half == 8'd255) ? half : half + 8'd1);
                    last_f <= {2'd0, mv_f}; last_t <= {2'd0, mv_t};
                    state <= S_BT0;
                end

                // ---- Move generator -------------------------------------------------------------------------------------------------------
                // Next square: skip empty squares and the other side's pieces
                G_SQ: begin
                    if (gs[6]) state <= G_END;
                    else if (rd == 4'd0 || rd[3] != gside) gs <= gs + 7'd1;
                    else begin gpcr <= rd; gd <= 4'd0; gk <= 3'd1; gpr <= 2'd0; state <= G_ADDR; end
                end
                // Target square of the current direction and step
                G_ADDR: begin
                    if (gd >= glim) begin gs <= gs + 7'd1; state <= G_SQ; end
                    else if (gt == 3'd6 && gd >= 4'd8) state <= G_C0;
                    else begin tsq <= {nr6[2:0], nf6[2:0]}; tv <= tv_n; msq <= {mr, gs[2:0]}; state <= G_EVAL; end
                end
                // Is it a move to test (the ray goes on past empty squares, a pawn reaching the last rank tries four pieces)
                G_EVAL: begin
                    if (gt == 3'd1 && gd[1:0] == 2'd1) begin
                        // Double pawn push: target empty and on the start rank, then look at the square in between
                        if (acc) state <= G_EVAL2;
                        else begin cray <= 1'b0; cprom <= 1'b0; state <= G_ADV; end
                    end else if (!acc) begin cray <= 1'b0; cprom <= 1'b0; state <= G_ADV; end
                    else begin
                        mv_f <= gs[5:0]; mv_t <= tsq; mv_p <= 2'd0; gpr <= 2'd0;
                        cray <= slider && t_empty && (gk != 3'd7);
                        cprom <= (gt == 3'd1) && p_last;
                        state <= G_MK;
                    end
                end
                // Double pawn push, second look: the square in between must be empty too
                G_EVAL2: begin
                    if (rd != 4'd0) begin cray <= 1'b0; cprom <= 1'b0; state <= G_ADV; end
                    else begin
                        mv_f <= gs[5:0]; mv_t <= tsq; mv_p <= 2'd0; gpr <= 2'd0;
                        cray <= 1'b0; cprom <= 1'b0; state <= G_MK;
                    end
                end
                // Castling: rights and empty squares, the king not in check, and the square it passes not attacked
                G_C0: begin
                    if ((gd == 4'd8) ? c_ok_s : c_ok_l) begin
                        tbd <= bdc; asq <= cbase + 6'd4; acol <= ~gside; aret <= G_C1; state <= A_INIT;
                    end else begin cray <= 1'b0; cprom <= 1'b0; state <= G_ADV; end
                end
                G_C1: begin
                    if (ahit) begin cray <= 1'b0; cprom <= 1'b0; state <= G_ADV; end
                    else begin tbd <= bdc; asq <= (gd == 4'd8) ? (cbase + 6'd5) : (cbase + 6'd3); acol <= ~gside; aret <= G_C2; state <= A_INIT; end
                end
                G_C2: begin
                    if (ahit) begin cray <= 1'b0; cprom <= 1'b0; state <= G_ADV; end
                    else begin
                        mv_f <= cbase + 6'd4; mv_t <= (gd == 4'd8) ? (cbase + 6'd6) : (cbase + 6'd2); mv_p <= 2'd0; gpr <= 2'd0;
                        cray <= 1'b0; cprom <= 1'b0; state <= G_MK;
                    end
                end
                // Play the candidate on a copy and look whether the mover's king is attacked
                G_MK: begin
                    tbd <= bdc; mk_ap <= 1'b0; state <= K_0;
                end
                // Write the move into the copy, one square per clock (the write itself is after this block): origin, target, en passant victim, rook
                // Latch the moving piece and the piece on the target
                K_0:  begin pcr <= rd; state <= K_0B; end
                K_0B: begin tcr <= rd; state <= K_1; end
                // The new castling rights, en passant square, king squares and material are known now; the origin square is cleared
                K_1: begin
                    tcas <= ncas; tepv <= nepv; teps <= neps; tkw <= nkw; tkb <= nkb; tmat <= nmat; tirr <= nirr;
                    state <= K_2;
                end
                K_2: state <= k_ep ? K_3 : (k_cas ? K_4 : (mk_ap ? S_APC : K_J));
                K_3: state <= k_cas ? K_4 : (mk_ap ? S_APC : K_J);
                K_4: state <= K_5;
                K_5: state <= mk_ap ? S_APC : K_J;
                // A candidate is written: is the mover's king attacked now
                K_J: begin
                    asq <= gside ? tkb : tkw; acol <= ~gside; aret <= G_JUDGE; state <= A_INIT;
                end
                // Attacked: not legal
                G_JUDGE: begin
                    state <= ahit ? G_ADV : G_LEG;
                end
                // Next candidate: next promotion piece, next square along the ray, or next direction
                G_ADV: begin
                    if (cprom && gpr != 2'd3) begin gpr <= gpr + 2'd1; mv_p <= gpr + 2'd1; state <= G_MK; end
                    else if (cray) begin gk <= gk + 3'd1; state <= G_ADDR; end
                    else begin gd <= gd + 4'd1; gk <= 3'd1; gpr <= 2'd0; state <= G_ADDR; end
                end
                // A legal move: what happens depends on the pass
                G_LEG: begin
                    case (gmode)
                        // First legal move becomes the cursor
                        GM_FIRST: begin
                            cur_f <= mv_f; cur_t <= mv_t; cur_p <= mv_p; cur_v <= 1'b1; anyl_g <= 1'b1; state <= G_FIN;
                        end
                        // Next piece: the first move after the cursor move that belongs to another piece
                        GM_NEXTP: begin
                            if (!havef) begin fst_f <= mv_f; fst_t <= mv_t; fst_p <= mv_p; havef <= 1'b1; end
                            if (same_cur) begin after <= 1'b1; state <= G_ADV; end
                            else if (after && mv_f != cur_f) begin cur_f <= mv_f; cur_t <= mv_t; cur_p <= mv_p; state <= G_FIN; end
                            else state <= G_ADV;
                        end
                        // Next target of the selected piece
                        GM_NEXTD: begin
                            if (after && mv_f == sel_from[5:0]) begin cur_f <= mv_f; cur_t <= mv_t; cur_p <= mv_p; cur_v <= 1'b1; state <= G_FIN; end
                            else begin if (same_cur) after <= 1'b1; state <= G_ADV; end
                        end
                        // First target of the selected piece
                        GM_FSEL: begin
                            if (mv_f == sel_from[5:0]) begin cur_f <= mv_f; cur_t <= mv_t; cur_p <= mv_p; cur_v <= 1'b1; state <= G_FIN; end
                            else state <= G_ADV;
                        end
                        // Service: hold this move until the RP2350 has read it
                        GM_SVC: begin sv_valid <= 1'b1; state <= SV_WAIT; end
                        default: state <= G_ADV;
                    endcase
                end
                SV_WAIT: begin
                    if (sv_next) begin sv_next <= 1'b0; state <= G_ADV; end
                end
                // A pass ended early
                G_FIN: begin
                    if (gmode == GM_FIRST) state <= S_BT2;
                    else begin
                        if (gmode == GM_FSEL) sel_from <= 8'd255;
                        state <= S_IDLE;
                    end
                end
                // All squares done
                G_END: begin
                    case (gmode)
                        GM_FIRST: state <= S_BT2;
                        GM_NEXTP: begin cur_f <= fst_f; cur_t <= fst_t; cur_p <= fst_p; state <= S_IDLE; end
                        GM_NEXTD: begin cur_v <= 1'b0; state <= S_IDLE; end
                        GM_FSEL: begin sel_from <= 8'd255; state <= S_IDLE; end
                        GM_SVC: begin sv_done <= 1'b1; state <= S_IDLE; end
                        default: state <= S_IDLE;
                    endcase
                end

                // ---- Attack scan: is square asq attacked by colour acol on the board tbd --------------------------------------------------
                A_INIT: begin ad <= 5'd0; ak <= 3'd1; ahit <= 1'b0; state <= A_ADDR; end
                A_ADDR: begin
                    if (ad == 5'd16) state <= A_DONE;
                    else begin asq_t <= {anr[2:0], anf[2:0]}; atv <= atv_n; state <= A_EVAL; end
                end
                A_EVAL: begin
                    if (!atv) begin ad <= ad + 5'd1; ak <= 3'd1; state <= A_ADDR; end
                    else if (ad < 5'd8) begin
                        if (aocc == 4'd0) begin
                            if (ak == 3'd7) begin ad <= ad + 5'd1; ak <= 3'd1; end else ak <= ak + 3'd1;
                            state <= A_ADDR;
                        end else if (a_att) begin ahit <= 1'b1; state <= A_DONE; end
                        else begin ad <= ad + 5'd1; ak <= 3'd1; state <= A_ADDR; end
                    end else begin
                        if (aocc == {acol, 3'd2}) begin ahit <= 1'b1; state <= A_DONE; end
                        else begin ad <= ad + 5'd1; state <= A_ADDR; end
                    end
                end
                A_DONE: state <= aret;

                default: state <= S_START;
            endcase
            // The one write port of the copy (squares of the move being written)
            if (wen) tbd[4*wsq +: 4] <= wval;
            // Writes from the RP2350 over the user bus: the position to list (0x180 board, 0x1A0.. details; it borrows the game position, the RP2350
            // writes the real one back before it plays), and the commands (0x1A8 go, 0x1A9 next, 0x1AC play, 0x1A7 unlock)
            if (u_wr) begin
                // Board bytes shift in (the first byte written ends up as squares 0 and 1)
                if (u_addr[15:5] == 11'h00C) begin bds[255:0] <= {u_wdata, bds[255:8]}; bw_cnt <= bw_cnt + 6'd1; end
                case (u_addr)
                    16'h01A0: begin castv[3:0] <= u_wdata[3:0]; epvv[0] <= u_wdata[4]; side0 <= u_wdata[5]; bad_up <= (bw_cnt != 6'd32); bw_cnt <= 6'd0; end
                    16'h01A1: epsv[5:0] <= u_wdata[5:0];
                    16'h01A2: kwv[5:0]  <= u_wdata[5:0];
                    16'h01A3: kbv[5:0]  <= u_wdata[5:0];
                    16'h01A4: matv[7:0] <= u_wdata;
                    16'h01A5: matv[15:8] <= u_wdata;
                    16'h01A7: sv_lock <= 1'b0;
                    16'h01A8: begin sv_go <= 1'b1; sv_valid <= 1'b0; sv_done <= 1'b0; end
                    16'h01A9: begin sv_next <= 1'b1; sv_valid <= 1'b0; end
                    16'h01AD: pm_f <= u_wdata[5:0];
                    16'h01AE: pm_t <= u_wdata[5:0];
                    16'h01AF: pm_p <= u_wdata[1:0];
                    16'h01AC: pm_go <= 1'b1;
                    default: ;
                endcase
            end
        end
    end
endmodule

`default_nettype wire
