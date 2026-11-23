// tb-lzss-zink.v - testbench: a model of the RP2350 runs the LZSS firmware through real Zen Link frames (Zen 4 board top, 50 MHz link clock, 25 MHz CPU clock).
// It sends a reset and then 64-byte blocks in lock-step (the CPU's bit-banged UART cannot take the next block while it compresses), and writes the reply bytes as hex text.
// Plusargs: +in=<hex file, one byte per line>  +n=<number of bytes>  +out=<output hex file>
`timescale 1ns/1ps

module tb_lzss_zink;

    // Zen Link clock, 50 MHz
    reg clk = 1'b0;
    // CPU clock, 25 MHz
    reg clk_core = 1'b0;
    // The two clocks
    always #10 clk = ~clk;
    always #20 clk_core = ~clk_core;

    `include "zink-host-model.vh"

    // LED pins
    wire led1, led2;
    // Input bytes and collected replies
    reg [7:0] data [0:1023];
    reg [7:0] got [0:4095];
    // File names
    reg [1023:0] in_name, out_name;
    // Counters and loop variables
    integer n, pos, blk, ng, k, c, fo, free_b, sent, guard;

    // This contains the instantiation for the design under test, running the LZSS firmware
    picorv32_lzss_zen4_top #(.FIRMWARE("firmware/riscv/src/lzss.hex"), .POR_BITS(4)) dut (.clk(clk), .clk_core(clk_core), .btn1(1'b1), .link_clk_in(m_clk), .link_csn_in(m_csn),
        .link_d_in(d_bus), .link_d_out(f_out), .link_d_oe(f_oe), .led1(led1), .led2(led2));

    // Waits until nwant reply bytes have been collected into got[ng...]
    task recv(input integer nwant);
        integer have;
        begin
            have = 0; guard = 0;
            while (have < nwant && guard < 200000) begin
                rdn(16'h0102, 1); c = rb[0];
                if (c > nwant - have) c = nwant - have;
                if (c > 100) c = 100;
                if (c > 0) begin
                    rdn(16'h0180, c);
                    for (k = 0; k < c; k = k + 1) begin got[ng] = rb[k]; ng = ng + 1; end
                    have = have + c;
                end
                guard = guard + 1;
                #(20_000);
            end
            if (have < nwant) begin errs = errs + 1; $display("FAIL: only %0d of %0d reply bytes arrived", have, nwant); $finish; end
        end
    endtask

    // This block runs the test
    initial begin
        if (!$value$plusargs("in=%s", in_name)) begin $display("FAIL: +in missing"); $finish; end
        if (!$value$plusargs("out=%s", out_name)) begin $display("FAIL: +out missing"); $finish; end
        if (!$value$plusargs("n=%d", n)) begin $display("FAIL: +n missing"); $finish; end
        $readmemh(in_name, data);
        #(20 * 3000);
        rdn(16'h0000, 2); check8(rb[0], 8'h5A, "link ID"); check8(rb[1], 8'hA5, "link ID_INV");
        // Give the CPU time to start (power-on delay and firmware start-up)
        #(200_000);
        ng = 0;
        // Reset the history: send 0, expect 0
        wb[0] = 8'h00; wrn(16'h0180, 1);
        recv(1); check8(got[0], 8'h00, "reset ack");
        pos = 0;
        while (pos < n) begin
            blk = (n - pos > 64) ? 64 : (n - pos);
            // Request: length byte, then the raw bytes
            wb[0] = blk; wrn(16'h0180, 1);
            sent = 0;
            while (sent < blk) begin
                rdn(16'h0103, 1); free_b = rb[0];
                k = blk - sent; if (k > free_b) k = free_b; if (k > 100) k = 100;
                if (k > 0) begin
                    for (c = 0; c < k; c = c + 1) wb[c] = data[pos + sent + c];
                    wrn(16'h0180, k);
                    sent = sent + k;
                end
            end
            // Reply: compressed length, then that many bytes
            recv(1);
            c = got[ng - 1];
            recv(c);
            pos = pos + blk;
        end
        fo = $fopen(out_name, "w");
        for (k = 1; k < ng; k = k + 1) $fwrite(fo, "%02x\n", got[k]);
        $fclose(fo);
        rdn(16'h0101, 1);
        if (rb[0][2] || rb[0][3]) begin errs = errs + 1; $display("FAIL: overflow flag set (status %h)", rb[0]); end
        if (errs == 0) $display("DONE"); else $display("FAIL: %0d errors", errs);
        $finish;
    end

    // Safety timeout
    initial begin
        #3_000_000_000;
        $display("FAIL: timeout");
        $finish;
    end

endmodule
