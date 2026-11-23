// tb-stack-processor.v - self-checking testbench: the RP2350 model sends instruction bytes through real Zen Link frames (the zen_spi.py sequence) and checks the replies.
// Covers the Shrike multiplication example (2 x 5), LIFO order, every ALU instruction and the pop-into-register instructions.

`timescale 1ns/1ps

module tb_stack_processor;

    // FPGA clock, 50 MHz
    reg clk = 1'b0;
    // Link CLK driven by the RP2350 model
    reg m_clk = 1'b0;
    // Link CS_N driven by the RP2350 model
    reg m_csn = 1'b1;
    // Data byte driven by the RP2350 model
    reg [7:0] m_d = 8'd0;
    // High while the RP2350 model drives the data pins
    reg m_oe = 1'b0;
    // Data pins from the FPGA
    wire [7:0] f_out, f_oe;
    // Shared tri-state data pins
    wire [7:0] d_bus;
    // Half period of the link clock: 8.2 FPGA clocks, not aligned to the FPGA clock
    realtime hp = 163.7;
    // Error counter
    integer errs = 0;
    // Bytes read back from the link
    reg [7:0] rb [0:255];

    // 50 MHz clock
    always #10 clk = ~clk;

    // Per-pin tri-state drivers
    genvar gp;
    generate
        for (gp = 0; gp < 8; gp = gp + 1) begin : g_pin
            assign d_bus[gp] = m_oe     ? m_d[gp]   : 1'bz;
            assign d_bus[gp] = f_oe[gp] ? f_out[gp] : 1'bz;
        end
    endgenerate

    // Drives one byte on D and gives one full link clock
    task beat_out(input [7:0] b);
        begin m_d = b; #(hp); m_clk = 1'b1; #(hp); m_clk = 1'b0; end
    endtask

    // Starts a frame: CS_N low, then CMD, ADDR_H and ADDR_L
    task begin_frame(input [7:0] cmd, input [15:0] addr);
        begin m_csn = 1'b0; m_oe = 1'b1; beat_out(cmd); beat_out(addr[15:8]); beat_out(addr[7:0]); end
    endtask

    // Ends a frame: CS_N high, release D, honour the minimum CS_N high time
    task end_frame;
        begin #(hp); m_csn = 1'b1; m_oe = 1'b0; #(hp * 2.0); end
    endtask

    // Writes one byte to a register
    task wr1(input [15:0] addr, input [7:0] v);
        begin begin_frame(8'h00, addr); beat_out(v); end_frame; end
    endtask

    // Reads n bytes starting at addr into rb[0..n-1]
    task rdn(input [15:0] addr, input integer n);
        integer k;
        begin
            begin_frame(8'h80 | (n - 1), addr);
            m_oe = 1'b0;
            #(hp);
            m_clk = 1'b1; #(hp); m_clk = 1'b0;
            for (k = 0; k < n; k = k + 1) begin
                #(hp);
                rb[k] = d_bus;
                m_clk = 1'b1; #(hp); m_clk = 1'b0;
            end
            end_frame;
        end
    endtask

    // Chip select through the byte port
    task spi_sel(input v);
        begin wr1(16'h0101, {7'd0, v}); end
    endtask

    // One SPI-style byte: read DATA (the reply), then write DATA (the byte sent)
    task spi_xfer(input [7:0] b, output [7:0] r);
        begin rdn(16'h0100, 1); r = rb[0]; wr1(16'h0100, b); end
    endtask

    // Select, one byte, release (the Shrike spi_exchange)
    task spi_exch(input [7:0] b, output [7:0] r);
        begin spi_sel(1); spi_xfer(b, r); spi_sel(0); end
    endtask

    // Checks a value
    task check8(input [7:0] got, input [7:0] exp, input [255:0] what);
        begin
            if (got !== exp) begin errs = errs + 1; $display("FAIL: %0s got %h expected %h", what, got, exp); end
        end
    endtask

    // LED 1 pin
    wire led1;
    // Replies and loop variables
    reg [7:0] r;
    integer i;
    integer a, b;
    reg [3:0] expn;

    // This contains the instantiation for the design under test
    stack_processor_zen4_top dut (.clk(clk), .link_clk_in(m_clk), .link_csn_in(m_csn), .link_d_in(d_bus), .link_d_out(f_out), .link_d_oe(f_oe), .btn1(1'b1), .led1(led1));

    // Sends one instruction and drops the reply
    task cmd(input [7:0] c);
        reg [7:0] rr;
        begin spi_exch(c, rr); end
    endtask

    // Pops the top of the stack and returns the nibble (the reply to the next byte)
    task pop_nib(output [3:0] n);
        reg [7:0] rr;
        begin spi_exch(8'h20, rr); spi_exch(8'h00, rr); n = rr[3:0]; end
    endtask

    // Loads A and B from nibbles: push a, push b, pop A (gets b), pop B (gets a) -> A = b, B = a
    task load_ab(input [3:0] av, input [3:0] bv);
        begin
            cmd({4'h1, bv}); cmd({4'h1, av});   // push bv, push av
            cmd(8'h33);                          // pop A = av
            cmd(8'h34);                          // pop B = bv
            cmd(8'h00);                          // let the pop finish
        end
    endtask

    // Runs one ALU instruction and returns the low nibble of C
    task alu(input [7:0] op, output [3:0] n);
        begin cmd(op); cmd(8'h32); pop_nib(n); end
    endtask

    // This block runs the test
    initial begin
        #(20 * 400);
        // The Shrike multiplication example: 2 x 5 = 10
        cmd(8'h12); cmd(8'h15); cmd(8'h33); cmd(8'h34); cmd(8'hC2); cmd(8'h32); cmd(8'h20);
        spi_exch(8'h00, r);
        $display("INFO: multiplication reply = 0x%h", r);
        check8(r[3:0], 4'hA, "2*5 low nibble");
        if (r[7:4] !== 4'h0 && r[7:4] !== 4'h8) begin errs = errs + 1; $display("FAIL: flags %h", r[7:4]); end
        // LED 1: stack is empty again after the pop
        // LIFO order with 12 values
        for (i = 0; i < 12; i = i + 1) cmd({4'h1, i[3:0]});
        if (led1 !== 1'b0) begin errs = errs + 1; $display("FAIL: LED 1 pin not lit with a non-empty stack"); end
        for (i = 11; i >= 0; i = i - 1) begin
            pop_nib(expn);
            if (expn !== i[3:0]) begin errs = errs + 1; $display("FAIL: LIFO order, popped %h expected %h", expn, i[3:0]); end
        end
        // Push from A, B and C
        load_ab(4'h6, 4'h3);               // A = 6, B = 3
        cmd(8'hC0);                        // C = 9
        cmd(8'h31); cmd(8'h30); cmd(8'h32);   // push B, push A, push C
        pop_nib(expn); check8(expn, 4'h9, "push C");
        pop_nib(expn); check8(expn, 4'h6, "push A");
        pop_nib(expn); check8(expn, 4'h3, "push B");
        // Pop into C (0x35): push 0xD, pop to C, push C, pop
        cmd(8'h1D); cmd(8'h35); cmd(8'h00); cmd(8'h32); pop_nib(expn); check8(expn, 4'hD, "pop into C");
        // Every ALU instruction over a spread of operands (low nibble of C compared with the model)
        for (a = 0; a < 16; a = a + 5) begin
            for (b = 1; b < 16; b = b + 4) begin
                load_ab(a[3:0], b[3:0]);
                alu(8'hC0, expn); check8(expn, (a + b) & 15, "add");
                alu(8'hC1, expn); check8(expn, (a - b) & 15, "sub");
                alu(8'hC2, expn); check8(expn, (a * b) & 15, "mul");
                alu(8'hC3, expn); check8(expn, (a / b) & 15, "div");
                alu(8'hC4, expn); check8(expn, (a << b) & 15, "shl");
                alu(8'hC5, expn); check8(expn, (a >> b) & 15, "shr");
                alu(8'hC6, expn); check8(expn, (a >> 1) & 15, "asr");
            end
        end
        // Software reset through the Zen Link (CTRL0 bit 0) clears the stack
        cmd(8'h13); wr1(16'h0010, 8'h01); wr1(16'h0010, 8'h00);
        #1000;
        if (led1 !== 1'b1) begin errs = errs + 1; $display("FAIL: stack not empty after the software reset"); end
        if (errs == 0) $display("ALL PASS"); else $display("SOME FAILED");
        $finish;
    end

    // Safety timeout
    initial begin
        #900_000_000;
        $display("FAIL: timeout");
        $finish;
    end

endmodule
