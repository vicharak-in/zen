// tb_runner_regs.v - checks every byte of the platformer register map
`timescale 1ns/1ps

module tb_runner_regs;
    reg [15:0] addr = 16'd0;
    wire [7:0] rdata;
    integer fails = 0;
    // This contains the instantiation for the register map under test
    runner_regs #(.NC(20)) dut (
        .addr(addr), .buttons(2'b10), .hero_x(11'h5A7), .hero_y(8'hC3), .ground(1'b1), .over(1'b0), .won(1'b1),
        .score(24'hABCDEF), .lives(2'd2), .coins(8'd9), .coin(20'hF5A31), .ex({11'h7FF, 11'h123, 11'h456, 11'h0AB}),
        .alive(4'b1010), .seq(7'h55), .busy(1'b1), .rdata(rdata)
    );
    // Check one address
    task expect;
        input [15:0] a;
        input [7:0] v;
        begin
            addr = a;
            #1;
            if (rdata !== v) begin
                $display("FAIL: addr %h gives %h, want %h", a, rdata, v);
                fails = fails + 1;
            end
        end
    endtask
    initial begin
        expect(16'h0140, 8'h02); expect(16'h0141, 8'd4);
        expect(16'h0150, 8'hA7); expect(16'h0151, 8'h05); expect(16'h0152, 8'hC3);
        expect(16'h0153, 8'b00000101);
        expect(16'h0154, 8'hEF); expect(16'h0155, 8'hCD); expect(16'h0156, 8'hAB);
        expect(16'h0157, 8'd2); expect(16'h0158, 8'd9);
        expect(16'h0159, 8'h31); expect(16'h015A, 8'h5A); expect(16'h015B, 8'h0F); expect(16'h015C, 8'h00);
        // enemy 0 = 0x0AB, enemy 1 = 0x456, enemy 2 = 0x123, enemy 3 = 0x7FF; alive = 1010 (enemy 1 and 3)
        expect(16'h015D, 8'hAB); expect(16'h015E, 8'h00);
        expect(16'h015F, 8'h56); expect(16'h0160, 8'h84);
        expect(16'h0161, 8'h23); expect(16'h0162, 8'h01);
        expect(16'h0163, 8'hFF); expect(16'h0164, 8'h87);
        expect(16'h0165, 8'hAB);
        expect(16'h0166, 8'h00); expect(16'h014F, 8'h00);
        if (fails == 0) $display("ALL PASSED"); else $display("FAILED %0d", fails);
        $finish;
    end
endmodule
