// tb_play.v - the computer's turn: the game waits, a service request leaves the game position alone, the move sent over the user bus is played
`timescale 1ns/1ps
module tb_play;
    reg clk = 1'b0;
    always #5 clk = ~clk;
    reg rst = 1'b1, ev_tick = 1'b0, a_in = 1'b0, b_in = 1'b0;
    reg u_wr = 1'b0; reg [15:0] u_addr = 16'd0; reg [7:0] u_wdata = 8'd0;
    wire busy, over, hold_p; wire [40*8-1:0] st; wire [31:0] svc_o;
    chess_core #(.DEPTH(1), .TWO_P(0)) dut (.clk(clk), .rst(rst), .restart(1'b0), .ev_tick(ev_tick), .a_in(a_in), .b_in(b_in), .busy(busy), .over(over), .hold_p(hold_p), .state_o(st),
        .u_wr(u_wr), .u_addr(u_addr), .u_wdata(u_wdata), .svc_o(svc_o));
    task wr(input [15:0] a, input [7:0] d); begin @(negedge clk); u_wr = 1'b1; u_addr = a; u_wdata = d; @(negedge clk); u_wr = 1'b0; end endtask
    task tick; begin @(negedge clk); ev_tick = 1'b1; @(negedge clk); ev_tick = 1'b0; repeat (6000) @(negedge clk); end endtask
    integer k, errs = 0, moves = 0;
    reg [255:0] before;
    initial begin
        repeat (4) @(negedge clk); rst = 1'b0; repeat (4) @(negedge clk);
        // Mode screen: mode 0 (vs computer) is the default, B starts the game
        tick; b_in = 1'b1; tick; b_in = 1'b0; tick;
        if (dut.phase == 2'd3) begin $display("FAIL: game did not start"); errs = errs + 1; end
        if (svc_o[2]) begin $display("FAIL: computer to move at white's turn"); errs = errs + 1; end
        // Pretend white has moved: black (the computer) is to move in the start position
        @(negedge clk); dut.side0 = 1'b1;
        repeat (4) @(negedge clk);
        if (!svc_o[2]) begin $display("FAIL: computer-to-move flag missing"); errs = errs + 1; end
        // The buttons do nothing on the computer's turn
        a_in = 1'b1; tick; a_in = 1'b0; tick; b_in = 1'b1; tick; b_in = 1'b0; tick;
        if (dut.side0 !== 1'b1 || dut.bds[255:0] !== 256'hcabedbac99999999000000000000000000000000000000001111111142365324) begin $display("FAIL: buttons changed the game on the computer's turn"); errs = errs + 1; end
        // A service request borrows the game position: the board of the start position with white to move, 20 moves
        before = dut.bds[255:0];
        for (k = 0; k < 32; k = k + 1) wr(16'h0180 + k, before[8*k +: 8]);
        wr(16'h01A0, 8'h0F); wr(16'h01A1, 8'd0); wr(16'h01A2, 8'd4); wr(16'h01A3, 8'd60); wr(16'h01A4, 8'd0); wr(16'h01A5, 8'd0);
        wr(16'h01A8, 8'd1);
        a_in = 1'b1; tick; a_in = 1'b0; tick;            // a button press while the RP2350 searches does nothing
        while (!svc_o[1]) begin
            @(negedge clk);
            if (svc_o[0]) begin moves = moves + 1; wr(16'h01A9, 8'd1); end
        end
        if (moves != 20) begin $display("FAIL: start position listed %0d moves", moves); errs = errs + 1; end
        if (dut.bds[255:0] !== before || dut.cur_v !== 1'b1 || dut.phase !== 2'd0) begin $display("FAIL: service changed the board or the cursor"); errs = errs + 1; end
        // The RP2350 restores the real position (black to move) before it plays
        wr(16'h01A0, 8'h2F);
        // The computer plays e7e5 (52 -> 36)
        wr(16'h01AD, 8'd52); wr(16'h01AE, 8'd36); wr(16'h01AF, 8'd0); wr(16'h01AC, 8'd1);
        repeat (6000) @(negedge clk);
        if (dut.side0 !== 1'b0 || dut.bds[4*36 +: 4] !== 4'd9 || dut.bds[4*52 +: 4] !== 4'd0) begin $display("FAIL: computer's move not played: side0=%b sq36=%0d sq52=%0d", dut.side0, dut.bds[4*36 +: 4], dut.bds[4*52 +: 4]); errs = errs + 1; end
        if (svc_o[2]) begin $display("FAIL: still waiting for the computer"); errs = errs + 1; end
        if (dut.last_f !== 8'd52 || dut.last_t !== 8'd36) begin $display("FAIL: last move not recorded"); errs = errs + 1; end
        if (errs == 0) $display("PASS: computer turn flow");
        $finish;
    end
endmodule
