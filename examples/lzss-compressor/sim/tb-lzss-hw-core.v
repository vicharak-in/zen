// This testbench plays the host: it sends a file to the hardware compressor over the UART protocol and writes the compressed block stream as hex text.
// Plusargs: +in=<hex file, one byte per line>  +n=<number of bytes>  +out=<output hex file>
`timescale 1 ns / 1 ps

module tb_lzss_hw_core;
    // Clock cycles per UART bit in this simulation (small, to keep it fast)
    localparam CPB = 16;
    // Clock cycles per UART bit the testbench uses right now (changes with the baud command)
    integer bitclk = CPB;
    // Clock period in ns
    localparam TCLK = 10;
    // System clock
    reg clk = 0;
    // Button level (high = not pressed)
    reg btn1 = 1;
    // Line from the testbench to the compressor
    reg rx_line = 1;
    // Line from the compressor to the testbench
    wire tx_line;
    // LED outputs
    wire led1, led2;

    // This contains the instantiation for the design under test
    lzss_hw_top #(.CPB(CPB), .POR_BITS(4), .IDLE_BITS(18)) dut (.clk(clk), .btn1(btn1), .led1(led1), .led2(led2), .uart_tx(tx_line), .uart_rx(rx_line));

    // Clock generator
    always #(TCLK/2) clk = ~clk;

    // Input data
    reg [7:0] data [0:65535];
    // Number of input bytes
    integer n;
    // File names
    reg [1023:0] in_name, out_name;
    // Output file handle
    integer fo;
    // Loop and bookkeeping variables
    integer pos, blk, c, k, total_out, b;
    // Byte received from the design
    reg [7:0] rxb;
    // Requested clocks per bit for the fast run (0 = stay at the default rate) and the idle-timeout test flag
    integer div, idle_test;
    // Pipelined mode: a separate sender keeps one block ahead of the replies (like the RP2350 does), the number of blocks answered so far, and the sender's own loop variables
    integer pipe, answered, sp, sk, sb, sidx;
    // Stream mode: the core cuts the blocks itself (0x7D / 0x7C commands); chunk size and counters of the stream sender
    integer stream, dstream, sblocks, schunk, gbytes, gsent, ddone;
    // End block index of every group sent in decode stream mode
    integer gend [0:1023];
    // This function returns how many groups of the decode stream have been fully answered.
    function integer gdone_groups();
        integer g;
        begin
            gdone_groups = 0;
            for (g = 0; g < gsent; g = g + 1) if (gend[g] <= ddone) gdone_groups = gdone_groups + 1;
        end
    endfunction
    // Compressed bytes collected during the compress pass (blocks back to back)
    reg [7:0] cbuf [0:131071];
    // Compressed length of every block
    integer clen [0:2047];
    // Number of blocks, write index into cbuf, and read index
    integer nblk, cw, cr;
    // Name of the decode output file and its handle
    reg [1023:0] dec_name;
    integer fd, dec_total;

    // This task sends one byte as 8N1 on rx_line.
    task send_byte(input [7:0] v);
        integer i;
        begin
            // Start bit
            rx_line = 0; #(bitclk*TCLK);
            // Eight data bits, least significant first
            for (i = 0; i < 8; i = i + 1) begin rx_line = v[i]; #(bitclk*TCLK); end
            // Stop bit
            rx_line = 1; #(bitclk*TCLK);
        end
    endtask

    // This task receives one byte from tx_line (waits for the start bit, samples in the middle of each bit); it gives up after a timeout.
    task recv_byte(output [7:0] v);
        integer i, guard;
        begin
            guard = 0;
            // Wait for the falling edge of the start bit
            while (tx_line === 1'b1 && guard < 400000) begin #(TCLK); guard = guard + 1; end
            if (guard >= 400000) begin $display("FAIL: timeout waiting for a byte"); $finish; end
            // Middle of the start bit
            #(bitclk*TCLK/2);
            // Middle of each data bit
            for (i = 0; i < 8; i = i + 1) begin #(bitclk*TCLK); v[i] = tx_line; end
            // Middle of the stop bit
            #(bitclk*TCLK);
        end
    endtask

    // This task sends the baud change command (0x7E, new clocks-per-bit), waits for the 0x7E acknowledge at the old rate and then uses the new rate.
    task set_baud(input integer d);
        begin
            send_byte(8'h7E);
            send_byte(d[7:0]);
            recv_byte(rxb);
            if (rxb !== 8'h7E) begin $display("FAIL: baud ack was %h", rxb); $finish; end
            bitclk = d;
        end
    endtask

    // Main sequence: reset handshake, then one request per 64-byte block
    initial begin
        if (!$value$plusargs("in=%s", in_name)) begin $display("FAIL: +in missing"); $finish; end
        if (!$value$plusargs("out=%s", out_name)) begin $display("FAIL: +out missing"); $finish; end
        if (!$value$plusargs("n=%d", n)) begin $display("FAIL: +n missing"); $finish; end
        $readmemh(in_name, data);
        fo = $fopen(out_name, "w");
        // Wait for the power-on delay and the reset synchroniser
        #(TCLK*100);
        div = 0;
        idle_test = 0;
        if ($value$plusargs("div=%d", div)) set_baud(div);
        if ($test$plusargs("idle")) idle_test = 1;
        pipe = $test$plusargs("pipe");
        stream = $test$plusargs("stream");
        dstream = $test$plusargs("dstream");
        sblocks = 0;
        answered = 0;
        // Reset the history and expect a zero back
        send_byte(8'h00);
        recv_byte(rxb);
        if (rxb !== 8'h00) begin $display("FAIL: reset ack was %h", rxb); $finish; end
        total_out = 0;
        pos = 0;
        nblk = 0;
        cw = 0;
        // In pipelined mode the sender runs on its own: block j+1 goes out right behind block j, but never more than one block ahead of the answers
        if (stream) begin
            // Stream mode: chunks of up to 448 bytes (7 blocks) behind a 0x7D command; at most two chunks are ahead of the answers
            fork
                begin
                    sp = 0;
                    while (sp < n) begin
                        schunk = (n - sp > 448) ? 448 : (n - sp);
                        wait ((sblocks - answered) <= 7);
                        send_byte(8'h7D);
                        send_byte(schunk[7:0]);
                        send_byte(schunk[15:8]);
                        for (sk = 0; sk < schunk; sk = sk + 1) send_byte(data[sp + sk]);
                        sblocks = sblocks + (schunk + 63) / 64;
                        sp = sp + schunk;
                    end
                end
            join_none
        end else if (pipe) begin
            fork
                begin
                    sp = 0; sidx = 0;
                    while (sp < n) begin
                        sb = (n - sp > 64) ? 64 : (n - sp);
                        wait (sidx - answered < 2);
                        send_byte(sb[7:0]);
                        for (sk = 0; sk < sb; sk = sk + 1) send_byte(data[sp + sk]);
                        sp = sp + sb;
                        sidx = sidx + 1;
                    end
                end
            join_none
        end
        while (pos < n) begin
            // Block length: 64 bytes, or what is left
            blk = (n - pos > 64) ? 64 : (n - pos);
            if (!pipe && !stream) begin
                send_byte(blk[7:0]);
                for (k = 0; k < blk; k = k + 1) send_byte(data[pos + k]);
            end
            // Reply: compressed length, then that many bytes
            recv_byte(rxb);
            c = rxb;
            $fwrite(fo, "%02x\n", rxb);
            for (k = 0; k < c; k = k + 1) begin recv_byte(rxb); $fwrite(fo, "%02x\n", rxb); cbuf[cw] = rxb; cw = cw + 1; end
            clen[nblk] = c;
            nblk = nblk + 1;
            total_out = total_out + 1 + c;
            answered = answered + 1;
            pos = pos + blk;
        end
        $fclose(fo);
        // Decode pass: reset the history, then send every compressed block as 0x80 | length and read back the raw bytes
        if ($value$plusargs("dec=%s", dec_name)) begin
            fd = $fopen(dec_name, "w");
            send_byte(8'h00);
            recv_byte(rxb);
            if (rxb !== 8'h00) begin $display("FAIL: reset ack (decode) was %h", rxb); $finish; end
            cr = 0;
            dec_total = 0;
            // In decode stream mode a separate sender sends groups of whole blocks (up to 448 compressed bytes) behind one 0x7C command, at most two groups ahead of the answers
            ddone = 0;
            gsent = 0;
            if (dstream) begin
                fork
                    begin : dsender
                        integer sb2, sp2, gq, cr2, nb2, kk;
                        sb2 = 0; cr2 = 0;
                        while (sb2 < nblk) begin
                            gbytes = 0; nb2 = 0;
                            while (sb2 + nb2 < nblk && gbytes + 1 + clen[sb2 + nb2] <= 448) begin gbytes = gbytes + 1 + clen[sb2 + nb2]; nb2 = nb2 + 1; end
                            // Wait until the group before the previous one has been fully answered
                            while (gsent - gdone_groups() >= 2) #(TCLK*10);
                            send_byte(8'h7C);
                            send_byte(gbytes[7:0]);
                            send_byte(gbytes[15:8]);
                            for (gq = 0; gq < nb2; gq = gq + 1) begin
                                send_byte(clen[sb2 + gq][7:0]);
                                for (kk = 0; kk < clen[sb2 + gq]; kk = kk + 1) begin send_byte(cbuf[cr2]); cr2 = cr2 + 1; end
                            end
                            gend[gsent] = sb2 + nb2;
                            gsent = gsent + 1;
                            sb2 = sb2 + nb2;
                        end
                    end
                join_none
            end
            for (b = 0; b < nblk; b = b + 1) begin
                if (!dstream) begin
                    send_byte(8'h80 | clen[b][7:0]);
                    for (k = 0; k < clen[b]; k = k + 1) begin send_byte(cbuf[cr]); cr = cr + 1; end
                end
                recv_byte(rxb);
                c = rxb;
                for (k = 0; k < c; k = k + 1) begin recv_byte(rxb); $fwrite(fd, "%02x\n", rxb); end
                dec_total = dec_total + c;
                ddone = ddone + 1;
            end
            $fclose(fd);
            $display("DECODED %0d", dec_total);
        end
        // Return to the default rate with a baud command and check the link still answers there
        if (div != 0) begin
            set_baud(CPB);
            send_byte(8'h00);
            recv_byte(rxb);
            if (rxb !== 8'h00) begin $display("FAIL: no reset ack after returning to the default rate (%h)", rxb); $finish; end
            $display("BAUD back-to-default ok");
        end
        // Idle fallback: switch to the fast rate, stay silent for longer than the timeout, then talk at the default rate
        if (idle_test) begin
            set_baud(8);
            #(TCLK * (1 << 19));
            bitclk = CPB;
            send_byte(8'h00);
            recv_byte(rxb);
            if (rxb !== 8'h00) begin $display("FAIL: link did not fall back to the default rate (%h)", rxb); $finish; end
            $display("IDLE fallback ok");
        end
        $display("DONE in=%0d out=%0d", n, total_out);
        $finish;
    end
endmodule
