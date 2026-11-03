// tb-i2c-to-spi-bridge.v - self-checking testbench for the I2C -> SPI bridge with MOSI wired to MISO: a byte written over I2C goes out on SPI and the byte it received comes back on the next I2C read.
// Also checks the "not ready" value 0xFF before the first transfer and that SPI chip select pulses once per byte.

`timescale 1ns/1ps

module tb_i2c_to_spi_bridge;

    // 50 MHz clock
    reg clk = 1'b0;
    always #10 clk = ~clk;
    // I2C open-drain bus: the testbench master drives with *_drive, the bridge pulls SDA low through sda_oe
    reg master_scl_drive = 1'b1;
    reg master_sda_drive = 1'b1;
    wire sda_out, sda_oe, led1;
    wire scl = master_scl_drive;
    wire sda = (sda_oe) ? 1'b0 : master_sda_drive;
    // SPI
    wire spi_sclk, spi_ss, spi_mosi;
    integer errs = 0;

    // This contains the instantiation for the design under test (MOSI looped to MISO)
    i2c_to_spi_bridge_zen4_top dut (.clk(clk), .sda_in(sda), .sda_out(sda_out), .sda_oe(sda_oe), .scl(scl),
        .spi_sclk(spi_sclk), .spi_ss(spi_ss), .spi_mosi(spi_mosi), .spi_miso(spi_mosi), .led1(led1));

    // I2C start condition
    task i2c_start; begin
        master_sda_drive = 1'b1; master_scl_drive = 1'b1; #5000;
        master_sda_drive = 1'b0; #5000;
        master_scl_drive = 1'b0; #5000;
    end endtask

    // I2C stop condition
    task i2c_stop; begin
        master_sda_drive = 1'b0; #5000;
        master_scl_drive = 1'b1; #5000;
        master_sda_drive = 1'b1; #5000;
    end endtask

    // I2C write of one byte, returns the ACK bit (0 = acknowledged)
    task i2c_write_byte; input [7:0] data; output ack; integer i; begin
        for (i = 7; i >= 0; i = i - 1) begin
            master_sda_drive = data[i]; #2500;
            master_scl_drive = 1'b1;    #5000;
            master_scl_drive = 1'b0;    #2500;
        end
        master_sda_drive = 1'b1; #2500;
        master_scl_drive = 1'b1; #2500;
        ack = sda; #2500;
        master_scl_drive = 1'b0; #2500;
    end endtask

    // I2C read of one byte, answered with NACK
    task i2c_read_byte; output [7:0] data; integer i; begin
        master_sda_drive = 1'b1;
        for (i = 7; i >= 0; i = i - 1) begin
            #2500;
            master_scl_drive = 1'b1; #2500;
            data[i] = sda;           #2500;
            master_scl_drive = 1'b0; #2500;
        end
        master_sda_drive = 1'b1; #2500;
        master_scl_drive = 1'b1; #5000;
        master_scl_drive = 1'b0; #2500;
    end endtask

    // Chip select pulse counter
    integer ncs = 0;
    always @(negedge spi_ss) ncs = ncs + 1;

    // Test data
    reg [7:0] vec [0:11];
    integer idx;
    reg [7:0] got;
    reg ack;

    // This block runs the test
    initial begin
        vec[0] = 8'h00; vec[1] = 8'hFF; vec[2] = 8'h55; vec[3] = 8'hAA; vec[4] = 8'h01; vec[5] = 8'h80;
        vec[6] = 8'h32; vec[7] = 8'h7F; vec[8] = 8'hC3; vec[9] = 8'h5A; vec[10] = 8'h10; vec[11] = 8'hE7;
        // The core holds its reset for 65535 clocks
        #2_000_000;
        // Before any transfer a read returns 0xFF
        i2c_start; i2c_write_byte({7'h32, 1'b1}, ack);
        if (ack !== 1'b0) begin errs = errs + 1; $display("FAIL: address 0x32 not acknowledged"); end
        i2c_read_byte(got); i2c_stop;
        if (got !== 8'hFF) begin errs = errs + 1; $display("FAIL: read before any transfer returned 0x%h, expected 0xFF", got); end
        #100_000;
        for (idx = 0; idx < 12; idx = idx + 1) begin
            ncs = 0;
            i2c_start; i2c_write_byte({7'h32, 1'b0}, ack);
            if (ack !== 1'b0) begin errs = errs + 1; $display("FAIL: vector %0d: address not acknowledged", idx); end
            i2c_write_byte(vec[idx], ack);
            i2c_stop;
            #100_000;
            i2c_start; i2c_write_byte({7'h32, 1'b1}, ack);
            i2c_read_byte(got); i2c_stop;
            if (got !== vec[idx]) begin errs = errs + 1; $display("FAIL: vector %0d: wrote 0x%h, read back 0x%h", idx, vec[idx], got); end
            if (ncs != 1) begin errs = errs + 1; $display("FAIL: vector %0d: chip select pulsed %0d times", idx, ncs); end
            #50_000;
        end
        if (errs == 0) $display("ALL PASS"); else $display("SOME FAILED");
        $finish;
    end

    // Safety timeout
    initial begin #200_000_000; $display("FAIL: timeout"); $finish; end

endmodule
