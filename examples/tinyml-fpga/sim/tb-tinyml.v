// tb-tinyml.v - self-checking testbench for tml_zink (the TinyML engine behind the Zink user bus).
// It talks to the user bus exactly like the Zink slave does (address stable for several clocks, then a one-clock strobe), loads the files
// written by firmware/pc-tools/gen_vectors.py (cfg, tbl, bias, w, in, exp .hex in the working directory), runs the network and checks:
//   1. memory read-back of the layer table and the input vector
//   2. the output vector against the golden model, and the cycle count against the formula
//   3. a write into the weight window while running is dropped and flagged, and the result is still correct
//   4. a clean re-run clears the error flag and gives the same result
//   5. a layer count of 0 is rejected (error flag, no done)

`timescale 1ns/1ps

module tb_tinyml;

    // 50 MHz clock like the board
    reg clk = 1'b0;
    // Clock generator
    always #10 clk = ~clk;

    // DUT inputs
    reg         rst       = 1'b1;
    reg  [15:0] usr_addr  = 16'd0;
    reg         usr_wr    = 1'b0;
    reg  [7:0]  usr_wdata = 8'd0;
    reg         usr_rd    = 1'b0;
    // DUT outputs
    wire [7:0]  usr_rdata;
    wire [7:0]  status;

    // Test vectors from the Python golden model
    reg [7:0] cfg [0:15];
    reg [7:0] tbl [0:63];
    reg [7:0] bias [0:1023];
    reg [7:0] wts [0:8191];
    reg [7:0] inp [0:255];
    reg [7:0] exp [0:255];

    // Values taken from cfg
    integer nlayers, in_len, out_len, wlen, blen, tlen, exp_cycles;
    // Error counter
    integer errors = 0;
    // Loop and scratch variables
    integer k, polls;
    reg [7:0] d;
    reg [31:0] cyc;

    // This contains the instantiation for the DUT
    tml_zink dut (
        .clk(clk), .rst(rst),
        .usr_addr(usr_addr), .usr_wr(usr_wr), .usr_wdata(usr_wdata), .usr_rd(usr_rd), .usr_rdata(usr_rdata),
        .status_o(status)
    );

    // Write one byte on the user bus: address settles for 3 clocks, then a one-clock write strobe
    task bus_wr(input [15:0] a, input [7:0] v);
        begin
            @(negedge clk); usr_addr = a; usr_wdata = v; usr_wr = 1'b0;   // Present address and data
            repeat (3) @(negedge clk);                                    // Let it settle
            usr_wr = 1'b1;                                                // One-clock strobe
            @(negedge clk); usr_wr = 1'b0;                                // End of strobe
        end
    endtask

    // Read one byte from the user bus: address settles for 3 clocks, the data is sampled in the clock of the read strobe
    task bus_rd(input [15:0] a, output [7:0] v);
        begin
            @(negedge clk); usr_addr = a;                                 // Present the address
            repeat (3) @(negedge clk);                                    // Let the registered RAM output follow
            usr_rd = 1'b1; v = usr_rdata;                                 // Strobe and sample
            @(negedge clk); usr_rd = 1'b0;                                // End of strobe
        end
    endtask

    // Start a run and wait until done or error is reported; leaves the final status in d
    task run_and_wait;
        begin
            bus_wr(16'h0100, 8'd1);                                       // CMD = RUN
            polls = 0;
            d = 8'd0;
            while (!(d[1] || d[2]) && polls < 20000) begin                // Poll STATUS until done or error
                bus_rd(16'h0101, d);
                polls = polls + 1;
            end
            if (polls >= 20000) begin errors = errors + 1; $display("FAIL: timeout"); end
        end
    endtask

    // Compare the output window with the golden vector and the cycle counter with the formula
    task check_result(input [255:0] tag);
        begin
            for (k = 0; k < out_len; k = k + 1) begin
                bus_rd(16'h0700 + k, d);                                  // Read output byte k
                if (d !== exp[k]) begin errors = errors + 1; $display("FAIL %0s: out[%0d] = %02x, expected %02x", tag, k, d, exp[k]); end
            end
            cyc = 32'd0;
            for (k = 0; k < 4; k = k + 1) begin
                bus_rd(16'h0104 + k, d);                                  // Read CYCLES byte k
                cyc = cyc | (d << (8 * k));
            end
            if (cyc !== exp_cycles) begin errors = errors + 1; $display("FAIL %0s: cycles = %0d, expected %0d", tag, cyc, exp_cycles); end
        end
    endtask

    // Main test sequence
    initial begin
        $readmemh("cfg.hex", cfg);                                        // Load the vector files
        $readmemh("tbl.hex", tbl);
        $readmemh("bias.hex", bias);
        $readmemh("w.hex", wts);
        $readmemh("in.hex", inp);
        $readmemh("exp.hex", exp);
        nlayers    = cfg[0];                                              // Unpack the config bytes
        in_len     = cfg[1];
        out_len    = cfg[2];
        wlen       = cfg[3] + 256 * cfg[4];
        blen       = cfg[5] + 256 * cfg[6];
        tlen       = cfg[7];
        exp_cycles = cfg[8] + 256 * cfg[9] + 65536 * cfg[10] + 16777216 * cfg[11];

        repeat (5) @(negedge clk);                                        // Reset
        rst = 1'b0;
        repeat (5) @(negedge clk);

        for (k = 0; k < tlen; k = k + 1) bus_wr(16'h0200 + k, tbl[k]);    // Layer table
        for (k = 0; k < blen; k = k + 1) bus_wr(16'h4000 + k, bias[k]);   // Biases
        for (k = 0; k < wlen; k = k + 1) bus_wr(16'h2000 + k, wts[k]);    // Weights
        for (k = 0; k < in_len; k = k + 1) bus_wr(16'h0600 + k, inp[k]);  // Input vector
        bus_wr(16'h0102, nlayers);                                        // NLAYERS

        for (k = 0; k < tlen; k = k + 1) begin                            // 1. read-back of the table
            bus_rd(16'h0200 + k, d);
            if (d !== tbl[k]) begin errors = errors + 1; $display("FAIL: table[%0d] = %02x, expected %02x", k, d, tbl[k]); end
        end
        for (k = 0; k < in_len; k = k + 1) begin                          // 1. read-back of the input
            bus_rd(16'h0600 + k, d);
            if (d !== inp[k]) begin errors = errors + 1; $display("FAIL: input[%0d] = %02x, expected %02x", k, d, inp[k]); end
        end
        for (k = 0; k < wlen && k < 32; k = k + 1) begin                  // 1. read-back of the first weights
            bus_rd(16'h2000 + k, d);
            if (d !== wts[k]) begin errors = errors + 1; $display("FAIL: weight[%0d] = %02x, expected %02x", k, d, wts[k]); end
        end

        run_and_wait;                                                     // 2. first run
        if (d[2:0] !== 3'b010) begin errors = errors + 1; $display("FAIL: status after run = %02x, expected done only", d); end
        check_result("run1");

        bus_wr(16'h0100, 8'd1);                                           // 3. second run, with a write into the weight window while busy
        repeat (10) @(negedge clk);
        bus_wr(16'h2000, 8'h55);                                          // Must be dropped and flagged
        polls = 0;
        d = 8'd0;
        while (!d[1] && polls < 20000) begin bus_rd(16'h0101, d); polls = polls + 1; end
        if (d[2] !== 1'b1) begin errors = errors + 1; $display("FAIL: write while busy did not set the error flag"); end
        check_result("run2");

        run_and_wait;                                                     // 4. clean re-run clears the error
        if (d[2:0] !== 3'b010) begin errors = errors + 1; $display("FAIL: status after clean re-run = %02x", d); end
        check_result("run3");

        bus_wr(16'h0102, 8'd0);                                           // 5. zero layers must be rejected
        run_and_wait;
        if (d[2:1] !== 2'b10) begin errors = errors + 1; $display("FAIL: nlayers=0 status = %02x, expected error without done", d); end

        if (errors == 0) $display("PASS: %0d layers, %0d cycles", nlayers, exp_cycles);
        else $display("FAIL: %0d errors", errors);
        $finish;
    end

endmodule
