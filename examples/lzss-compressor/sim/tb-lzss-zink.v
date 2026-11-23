// tb-lzss-zink.v - testbench: a model of the RP2350 sends a command byte stream to the engine through real Zen Link frames and writes the reply bytes as hex text.
// Plusargs: +cmd=<hex file, one byte per line>  +ncmd=<number of command bytes>  +nrx=<number of reply bytes to collect>  +out=<output hex file>  [+div=<clocks per bit>]
// With +div the testbench first switches the engine to that bit time (0x7E command, then the bridge rate), and at the end switches back and checks a reset still answers.
`timescale 1ns/1ps

module tb_lzss_zink;

    // Clock cycles per UART bit at power-up in this simulation (small, to keep it fast)
    localparam CPB = 16;
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
    // Command bytes and collected replies
    reg [7:0] cmd [0:65535];
    reg [7:0] got [0:65535];
    // File names
    reg [1023:0] cmd_name, out_name;
    // Counters and loop variables
    integer ncmd, nrx, sent, ng, free_b, k, c, div, fo;

    // This contains the instantiation for the design under test
    lzss_zen4_top #(.CPB(CPB), .IDLE_BITS(18), .POR_BITS(4)) dut (.clk(clk), .clk_core(clk_core), .btn1(1'b1), .link_clk_in(m_clk), .link_csn_in(m_csn), .link_d_in(d_bus),
        .link_d_out(f_out), .link_d_oe(f_oe), .led1(led1), .led2(led2));

    // Sends the command bytes cmd[from..to-1] and collects replies until nwant reply bytes are in got[] (starting at gstart)
    task run_io(input integer from, input integer to, input integer gstart, input integer nwant);
        integer pos, gn, guard;
        begin
            pos = from; gn = gstart; guard = 0;
            while ((pos < to || gn < gstart + nwant) && guard < 400000) begin
                // Queue what fits
                if (pos < to) begin
                    rdn(16'h0103, 1); free_b = rb[0];
                    k = to - pos; if (k > free_b) k = free_b; if (k > 100) k = 100;
                    if (k > 0) begin
                        for (c = 0; c < k; c = c + 1) wb[c] = cmd[pos + c];
                        wrn(16'h0180, k);
                        pos = pos + k;
                    end
                end
                // Take what has arrived
                rdn(16'h0102, 1); c = rb[0];
                if (c > 100) c = 100;
                if (c > 0) begin
                    rdn(16'h0180, c);
                    for (k = 0; k < c; k = k + 1) begin got[gn] = rb[k]; gn = gn + 1; end
                end
                guard = guard + 1;
                #(20_000);
            end
            if (gn < gstart + nwant) begin errs = errs + 1; $display("FAIL: only %0d of %0d reply bytes arrived", gn - gstart, nwant); end
        end
    endtask

    // Switches engine and bridge to the bit time d (0x7E d, ack 0x7E at the old rate, then the bridge registers)
    task set_baud(input integer d);
        begin
            cmd[0] = 8'h7E; cmd[1] = d;
            run_io(0, 2, 0, 1);
            check8(got[0], 8'h7E, "baud ack");
            wr1(16'h0104, d[7:0]); wr1(16'h0105, d[15:8]);
        end
    endtask

    // This block runs the test
    initial begin
        if (!$value$plusargs("cmd=%s", cmd_name)) begin $display("FAIL: +cmd missing"); $finish; end
        if (!$value$plusargs("out=%s", out_name)) begin $display("FAIL: +out missing"); $finish; end
        if (!$value$plusargs("ncmd=%d", ncmd)) begin $display("FAIL: +ncmd missing"); $finish; end
        if (!$value$plusargs("nrx=%d", nrx)) begin $display("FAIL: +nrx missing"); $finish; end
        div = 0;
        if (!$value$plusargs("div=%d", div)) div = 0;
        #(20 * 3000);
        rdn(16'h0000, 2); check8(rb[0], 8'h5A, "link ID"); check8(rb[1], 8'hA5, "link ID_INV");
        if (div != 0) set_baud(div);
        $readmemh(cmd_name, cmd);
        run_io(0, ncmd, 0, nrx);
        fo = $fopen(out_name, "w");
        for (k = 0; k < nrx; k = k + 1) $fwrite(fo, "%02x\n", got[k]);
        $fclose(fo);
        // Return to the default rate with a baud command and check the link still answers there
        if (div != 0) begin
            cmd[0] = 8'h7E; cmd[1] = CPB;
            run_io(0, 2, 0, 1);
            check8(got[0], 8'h7E, "baud ack back");
            wr1(16'h0104, CPB); wr1(16'h0105, 8'd0);
            cmd[0] = 8'h00;
            run_io(0, 1, 0, 1);
            check8(got[0], 8'h00, "reset ack at the default rate");
            if (errs == 0) $display("BAUD back-to-default ok");
        end
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
