// tb-aes-top.v - self-checking testbench for aes_top: plays the PC on the UART pins and checks every reply byte.
// Covers: version, unknown command, key load, ECB encrypt and decrypt (6 blocks), CTR (partial blocks, counter continues),
// re-keying, baud switch, error replies, idle timeout (baud returns to default, half-sent command is dropped).

`timescale 1ns/1ps

module tb_aes_top;

    // S-box lanes of the design under test
    parameter LANES = 1;
    // MixColumns columns per clock of the design under test
    parameter MCP   = 1;
    // Default clocks per bit (small so the simulation is fast)
    parameter CPB0  = 16;
    // Idle timeout in clocks (small so the simulation is fast)
    parameter IDLE  = 400000;

    // Clock
    reg  clk = 1'b0;
    // Reset
    reg  rst = 1'b1;
    // Line from the testbench to the design (idle high)
    reg  rx_line = 1'b1;
    // Line from the design to the testbench
    wire tx_line;
    // LEDs
    wire busy_led, err_led;

    // Clocks per bit the testbench currently uses on both lines
    integer cpb = CPB0;
    // Error counter
    integer errs = 0;
    // Check counter
    integer checks = 0;

    // Vector memories (one byte per entry)
    reg [7:0] key1 [0:15];
    // ECB plain text, 6 blocks
    reg [7:0] ecb_pt [0:95];
    // ECB cipher text, 6 blocks
    reg [7:0] ecb_ct [0:95];
    // CTR initial counter
    reg [7:0] iv [0:15];
    // CTR first plain text, 40 bytes
    reg [7:0] ctr_pt [0:39];
    // CTR first cipher text
    reg [7:0] ctr_ct [0:39];
    // CTR second plain text, 32 bytes
    reg [7:0] ctr_pt2 [0:31];
    // CTR second cipher text
    reg [7:0] ctr_ct2 [0:31];
    // Second key
    reg [7:0] key2 [0:15];
    // One block under the second key
    reg [7:0] pt2 [0:15];
    // Its cipher text
    reg [7:0] ct2 [0:15];

    // Bytes received from the design
    reg [7:0] rxq [0:8191];
    // Number of bytes received so far
    integer rxn = 0;
    // Expected bytes for the next check
    reg [7:0] exp_b [0:255];
    // Scratch loop variables
    integer i, j, w, base;

    // This contains the instantiation for the design under test
    aes_top #(.SB_LANES(LANES), .MC_PAR(MCP), .CPB_DEFAULT(CPB0), .IDLE_CLKS(IDLE)) dut (
        .clk(clk), .rst(rst), .uart_rx(rx_line), .uart_tx(tx_line), .busy_led(busy_led), .err_led(err_led));

    // This block makes a 25 MHz clock
    always #20 clk = ~clk;

    // This task sends one byte on the line to the design
    task send_byte;
        input [7:0] b; // Byte to send
        integer k;     // Bit counter
        begin
            rx_line = 1'b0;                                   // Start bit
            repeat (cpb) @(posedge clk);                      // One bit time
            for (k = 0; k < 8; k = k + 1) begin
                rx_line = b[k];                               // Data bit, LSB first
                repeat (cpb) @(posedge clk);                  // One bit time
            end
            rx_line = 1'b1;                                   // Stop bit
            repeat (cpb) @(posedge clk);                      // One bit time
        end
    endtask

    // This block decodes the line from the design into rxq
    always begin
        @(negedge tx_line);                                   // Start bit begins
        repeat (cpb / 2) @(posedge clk);                      // Go to the middle of the start bit
        for (j = 0; j < 8; j = j + 1) begin
            repeat (cpb) @(posedge clk);                      // Go to the middle of the next bit
            rxq[rxn][j] = tx_line;                            // Sample the data bit
        end
        repeat (cpb) @(posedge clk);                          // Middle of the stop bit
        if (tx_line !== 1'b1) begin errs = errs + 1; $display("FAIL: bad stop bit"); end
        rxn = rxn + 1;                                        // One more byte received
    end

    // This task waits for n more reply bytes and compares them with exp_b
    task check_reply;
        input integer n;   // Number of bytes expected
        input integer tag; // Number printed on failure
        integer t, k;      // Timeout counter and byte counter
        begin
            t = 0;                                            // Count waiting clocks
            while (rxn < base + n && t < 4000000) begin
                @(posedge clk); t = t + 1;                    // Wait for the bytes
            end
            if (rxn < base + n) begin
                errs = errs + 1;                              // Not enough bytes came
                $display("FAIL test %0d: only %0d of %0d reply bytes", tag, rxn - base, n);
            end else begin
                for (k = 0; k < n; k = k + 1) begin
                    checks = checks + 1;                      // One more check
                    if (rxq[base + k] !== exp_b[k]) begin
                        errs = errs + 1;                      // Wrong byte
                        $display("FAIL test %0d: byte %0d got %h expected %h", tag, k, rxq[base + k], exp_b[k]);
                    end
                end
            end
            repeat (4 * cpb) @(posedge clk);                  // Let the line settle
            base = rxn;                                       // Next check starts here
        end
    endtask

    // This task checks that no byte arrives within a while
    task check_silence;
        input integer tag; // Number printed on failure
        begin
            repeat (3000) @(posedge clk);                     // Wait a while
            if (rxn != base) begin
                errs = errs + 1;                              // Something came
                $display("FAIL test %0d: unexpected reply byte %h", tag, rxq[base]);
                base = rxn;                                   // Resynchronise
            end
        end
    endtask

    // This block runs the tests
    initial begin
        $readmemh("vectors/key1.mem", key1);                  // Load all vectors
        $readmemh("vectors/ecb-pt.mem", ecb_pt);
        $readmemh("vectors/ecb-ct.mem", ecb_ct);
        $readmemh("vectors/iv.mem", iv);
        $readmemh("vectors/ctr-pt.mem", ctr_pt);
        $readmemh("vectors/ctr-ct.mem", ctr_ct);
        $readmemh("vectors/ctr-pt2.mem", ctr_pt2);
        $readmemh("vectors/ctr-ct2.mem", ctr_ct2);
        $readmemh("vectors/key2.mem", key2);
        $readmemh("vectors/pt2.mem", pt2);
        $readmemh("vectors/ct2.mem", ct2);
        base = 0;                                             // First reply byte index
        repeat (10) @(posedge clk);                           // Hold reset
        rst = 1'b0;                                           // Release reset
        repeat (10) @(posedge clk);                           // Settle

        // ---- test 1: version
        send_byte("V");                                       // Ask for the version
        exp_b[0] = "A"; exp_b[1] = "E"; exp_b[2] = "S"; exp_b[3] = MCP * 16 + LANES; // Expected reply
        check_reply(4, 1);

        // ---- test 2: unknown command
        send_byte("Z");                                       // Not a command
        exp_b[0] = "X";                                       // Expected reply
        check_reply(1, 2);

        // ---- test 3: key load
        send_byte("K");                                       // Key command
        for (i = 0; i < 16; i = i + 1) send_byte(key1[i]);    // 16 key bytes
        exp_b[0] = "K";                                       // Expected acknowledge
        check_reply(1, 3);

        // ---- test 4: ECB encrypt 6 blocks
        send_byte("E"); send_byte(8'd6);                      // Encrypt six blocks
        for (i = 0; i < 96; i = i + 1) send_byte(ecb_pt[i]);  // Plain text
        for (i = 0; i < 96; i = i + 1) exp_b[i] = ecb_ct[i];  // Expected cipher text
        check_reply(96, 4);

        // ---- test 5: ECB decrypt 6 blocks
        send_byte("D"); send_byte(8'd6);                      // Decrypt six blocks
        for (i = 0; i < 96; i = i + 1) send_byte(ecb_ct[i]);  // Cipher text
        for (i = 0; i < 96; i = i + 1) exp_b[i] = ecb_pt[i];  // Expected plain text
        check_reply(96, 5);

        // ---- test 6: CTR, 40 bytes (two full blocks and a partial one)
        send_byte("I");                                       // Counter command
        for (i = 0; i < 16; i = i + 1) send_byte(iv[i]);      // 16 counter bytes
        exp_b[0] = "I";                                       // Expected acknowledge
        check_reply(1, 6);
        send_byte("C"); send_byte(8'd0); send_byte(8'd40);    // CTR, 40 bytes
        for (i = 0; i < 40; i = i + 1) send_byte(ctr_pt[i]);  // Plain text
        for (i = 0; i < 40; i = i + 1) exp_b[i] = ctr_ct[i];  // Expected cipher text
        check_reply(40, 7);

        // ---- test 7: CTR again, the counter continues after the three started blocks
        send_byte("C"); send_byte(8'd0); send_byte(8'd32);    // CTR, 32 bytes
        for (i = 0; i < 32; i = i + 1) send_byte(ctr_pt2[i]); // Plain text
        for (i = 0; i < 32; i = i + 1) exp_b[i] = ctr_ct2[i]; // Expected cipher text
        check_reply(32, 8);

        // ---- test 8: re-key and one block
        send_byte("K");                                       // Key command
        for (i = 0; i < 16; i = i + 1) send_byte(key2[i]);    // New key
        exp_b[0] = "K";                                       // Expected acknowledge
        check_reply(1, 9);
        send_byte("E"); send_byte(8'd1);                      // One block
        for (i = 0; i < 16; i = i + 1) send_byte(pt2[i]);     // Plain text
        for (i = 0; i < 16; i = i + 1) exp_b[i] = ct2[i];     // Expected cipher text
        check_reply(16, 10);

        // ---- test 9: error replies
        send_byte("E"); send_byte(8'd0);                      // Zero blocks
        exp_b[0] = "X";                                       // Expected error
        check_reply(1, 11);
        send_byte("B"); send_byte(8'd2);                      // Divisor too small
        exp_b[0] = "X";                                       // Expected error
        check_reply(1, 12);

        // ---- test 10: baud switch to half the bit time, then work at the new rate
        send_byte("B"); send_byte(CPB0 / 2);                  // Switch to twice the baud rate
        exp_b[0] = "B";                                       // Acknowledge at the old rate
        check_reply(1, 13);
        cpb = CPB0 / 2;                                       // The testbench follows
        send_byte("V");                                       // Version at the new rate
        exp_b[0] = "A"; exp_b[1] = "E"; exp_b[2] = "S"; exp_b[3] = MCP * 16 + LANES;
        check_reply(4, 14);
        send_byte("E"); send_byte(8'd1);                      // One block at the new rate (key 2 is still loaded)
        for (i = 0; i < 16; i = i + 1) send_byte(pt2[i]);     // Plain text
        for (i = 0; i < 16; i = i + 1) exp_b[i] = ct2[i];     // Expected cipher text
        check_reply(16, 15);

        // ---- test 11: idle timeout returns the baud rate to the default
        repeat (IDLE + 5000) @(posedge clk);                  // Stay silent for longer than the timeout
        cpb = CPB0;                                           // The testbench uses the default rate again
        send_byte("V");                                       // Version at the default rate
        exp_b[0] = "A"; exp_b[1] = "E"; exp_b[2] = "S"; exp_b[3] = MCP * 16 + LANES;
        check_reply(4, 16);

        // ---- test 12: a half-sent command is dropped by the timeout
        send_byte("E"); send_byte(8'd2);                      // Two blocks announced
        for (i = 0; i < 5; i = i + 1) send_byte(8'hAA);       // but only five bytes sent
        repeat (IDLE + 5000) @(posedge clk);                  // Stay silent for longer than the timeout
        check_silence(17);                                    // Nothing must have been sent
        send_byte("E"); send_byte(8'd1);                      // A fresh command must work
        for (i = 0; i < 16; i = i + 1) send_byte(pt2[i]);     // Plain text
        for (i = 0; i < 16; i = i + 1) exp_b[i] = ct2[i];     // Expected cipher text
        check_reply(16, 18);

        // ---- test 13: the FIFO overflow LED is still off
        checks = checks + 1;                                  // One more check
        if (err_led !== 1'b0) begin errs = errs + 1; $display("FAIL: overflow flag set"); end

        $display("TOP LANES=%0d MC_PAR=%0d: %0d byte checks, %0d errors", LANES, MCP, checks, errs);
        if (errs == 0) $display("ALL PASS"); else $display("SOME FAILED");
        $finish;
    end

    // This block stops a hung simulation
    initial begin
        #2000000000;
        $display("TIMEOUT");
        $finish;
    end

endmodule
