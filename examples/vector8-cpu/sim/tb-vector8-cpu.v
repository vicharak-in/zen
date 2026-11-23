// tb-vector8-cpu.v - self-checking testbench: real Zen Link frames send two-byte instructions (opcode, data) inside one chip select and read the accumulator back
// with a NOP, the same flow as the Shrike diagnostics. Covers arithmetic wrap, logic, shifts and rotates, INC / DEC and the zero flag with JMP / JZ / JNZ.

`timescale 1ns/1ps

module tb_vector8_cpu;

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
    // Opcodes
    localparam NOP = 0, LDA = 1, ADD = 2, SUB = 3, AND_ = 4, OR_ = 5, XOR_ = 6, LSL = 7, LSR = 8, ROL = 9, ROR = 10, INC = 11, DEC = 12, JMP = 13, JZ = 14, JNZ = 15;
    // Accumulator read back
    reg [7:0] acc;

    // This contains the instantiation for the design under test
    vector8_cpu_zen4_top dut (.clk(clk), .link_clk_in(m_clk), .link_csn_in(m_csn), .link_d_in(d_bus), .link_d_out(f_out), .link_d_oe(f_oe), .btn1(1'b1), .led1(led1));

    // Sends one instruction and reads the accumulator (the Shrike send_instr)
    task instr(input [4:0] op, input [7:0] d);
        reg [7:0] t, r1;
        begin
            spi_sel(1); spi_xfer({3'd0, op}, t); spi_xfer(d, t); spi_sel(0);
            spi_sel(1); spi_xfer(8'h00, t); spi_xfer(8'h00, r1); spi_sel(0);
            acc = r1;
        end
    endtask

    // Checks the accumulator after an instruction
    task expect_acc(input [4:0] op, input [7:0] d, input [7:0] e, input [255:0] what);
        begin instr(op, d); if (acc !== e) begin errs = errs + 1; $display("FAIL: %0s: acc %0d expected %0d", what, acc, e); end end
    endtask

    // This block runs the test
    initial begin
        #(20 * 400);
        expect_acc(LDA, 255, 255, "LDA 255");
        expect_acc(INC, 0, 0, "INC wraps to 0");
        expect_acc(ADD, 128, 128, "ADD 128");
        expect_acc(SUB, 1, 127, "SUB 1");
        expect_acc(AND_, 8'h0F, 8'h0F, "AND 0F");
        expect_acc(OR_, 8'hA0, 8'hAF, "OR A0");
        expect_acc(XOR_, 8'hFF, 8'h50, "XOR FF");
        expect_acc(LSL, 0, 8'hA0, "LSL");
        expect_acc(LSR, 0, 8'h50, "LSR");
        expect_acc(ROL, 0, 8'hA0, "ROL");
        expect_acc(ROR, 0, 8'h50, "ROR");
        expect_acc(DEC, 0, 8'h4F, "DEC");
        // Zero flag and jumps: SUB to zero, JZ taken (acc untouched, pc changes), JNZ not taken
        expect_acc(LDA, 5, 5, "LDA 5");
        expect_acc(SUB, 5, 0, "SUB to zero");
        expect_acc(JZ, 8'h20, 0, "JZ keeps acc");
        expect_acc(JNZ, 8'h30, 0, "JNZ keeps acc");
        expect_acc(JMP, 8'h10, 0, "JMP keeps acc");
        // A pair cut short by releasing the select starts over: the next first byte is an opcode again
        begin : cut reg [7:0] t; spi_sel(1); spi_xfer({3'd0, LDA}, t); spi_sel(0); end
        expect_acc(LDA, 77, 77, "LDA after a cut pair");
        // Software reset clears the accumulator
        wr1(16'h0010, 8'd1); wr1(16'h0010, 8'd0);
        instr(NOP, 0); if (acc !== 8'd0) begin errs = errs + 1; $display("FAIL: acc %0d after software reset", acc); end
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
