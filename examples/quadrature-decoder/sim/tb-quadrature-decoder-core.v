// tb-quadrature-decoder-core.v - self-checking testbench with short timing (CLK_FREQ 100 kHz, UPDATE_MS 10 = 1000-clock window, CPR 16, 8 clocks per UART bit): drives 20 forward
// steps then 5 reverse steps into the decoder and checks the 8-byte packets (position, speed, angle, direction) that come out of the UART.

`timescale 1ns/1ps

module tb_quadrature_decoder;

    // Clock
    reg clk = 1'b0;
    // Reset
    reg rst = 1'b1;
    // Encoder channels
    reg enc_a = 1'b0, enc_b = 1'b0;
    // Outputs
    wire uart_tx, direction;
    // Error counter
    integer errs = 0;
    // Received bytes
    reg [7:0] rb [0:1023];
    integer nb = 0;
    // Parsed packet
    reg signed [15:0] p_pos, p_spd;
    reg [15:0] p_ang;
    reg p_dir;
    // Gray-code position of the encoder model
    integer ph = 0;
    // Loop variables
    integer i, k, found;

    // 50 MHz clock
    always #10 clk = ~clk;

    // This contains the instantiation for the design under test
    quadrature_decoder_uart #(.WIDTH(16), .CLK_FREQ(100_000), .UPDATE_MS(10), .CPR(16), .CLKS_PER_BIT(8)) dut (
        .clk(clk), .rst(rst), .enc_a(enc_a), .enc_b(enc_b), .uart_tx(uart_tx), .direction(direction));

    // This block is a UART receiver: it logs every byte (8 clocks of 20 ns per bit)
    always @(negedge uart_tx) begin : rx
        integer j;
        reg [7:0] b;
        #(8 * 20 / 2);
        for (j = 0; j < 8; j = j + 1) begin #(8 * 20); b[j] = uart_tx; end
        #(8 * 20);
        rb[nb] = b; nb = nb + 1;
    end

    // One encoder step: forward goes 00 -> 01 -> 11 -> 10 (A,B), reverse the other way, each state held for 8 clocks
    task step(input fwd);
        begin
            ph = (ph + (fwd ? 1 : 3)) % 4;
            case (ph)
                0: begin enc_a = 0; enc_b = 0; end
                1: begin enc_a = 0; enc_b = 1; end
                2: begin enc_a = 1; enc_b = 1; end
                3: begin enc_a = 1; enc_b = 0; end
            endcase
            repeat (8) @(posedge clk);
        end
    endtask

    // Finds the last complete packet in the byte log and parses it
    task last_packet;
        begin
            found = -1;
            for (i = 0; i + 7 < nb; i = i + 1) if (rb[i] == 8'hAA) found = i;
            if (found < 0) begin errs = errs + 1; $display("FAIL: no packet received"); end
            else begin
                p_pos = {rb[found+1], rb[found+2]};
                p_spd = {rb[found+3], rb[found+4]};
                p_ang = {rb[found+5], rb[found+6]};
                p_dir = rb[found+7][0];
            end
        end
    endtask

    // This block runs the test
    initial begin
        repeat (10) @(posedge clk);
        rst = 1'b0;
        // Start the steps right after a measurement tick so they all land in one window
        @(posedge dut.QUAD_DEC_INST.data_valid);
        repeat (2) @(posedge clk);
        for (k = 0; k < 20; k = k + 1) step(1'b1);
        // Next window's packet
        @(posedge dut.QUAD_DEC_INST.data_valid);
        repeat (900) @(posedge clk);
        last_packet;
        if (p_pos !== 16'sd20)    begin errs = errs + 1; $display("FAIL: position %0d, expected 20", p_pos); end
        if (p_spd !== 16'sd2000)  begin errs = errs + 1; $display("FAIL: speed %0d, expected 2000 (20 steps x 100)", p_spd); end
        if (p_ang !== 16'd4)      begin errs = errs + 1; $display("FAIL: angle %0d, expected 4 (20 mod 16)", p_ang); end
        if (p_dir !== 1'b1)       begin errs = errs + 1; $display("FAIL: direction %b, expected forward", p_dir); end

        // Reverse five steps in the next window
        @(posedge dut.QUAD_DEC_INST.data_valid);
        repeat (2) @(posedge clk);
        for (k = 0; k < 5; k = k + 1) step(1'b0);
        @(posedge dut.QUAD_DEC_INST.data_valid);
        repeat (900) @(posedge clk);
        last_packet;
        if (p_pos !== 16'sd15)    begin errs = errs + 1; $display("FAIL: position %0d, expected 15", p_pos); end
        if (p_spd !== -16'sd500)  begin errs = errs + 1; $display("FAIL: speed %0d, expected -500", p_spd); end
        if (p_ang !== 16'd15)     begin errs = errs + 1; $display("FAIL: angle %0d, expected 15 (wrapped below zero)", p_ang); end
        if (p_dir !== 1'b0)       begin errs = errs + 1; $display("FAIL: direction %b, expected reverse", p_dir); end

        if (errs == 0) $display("ALL PASS"); else $display("SOME FAILED");
        $finish;
    end

    // Safety timeout
    initial begin
        #5_000_000;
        $display("FAIL: timeout, %0d bytes received", nb);
        $finish;
    end

endmodule
