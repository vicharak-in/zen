// tb-i2c-led-core.v - self-checking testbench: an I2C master model (100 kHz) writes 0xAA and 0xFF to address 0x32, reads the byte back, and tries a wrong address (must NACK).
// SDA is a wired-AND bus: the master and the slave (through sda_oe) can each pull it low.

`timescale 1ns/1ps

module tb_i2c_led;

    // Quarter of an I2C bit time at 100 kHz
    localparam Q = 2500;
    // Clock
    reg clk = 1'b0;
    // Active-low reset
    reg rst_n = 1'b0;
    // I2C lines
    reg scl = 1'b1;
    reg m_sda = 1'b1;
    tri1 sda;
    wire s_sda_out, s_sda_oe, led;
    // Error counter
    integer errs = 0;
    // Result of byte transfers
    reg ack;
    reg [7:0] rdata;

    // 50 MHz clock
    always #10 clk = ~clk;

    // Open-drain bus: a low from either side wins
    assign sda = m_sda ? 1'bz : 1'b0;
    assign sda = s_sda_oe ? 1'b0 : 1'bz;

    // This contains the instantiation for the design under test
    i2c_led #(.I2C_SLAVE_ADR(7'h32)) dut (.i_clk(clk), .i_rst_n(rst_n), .i_scl(scl), .i_sda(sda), .o_sda(s_sda_out), .o_sda_oe(s_sda_oe), .o_led(led));

    // Start condition: SDA falls while SCL is high
    task i2c_start;
        begin m_sda = 1; scl = 1; #(Q); m_sda = 0; #(Q); scl = 0; #(Q); end
    endtask

    // Stop condition: SDA rises while SCL is high
    task i2c_stop;
        begin m_sda = 0; #(Q); scl = 1; #(Q); m_sda = 1; #(2 * Q); end
    endtask

    // One bit out, one bit in (the master releases SDA to read)
    task i2c_bit(input b_out, output b_in);
        begin m_sda = b_out; #(Q); scl = 1; #(Q); b_in = sda; #(Q); scl = 0; #(Q); end
    endtask

    // Sends a byte and returns whether the slave acknowledged
    task i2c_wbyte(input [7:0] d, output a);
        integer k; reg bi;
        begin
            for (k = 7; k >= 0; k = k - 1) i2c_bit(d[k], bi);
            i2c_bit(1'b1, bi);
            a = ~bi;
        end
    endtask

    // Reads a byte and answers with ACK (nack = 0) or NACK (nack = 1)
    task i2c_rbyte(output [7:0] d, input nack);
        integer k; reg bi;
        begin
            for (k = 7; k >= 0; k = k - 1) begin i2c_bit(1'b1, bi); d[k] = bi; end
            i2c_bit(nack, bi);
        end
    endtask

    // Writes one byte to the slave at address a7
    task write_byte(input [6:0] a7, input [7:0] d, output a_addr, output a_data);
        begin
            i2c_start; i2c_wbyte({a7, 1'b0}, a_addr);
            if (a_addr) i2c_wbyte(d, a_data); else a_data = 1'b0;
            i2c_stop;
        end
    endtask

    // This block runs the test
    initial begin
        reg a1, a2;
        repeat (10) @(posedge clk);
        rst_n = 1'b1;
        repeat (20) @(posedge clk);

        write_byte(7'h32, 8'hAA, a1, a2);
        if (!a1 || !a2) begin errs = errs + 1; $display("FAIL: write 0xAA not acknowledged (%b %b)", a1, a2); end
        repeat (10) @(posedge clk);
        if (led !== 1'b1) begin errs = errs + 1; $display("FAIL: LED not on after 0xAA"); end

        // Read back: the slave returns the last byte written
        i2c_start; i2c_wbyte({7'h32, 1'b1}, a1);
        if (!a1) begin errs = errs + 1; $display("FAIL: read address not acknowledged"); end
        i2c_rbyte(rdata, 1'b1); i2c_stop;
        if (rdata !== 8'hAA) begin errs = errs + 1; $display("FAIL: read back %h, expected AA", rdata); end

        write_byte(7'h32, 8'hFF, a1, a2);
        if (!a1 || !a2) begin errs = errs + 1; $display("FAIL: write 0xFF not acknowledged"); end
        repeat (10) @(posedge clk);
        if (led !== 1'b0) begin errs = errs + 1; $display("FAIL: LED not off after 0xFF"); end

        // Other data leaves the LED alone
        write_byte(7'h32, 8'h12, a1, a2);
        repeat (10) @(posedge clk);
        if (led !== 1'b0) begin errs = errs + 1; $display("FAIL: LED changed on 0x12"); end

        // Wrong address: no ACK, LED unchanged
        write_byte(7'h10, 8'hAA, a1, a2);
        if (a1) begin errs = errs + 1; $display("FAIL: wrong address acknowledged"); end
        repeat (10) @(posedge clk);
        if (led !== 1'b0) begin errs = errs + 1; $display("FAIL: LED changed on wrong address"); end

        if (errs == 0) $display("ALL PASS"); else $display("SOME FAILED");
        $finish;
    end

    // Safety timeout
    initial begin
        #50_000_000;
        $display("FAIL: timeout");
        $finish;
    end

endmodule
