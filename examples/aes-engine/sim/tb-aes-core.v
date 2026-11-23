// tb-aes-core.v - self-checking testbench for aes_core: encrypts and decrypts every vector in vectors/core.mem.
// Run with:  iverilog -g2012 -P tb_aes_core.LANES=1 -P tb_aes_core.MCP=1 ...   (Zen 4 setting is the default)

`timescale 1ns/1ps

module tb_aes_core;

    // S-box lanes of the core under test (1 = Zen 4, 4 = Zen 8)
    parameter LANES = 1;
    // MixColumns columns per clock of the core under test (1 = Zen 4, 4 = Zen 8)
    parameter MCP   = 1;
    // Number of vector cases in vectors/core.mem
    parameter NCASE = 68;

    // Clock
    reg         clk = 1'b0;
    // Reset
    reg         rst = 1'b1;
    // Key interface drive
    reg         kw_clr = 1'b0;
    // Key word strobe
    reg         kw_valid = 1'b0;
    // Key word
    reg  [31:0] kw_data = 32'd0;
    // Key expansion start
    reg         ks_start = 1'b0;
    // Key expansion busy
    wire        ks_busy;
    // Key expansion done
    wire        ks_done;
    // State load strobe
    reg         ld_valid = 1'b0;
    // State load byte
    reg  [7:0]  ld_byte = 8'd0;
    // State unload strobe
    reg         unld_valid = 1'b0;
    // Low state byte
    wire [7:0]  st_byte;
    // Block start
    reg         blk_start = 1'b0;
    // Direction
    reg         blk_dec = 1'b0;
    // Block busy
    wire        blk_busy;
    // Block done
    wire        blk_done;

    // 128 bit vector memory: key, plain, cipher per case
    reg [127:0] vec [0:3*NCASE-1];
    // Error counter
    integer errs = 0;
    // Pass counter
    integer passes = 0;
    // Cycle counters for the report
    integer ks_cycles, enc_cycles, dec_cycles;
    // Loop and scratch variables
    integer i, b, t;
    // Case vectors
    reg [127:0] kk, pp, cc, got;

    // This contains the instantiation for the core under test
    aes_core #(.SB_LANES(LANES), .MC_PAR(MCP)) dut (
        .clk(clk), .rst(rst), .kw_clr(kw_clr), .kw_valid(kw_valid), .kw_data(kw_data), .ks_start(ks_start),
        .ks_busy(ks_busy), .ks_done(ks_done), .ld_valid(ld_valid), .ld_byte(ld_byte), .unld_valid(unld_valid),
        .st_byte(st_byte), .blk_start(blk_start), .blk_dec(blk_dec), .blk_busy(blk_busy), .blk_done(blk_done));

    // This block makes a 25 MHz clock
    always #20 clk = ~clk;

    // This function returns byte n of a vector, byte 0 being the first (most significant) hex pair
    function [7:0] vbyte;
        input [127:0] h; // The vector
        input integer n; // Byte number 0..15
        begin
            vbyte = h[127 - 8*n -: 8]; // Pick the byte
        end
    endfunction

    // This task writes a key, expands it and measures the expansion time
    task do_key;
        input [127:0] k; // The key
        integer w;       // Word counter
        begin
            @(negedge clk); kw_clr = 1'b1;                       // Restart the key word counter
            @(negedge clk); kw_clr = 1'b0;                       // Release it
            for (w = 0; w < 4; w = w + 1) begin
                kw_data  = {vbyte(k, 4*w+3), vbyte(k, 4*w+2), vbyte(k, 4*w+1), vbyte(k, 4*w)}; // Word w, byte 4w in bits 7:0
                kw_valid = 1'b1;                                 // Write it
                @(negedge clk);                                  // One clock per word
            end
            kw_valid = 1'b0;                                     // Stop writing
            ks_start = 1'b1;                                     // Start the expansion
            @(negedge clk); ks_start = 1'b0;                     // One clock pulse
            t = 0;                                               // Count clocks
            while (!ks_done && t < 5000) begin
                @(negedge clk); t = t + 1;                       // Wait for done
            end
            ks_cycles = t;                                       // Remember the time
            if (t >= 5000) begin errs = errs + 1; $display("FAIL: key expansion timeout"); end
            @(negedge clk);                                      // Settle
        end
    endtask

    // This task loads a block, runs it and returns the result block
    task do_block;
        input  [127:0] h_in;  // Input block
        input          dec;   // Direction
        output [127:0] h_out; // Output block
        integer n;            // Byte counter
        begin
            for (n = 0; n < 16; n = n + 1) begin
                ld_byte  = vbyte(h_in, n);                       // First byte goes in first
                ld_valid = 1'b1;                                 // Shift it in
                @(negedge clk);                                  // One byte per clock
            end
            ld_valid  = 1'b0;                                    // Stop loading
            blk_dec   = dec;                                     // Direction
            blk_start = 1'b1;                                    // Start
            @(negedge clk); blk_start = 1'b0;                    // One clock pulse
            t = 1;                                               // Count clocks (the start clock counts)
            while (!blk_done && t < 2000) begin
                @(negedge clk); t = t + 1;                       // Wait for done
            end
            if (dec) dec_cycles = t; else enc_cycles = t;        // Remember the time
            if (t >= 2000) begin errs = errs + 1; $display("FAIL: block timeout"); end
            @(negedge clk);                                      // Settle
            for (n = 0; n < 16; n = n + 1) begin
                h_out[127 - 8*n -: 8] = st_byte;                 // First byte comes out first
                unld_valid = 1'b1;                               // Drop it
                @(negedge clk);                                  // One byte per clock
            end
            unld_valid = 1'b0;                                   // Stop unloading
        end
    endtask

    // This block runs all vectors
    initial begin
        $readmemh("vectors/core.mem", vec);                      // Load the vectors
        repeat (4) @(negedge clk);                               // Hold reset a few clocks
        rst = 1'b0;                                              // Release reset
        repeat (2) @(negedge clk);                               // Settle
        for (i = 0; i < NCASE; i = i + 1) begin
            kk = vec[3*i]; pp = vec[3*i+1]; cc = vec[3*i+2];    // This case
            do_key(kk);                                          // Expand the key
            do_block(pp, 1'b0, got);                             // Encrypt
            if (got !== cc) begin
                errs = errs + 1;                                 // Count the error
                $display("FAIL enc case %0d: key %h pt %h got %h exp %h", i, kk, pp, got, cc);
            end else passes = passes + 1;                        // Count the pass
            do_block(cc, 1'b1, got);                             // Decrypt
            if (got !== pp) begin
                errs = errs + 1;                                 // Count the error
                $display("FAIL dec case %0d: key %h ct %h got %h exp %h", i, kk, cc, got, pp);
            end else passes = passes + 1;                        // Count the pass
        end
        $display("CORE LANES=%0d MC_PAR=%0d: %0d checks passed, %0d errors | key expansion %0d clk, encrypt %0d clk, decrypt %0d clk",
                 LANES, MCP, passes, errs, ks_cycles, enc_cycles, dec_cycles);
        if (errs == 0) $display("ALL PASS"); else $display("SOME FAILED");
        $finish;
    end

    // This block stops a hung simulation
    initial begin
        #200000000;
        $display("TIMEOUT");
        $finish;
    end

endmodule
