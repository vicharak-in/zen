`timescale 1ns/1ps
// Self-checking system testbench: drives real Zen Link frames into flight_fpga_top and compares the
// FPGA's roll, pitch and rotated vertices with the Python model (vec.hex).
module tb_flight;
    localparam NT = 20, NW = 65, NV = 19;
    reg clk = 0, lclk = 0, lcsn = 1;
    reg [7:0] ld = 0; reg drive = 1;
    wire [7:0] dout, doe;
    wire [7:0] lin = drive ? ld : 8'hZZ;
    flight_fpga_top dut (.clk(clk), .link_clk_in(lclk), .link_csn_in(lcsn), .link_d_in(ld), .link_d_out(dout), .link_d_oe(doe),
                    .btn1(1'b1), .btn2(1'b0), .led1(), .led2());
    always #20 clk = ~clk;                 // 25 MHz
    localparam HP = 160;                   // link half period (ns)

    reg [15:0] vec [0:NT*NW-1];
    reg [7:0] rb [0:127];
    integer errors = 0, t, i, n;

    task byte_out(input [7:0] b); begin ld = b; #HP lclk = 1; #HP lclk = 0; end endtask
    task wr_frame(input [15:0] addr, input [7:0] b0, input [7:0] b1); begin
        lcsn = 0; #HP; byte_out(8'h01); byte_out(addr[15:8]); byte_out(addr[7:0]); byte_out(b0); byte_out(b1);
        #HP lcsn = 1; #(HP*2);
    end endtask
    task wr1(input [15:0] addr, input [7:0] b0); begin
        lcsn = 0; #HP; byte_out(8'h00); byte_out(addr[15:8]); byte_out(addr[7:0]); byte_out(b0);
        #HP lcsn = 1; #(HP*2);
    end endtask
    task rd_frame(input [15:0] addr, input integer len); begin
        lcsn = 0; #HP; byte_out(8'h80 | (len - 1)); byte_out(addr[15:8]); byte_out(addr[7:0]);
        byte_out(8'h00);                                      // turnaround clock
        for (n = 0; n < len; n = n + 1) begin #HP lclk = 1; rb[n] = dout; #HP lclk = 0; end
        #HP; lcsn = 1; #(HP*2);
    end endtask
    task wr16(input [15:0] addr, input [15:0] v); begin wr_frame(addr, v[7:0], v[15:8]); end endtask

    reg [15:0] w, e;
    initial begin
        $readmemh("vec.hex", vec);
        #1000;
        // ID check through the link
        rd_frame(16'h0000, 2);
        if (rb[0] !== 8'h5A || rb[1] !== 8'hA5) begin $display("FAIL: link ID %h %h", rb[0], rb[1]); errors = errors + 1; end
        rd_frame(16'h0141, 1);
        if (rb[0] !== 8'hF1) begin $display("FAIL: bitstream id %h", rb[0]); errors = errors + 1; end
        rd_frame(16'h0140, 1);
        if (rb[0] !== 8'h02) begin $display("FAIL: buttons %h", rb[0]); errors = errors + 1; end
        for (t = 0; t < NT; t = t + 1) begin
            for (i = 0; i < 6; i = i + 1) wr16(16'h0100 + 2*i, vec[t*NW + i]);
            wr1(16'h010C, 8'h01);                                   // start
            #4000;                                                  // wait (job is ~1.2k clocks = 48 us)
            rd_frame(16'h0020, 1);
            while (rb[0][0]) begin #2000; rd_frame(16'h0020, 1); end
            rd_frame(16'h0110, 4);
            if ({rb[1], rb[0]} !== vec[t*NW+6] || {rb[3], rb[2]} !== vec[t*NW+7]) begin
                $display("FAIL test %0d angles: got %h %h exp %h %h", t, {rb[1], rb[0]}, {rb[3], rb[2]}, vec[t*NW+6], vec[t*NW+7]);
                errors = errors + 1;
            end
            rd_frame(16'h0200, 6*NV);
            for (i = 0; i < 3*NV; i = i + 1) begin
                w = {rb[2*i+1], rb[2*i]}; e = vec[t*NW + 8 + i];
                if (w !== e) begin
                    if (errors < 10) $display("FAIL test %0d word %0d: got %h exp %h", t, i, w, e);
                    errors = errors + 1;
                end
            end
        end
        if (errors == 0) $display("PASS: %0d tests, FPGA bit-exact with the Python model", NT);
        else $display("FAILED: %0d errors", errors);
        $finish;
    end
    initial begin #200000000; $display("TIMEOUT"); $finish; end
endmodule
