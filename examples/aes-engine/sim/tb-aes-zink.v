// tb-aes-zink.v - self-checking testbench: a model of the RP2350 runs the AES engine through real Zen Link frames (Zen 4 board top, 50 MHz link clock and 25 MHz engine clock):
// version, key load, ECB encrypt of the FIPS-197 block, ECB decrypt back, and an unknown command.

`timescale 1ns/1ps

module tb_aes_zink;

    // Zen Link clock, 50 MHz
    reg clk = 1'b0;
    // Engine clock, 25 MHz
    reg clk_core = 1'b0;
    // The two clocks
    always #10 clk = ~clk;
    always #20 clk_core = ~clk_core;

    `include "zink-host-model.vh"

    // LED pins
    wire led1, led2;
    // Loop counter and wait guard
    integer i, guard;
    // Bytes waiting
    reg [7:0] cnt;

    // This contains the instantiation for the design under test
    aes_zen4_top dut (.clk(clk), .clk_core(clk_core), .btn1(1'b1), .link_clk_in(m_clk), .link_csn_in(m_csn), .link_d_in(d_bus), .link_d_out(f_out), .link_d_oe(f_oe), .led1(led1), .led2(led2));

    // Waits until at least n bytes have come back from the engine
    task wait_rx(input integer n);
        begin
            guard = 0; cnt = 0;
            while (cnt < n && guard < 400) begin
                #(100_000);
                rdn(16'h0102, 1); cnt = rb[0];
                guard = guard + 1;
            end
            if (cnt < n) begin errs = errs + 1; $display("FAIL: only %0d of %0d reply bytes arrived", cnt, n); end
        end
    endtask

    // This block runs the test
    initial begin
        #(20 * 3000);
        rdn(16'h0000, 2); check8(rb[0], 8'h5A, "link ID"); check8(rb[1], 8'hA5, "link ID_INV");
        // Version command: reply A E S and the configuration byte {MC_PAR, SB_LANES} = 0x11
        wr1(16'h0100, "V");
        wait_rx(4); rdn(16'h0180, 4);
        check8(rb[0], "A", "version A"); check8(rb[1], "E", "version E"); check8(rb[2], "S", "version S"); check8(rb[3], 8'h11, "version config");
        // Key 000102...0f
        wb[0] = "K"; for (i = 0; i < 16; i = i + 1) wb[i + 1] = i;
        wrn(16'h0180, 17);
        wait_rx(1); rdn(16'h0100, 1); check8(rb[0], "K", "key reply");
        // ECB encrypt 00112233445566778899aabbccddeeff: expect 69c4e0d86a7b0430d8cdb78070b4c55a (FIPS-197 appendix C.1)
        wb[0] = "E"; wb[1] = 8'd1; for (i = 0; i < 16; i = i + 1) wb[i + 2] = {i[3:0], i[3:0]};
        wrn(16'h0180, 18);
        wait_rx(16); rdn(16'h0180, 16);
        check8(rb[0], 8'h69, "ct 0"); check8(rb[1], 8'hc4, "ct 1"); check8(rb[2], 8'he0, "ct 2"); check8(rb[3], 8'hd8, "ct 3");
        check8(rb[4], 8'h6a, "ct 4"); check8(rb[5], 8'h7b, "ct 5"); check8(rb[6], 8'h04, "ct 6"); check8(rb[7], 8'h30, "ct 7");
        check8(rb[8], 8'hd8, "ct 8"); check8(rb[9], 8'hcd, "ct 9"); check8(rb[10], 8'hb7, "ct 10"); check8(rb[11], 8'h80, "ct 11");
        check8(rb[12], 8'h70, "ct 12"); check8(rb[13], 8'hb4, "ct 13"); check8(rb[14], 8'hc5, "ct 14"); check8(rb[15], 8'h5a, "ct 15");
        // ECB decrypt the same cipher text: back to 0011...ff
        wb[0] = "D"; wb[1] = 8'd1;
        wb[2] = 8'h69; wb[3] = 8'hc4; wb[4] = 8'he0; wb[5] = 8'hd8; wb[6] = 8'h6a; wb[7] = 8'h7b; wb[8] = 8'h04; wb[9] = 8'h30;
        wb[10] = 8'hd8; wb[11] = 8'hcd; wb[12] = 8'hb7; wb[13] = 8'h80; wb[14] = 8'h70; wb[15] = 8'hb4; wb[16] = 8'hc5; wb[17] = 8'h5a;
        wrn(16'h0180, 18);
        wait_rx(16); rdn(16'h0180, 16);
        for (i = 0; i < 16; i = i + 1) check8(rb[i], {i[3:0], i[3:0]}, "plain text");
        // Unknown command: reply X
        wr1(16'h0100, "Z");
        wait_rx(1); rdn(16'h0100, 1); check8(rb[0], "X", "unknown command reply");
        // The error LED stays off and the status shows idle
        if (led2 !== 1'b1) begin errs = errs + 1; $display("FAIL: LED 2 lit (FIFO overflow)"); end
        if (errs == 0) $display("ALL PASS"); else $display("SOME FAILED");
        $finish;
    end

    // Safety timeout
    initial begin
        #200_000_000;
        $display("FAIL: timeout");
        $finish;
    end

endmodule
