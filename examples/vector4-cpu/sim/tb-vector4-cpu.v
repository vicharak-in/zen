// tb-vector4-cpu.v - self-checking testbench: real Zen Link frames load a small program (the operand of instruction n is data[n]) and step through it;
// reg and pc are checked after every step. Also tests jump, shift, compare and the reset bit, and the software reset of the design.

`timescale 1ns/1ps

module tb_vector4_cpu;

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
    // Reply byte
    reg [7:0] r;
    // LED 1 pin
    wire led1;

    // One command byte: {data, mode, reset, step}, returns the state reply that came back
    task send_packet(input [3:0] d, input [1:0] instr, input rst, input stp, output [7:0] rep);
        begin spi_exch({d, instr, rst, stp}, rep); end
    endtask

    // Reads {regval, pc} with a command that does nothing
    task read_state(output [3:0] pc, output [3:0] reg_v);
        reg [7:0] rep;
        begin send_packet(4'd0, 2'd0, 1'b0, 1'b0, rep); pc = rep[3:0]; reg_v = rep[7:4]; end
    endtask

    // Writes an opcode into program memory at addr
    task write_prog(input [3:0] addr, input [3:0] op);
        reg [7:0] t;
        begin send_packet(addr, 2'd2, 1'b0, 1'b1, t); send_packet(op, 2'd0, 1'b0, 1'b1, t); end
    endtask

    // Writes a value into data memory at addr
    task write_data(input [3:0] addr, input [3:0] v);
        reg [7:0] t;
        begin send_packet(addr, 2'd2, 1'b0, 1'b1, t); send_packet(v, 2'd1, 1'b0, 1'b1, t); end
    endtask

    // Executes one instruction at the current pc and checks regval and pc afterwards
    task run_step(input [3:0] exp_reg, input [3:0] exp_pc, input [255:0] what);
        reg [7:0] t;
        reg [3:0] pc, rg;
        begin
            send_packet(4'd0, 2'd3, 1'b0, 1'b1, t);
            read_state(pc, rg);
            if (rg !== exp_reg || pc !== exp_pc) begin errs = errs + 1; $display("FAIL: %0s: reg %0d pc %0d, expected reg %0d pc %0d", what, rg, pc, exp_reg, exp_pc); end
        end
    endtask

    // This contains the instantiation for the design under test
    vector4_cpu_zen4_top dut (.clk(clk), .link_clk_in(m_clk), .link_csn_in(m_csn), .link_d_in(d_bus), .link_d_out(f_out), .link_d_oe(f_oe), .btn1(1'b1), .led1(led1));

    // Opcodes
    localparam LOAD = 0, STORE = 1, ADD = 2, MUL = 3, SUB = 4, SHIFTL = 5, SHIFTR = 6, JUMPTOIF = 7, LOGICAND = 8, LOGICOR = 9, EQUALS = 10, NEQ = 11, BITAND = 12, BITOR = 13, LOGICNOT = 14, BITNOT = 15;
    reg [7:0] t;
    reg [3:0] pc, rg;

    // This block runs the test
    initial begin
        #(20 * 400);
        // Program: 0 LOAD d0  1 ADD d1  2 MUL d2  3 SUB d3  4 BITAND d4  5 BITNOT  6 SHIFTL d6  7 SHIFTR d7  8 EQUALS d8
        write_data(0, 3);  write_prog(0, LOAD);
        write_data(1, 2);  write_prog(1, ADD);
        write_data(2, 2);  write_prog(2, MUL);
        write_data(3, 3);  write_prog(3, SUB);
        write_data(4, 2);  write_prog(4, BITAND);
        write_data(5, 0);  write_prog(5, BITNOT);
        write_data(6, 1);  write_prog(6, SHIFTL);
        write_data(7, 2);  write_prog(7, SHIFTR);
        write_data(8, 2);  write_prog(8, EQUALS);
        send_packet(4'd0, 2'd2, 1'b0, 1'b1, t);       // pc = 0
        run_step(4'd3, 4'd1, "LOAD 3");
        run_step(4'd5, 4'd2, "ADD 2");
        run_step(4'd10, 4'd3, "MUL 2");
        run_step(4'd7, 4'd4, "SUB 3");
        run_step(4'd2, 4'd5, "BITAND 2");
        run_step(4'd13, 4'd6, "BITNOT");
        run_step(4'd10, 4'd7, "SHIFTL 1 (13<<1 = 26 -> 10)");
        run_step(4'd2, 4'd8, "SHIFTR 2");
        run_step(4'd1, 4'd9, "EQUALS 2");

        // Jump: instruction 10 is JUMPTOIF with operand 3; data bit 3 of the RUNPROG command decides whether the jump is taken
        write_data(10, 4'd3); write_prog(10, JUMPTOIF);
        send_packet(4'd10, 2'd2, 1'b0, 1'b1, t);       // pc = 10
        send_packet(4'd8, 2'd3, 1'b0, 1'b1, t);         // RUNPROG with data bit 3 set: the jump is taken to data[10] = 3
        read_state(pc, rg);
        if (pc !== 4'd3 || rg !== 4'd1) begin errs = errs + 1; $display("FAIL: jump taken, pc %0d reg %0d, expected pc 3 reg 1", pc, rg); end
        // Jump not taken: data bit 3 of the RUNPROG command clear
        send_packet(4'd10, 2'd2, 1'b0, 1'b1, t);
        send_packet(4'd0, 2'd3, 1'b0, 1'b1, t);         // run at pc=10 with data bit 3 of this command clear
        read_state(pc, rg);
        if (pc !== 4'd11) begin errs = errs + 1; $display("FAIL: jump not taken, pc %0d", pc); end

        // Reset bit: pc and reg return to zero
        send_packet(4'd0, 2'd0, 1'b1, 1'b0, t);
        send_packet(4'd0, 2'd0, 1'b0, 1'b0, t);
        read_state(pc, rg);
        if (pc !== 4'd0 || rg !== 4'd0) begin errs = errs + 1; $display("FAIL: reset bit, pc %0d reg %0d", pc, rg); end
        // Program memory is cleared by the reset too: a LOAD now gives data 0
        send_packet(4'd0, 2'd3, 1'b0, 1'b1, t);
        read_state(pc, rg);
        if (rg !== 4'd0 || pc !== 4'd1) begin errs = errs + 1; $display("FAIL: after reset run, pc %0d reg %0d", pc, rg); end

        // Software reset through Zen Link CTRL0
        write_data(0, 9); write_prog(0, LOAD);
        send_packet(4'd0, 2'd2, 1'b0, 1'b1, t);
        run_step(4'd9, 4'd1, "LOAD 9 before software reset");
        wr1(16'h0010, 8'd1); wr1(16'h0010, 8'd0);
        read_state(pc, rg);
        if (pc !== 4'd0 || rg !== 4'd0) begin errs = errs + 1; $display("FAIL: software reset, pc %0d reg %0d", pc, rg); end

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
