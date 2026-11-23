// tb_svc.v - loads positions into chess_core and prints every legal move the generator finds, in order
// check_movegen.py compares the lists with the Python model
`timescale 1ns/1ps

module tb_svc;
    parameter N = 4000;
    reg clk = 1'b0;
    always #5 clk = ~clk;
    reg rst = 1'b1;
    reg u_wr = 1'b0; reg [15:0] u_addr = 16'd0; reg [7:0] u_wdata = 8'd0; wire [31:0] svc_o;
    // One user bus write
    task wr(input [15:0] a, input [7:0] d); begin @(negedge clk); u_wr = 1'b1; u_addr = a; u_wdata = d; @(negedge clk); u_wr = 1'b0; end endtask
    wire busy, over, hold_p;
    wire [40*8-1:0] st;

    // This contains the instantiation for the core under test
    chess_core dut (.clk(clk), .rst(rst), .restart(1'b0), .ev_tick(1'b0), .a_in(1'b0), .b_in(1'b0), .busy(busy), .over(over), .hold_p(hold_p), .state_o(st), .u_wr(u_wr), .u_addr(u_addr), .u_wdata(u_wdata), .svc_o(svc_o));

    reg [255:0] boards [0:N-1];
    reg [31:0]  metas  [0:N-1];
    reg [15:0]  mats   [0:N-1];
    integer i, t, k;
    reg [31:0] m;
    initial begin
        $readmemh("boards.hex", boards);
        $readmemh("meta.hex", metas);
        $readmemh("mats.hex", mats);
        repeat (4) @(negedge clk);
        rst = 1'b0;
        repeat (4) @(negedge clk);
        for (i = 0; i < N; i = i + 1) begin
            m = metas[i];
            for (k = 0; k < 32; k = k + 1) wr(16'h0180 + k, boards[i][8*k +: 8]);
            wr(16'h01A0, {2'd0, m[5], m[4], m[3:0]});
            wr(16'h01A1, {2'd0, m[13:8]});
            wr(16'h01A2, {2'd0, m[21:16]});
            wr(16'h01A3, {2'd0, m[29:24]});
            wr(16'h01A4, mats[i][7:0]);
            wr(16'h01A5, mats[i][15:8]);
            wr(16'h01A8, 8'd1);
            t = 0;
            while (!svc_o[1] && t < 400000) begin
                @(negedge clk); t = t + 1;
                if (svc_o[0]) begin
                    $display("M %0d %0d %0d %064x %0d %0d %0d %0d %0d %0d", dut.mv_f, dut.mv_t, dut.mv_p, dut.tbd, dut.tcas, dut.tepv, dut.tepv ? dut.teps : 6'd0, dut.tkw, dut.tkb, $signed(dut.tmat));
                    wr(16'h01A9, 8'd1);
                end
            end
            if (t >= 400000) begin $display("TIMEOUT %0d", i); $finish; end
            $display("P %0d %0d", i, t);
        end
        $display("DONE");
        $finish;
    end
endmodule
