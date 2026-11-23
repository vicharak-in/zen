// chess_make.v - decodes one move on a board, combinational: the squares it changes, new castling rights, en passant, material and king squares
// The core writes the squares one per clock. No legality test here: the core plays the move and then looks whether the mover's king is attacked. Equals make() of model/chess_game.py.
`default_nettype none

module chess_make (
    input  wire [3:0]   pc,         // the moving piece (read by the core)
    input  wire [3:0]   tc,         // the piece on the target square (read by the core)
    input  wire [5:0]   frm,        // move from
    input  wire [5:0]   to,         // move to
    input  wire [1:0]   promo,      // promotion piece: 0 queen, 1 rook, 2 bishop, 3 knight
    input  wire [3:0]   castle,     // castling rights before: 1 white short, 2 white long, 4 black short, 8 black long
    input  wire         epv,        // en passant square valid
    input  wire [5:0]   eps,        // en passant square
    input  wire signed [15:0] mat,  // material, white minus black
    input  wire [5:0]   ksqw,       // white king square
    input  wire [5:0]   ksqb,       // black king square
    output wire         is_ep_o,    // the move is an en passant capture
    output wire [5:0]   capsq_o,    // square of the pawn taken en passant
    output wire [3:0]   newp_o,     // piece standing on the target square afterwards (promotion applied)
    output wire         cas_o,      // the move is castling
    output wire [5:0]   rk_f_o,     // castling: rook origin square
    output wire [5:0]   rk_t_o,     // castling: rook target square
    output wire [3:0]   rook_o,     // castling: the rook piece
    output reg  [3:0]   ncastle,    // castling rights after
    output reg          nepv,       // en passant square valid after
    output reg  [5:0]   neps,       // en passant square after
    output reg  signed [15:0] nmat, // material after
    output reg  [5:0]   nksqw,      // white king square after
    output reg  [5:0]   nksqb,      // black king square after
    output reg          irrev       // pawn move or capture (resets the 50-move counter)
);
    // Piece values in centipawns by type
    function [9:0] valf(input [2:0] t);
        case (t)
            3'd1: valf = 10'd100;
            3'd2: valf = 10'd320;
            3'd3: valf = 10'd330;
            3'd4: valf = 10'd500;
            3'd5: valf = 10'd900;
            default: valf = 10'd0;
        endcase
    endfunction
    // Castling rights a move from or to this square keeps
    function [3:0] keep(input [5:0] sq);
        case (sq)
            6'd4:  keep = 4'd12;
            6'd0:  keep = 4'd13;
            6'd7:  keep = 4'd14;
            6'd60: keep = 4'd3;
            6'd56: keep = 4'd7;
            6'd63: keep = 4'd11;
            default: keep = 4'd15;
        endcase
    endfunction

    // Colour and type of the moving piece
    wire       col = pc[3];
    wire [2:0] ty  = pc[2:0];
    // En passant capture and promotion
    wire is_ep    = (ty == 3'd1) && epv && (to == eps) && (tc == 4'd0) && (frm[2:0] != to[2:0]);
    wire [5:0] capsq = col ? (to + 6'd8) : (to - 6'd8);
    wire promo_now = (ty == 3'd1) && (to[5:3] == 3'd0 || to[5:3] == 3'd7);
    wire [2:0] ptype = (promo == 2'd0) ? 3'd5 : ((promo == 2'd1) ? 3'd4 : ((promo == 2'd2) ? 3'd3 : 3'd2));
    wire [3:0] newp = promo_now ? {col, ptype} : pc;
    // Castling: the king moves two squares
    wire cas_s = (ty == 3'd6) && (to == frm + 6'd2);
    wire cas_l = (ty == 3'd6) && (frm == to + 6'd2);
    // Material gained by the mover
    wire [11:0] gain0 = is_ep ? 12'd100 : {2'd0, valf(tc[2:0])};
    wire [11:0] gain  = promo_now ? (gain0 + {2'd0, valf(ptype)} - 12'd100) : gain0;

    // What the core needs to write the move square by square (the core has one write port, so the logic stays small)
    assign is_ep_o = is_ep;
    assign capsq_o = capsq;
    assign newp_o  = newp;
    assign cas_o   = cas_s | cas_l;
    assign rk_f_o  = cas_s ? (frm + 6'd3) : (frm - 6'd4);
    assign rk_t_o  = cas_s ? (frm + 6'd1) : (frm - 6'd1);
    assign rook_o  = {col, 3'd4};

    // This block makes the rest of the new position
    always @* begin
        nmat    = col ? (mat - $signed({4'd0, gain})) : (mat + $signed({4'd0, gain}));
        ncastle = castle & keep(frm) & keep(to);
        nepv    = (ty == 3'd1) && ((to - frm == 6'd16) || (frm - to == 6'd16));
        neps    = ({1'b0, frm} + {1'b0, to}) >> 1;
        nksqw   = (ty == 3'd6 && !col) ? to : ksqw;
        nksqb   = (ty == 3'd6 && col) ? to : ksqb;
        irrev   = (ty == 3'd1) || (tc != 4'd0) || is_ep;
    end
endmodule

`default_nettype wire
