// tb_regs.v - checks the register map: every frame byte, score, lines, level, over and the seq/busy byte
`timescale 1ns/1ps

module tb_regs;
    // Test values
    reg [199:0] board = 200'h0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF01;
    reg [15:0] mask = 16'h4E40;
    reg [4:0] px = 5'd7, py = 5'd13;
    reg [23:0] score = 24'h12ABCD;
    reg [15:0] lines = 16'h0A5B;
    reg [7:0] level = 8'h7E;
    reg over = 1'b1, busy = 1'b1;
    reg [6:0] seq = 7'h55;
    reg [1:0] buttons = 2'b10;
    reg [15:0] addr = 16'h0000;
    wire [7:0] rdata;
    integer i, errors = 0;

    // This contains the instantiation for the register map
    tetris_regs dut (.addr(addr), .buttons(buttons), .board(board), .mask(mask), .px(px), .py(py), .score(score), .lines(lines),
        .level(level), .over(over), .seq(seq), .busy(busy), .rdata(rdata));

    // Read one address and compare
    task rd;
        input [15:0] a;
        input [7:0] want;
        begin
            addr = a;
            #1;
            if (rdata !== want) begin
                errors = errors + 1;
                $display("FAIL: addr %h read %h want %h", a, rdata, want);
            end
        end
    endtask

    initial begin
        for (i = 0; i < 25; i = i + 1) rd(16'h0150 + i, board[8*i +: 8]);
        rd(16'h0169, 8'h40); rd(16'h016A, 8'h4E); rd(16'h016B, 8'h07); rd(16'h016C, 8'h0D);
        rd(16'h016D, 8'hCD); rd(16'h016E, 8'hAB); rd(16'h016F, 8'h12);
        rd(16'h0170, 8'h5B); rd(16'h0171, 8'h0A);
        rd(16'h0172, 8'h7E); rd(16'h0173, 8'h01);
        rd(16'h0174, {7'h55, 1'b1});
        rd(16'h0140, 8'h02);
        rd(16'h0141, 8'h02);
        rd(16'h0100, 8'h00); rd(16'h0175, 8'h00); rd(16'h0200, 8'h00);
        if (errors == 0) $display("ALL PASSED");
        else $display("%0d CHECKS FAILED", errors);
        $finish;
    end
endmodule
