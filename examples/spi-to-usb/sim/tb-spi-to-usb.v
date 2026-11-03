// tb-spi-to-usb.v - self-checking testbench: an Arduino-style SPI master model sends bytes on the external pads, the RP2350 model reads the last byte through real Zen Link frames.
// The external master must get the previous byte back on every transfer, and LED 1 must follow bit 0.

`timescale 1ns/1ps

module tb_spi_to_usb;

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
    // External SPI master model (the Arduino): mode 0, 250 kHz
    reg ext_ss_n = 1'b1, ext_sck = 1'b0, ext_mosi = 1'b0;
    wire ext_miso_out, ext_miso_oe;
    wire ext_miso = ext_miso_oe ? ext_miso_out : 1'b0;
    task ext_xfer(input [7:0] b, output [7:0] r);
        integer k;
        begin
            ext_ss_n = 1'b0; #2000;
            for (k = 7; k >= 0; k = k - 1) begin
                ext_mosi = b[k]; #1000; ext_sck = 1'b1; #200; r[k] = ext_miso; #800; ext_sck = 1'b0; #1000;
            end
            #2000; ext_ss_n = 1'b1; #4000;
        end
    endtask

    // LED 1 pin
    wire led1;
    // Replies
    reg [7:0] r, e;

    // This contains the instantiation for the design under test
    spi_to_usb_zen4_top dut (.clk(clk), .link_clk_in(m_clk), .link_csn_in(m_csn), .link_d_in(d_bus), .link_d_out(f_out), .link_d_oe(f_oe), .btn1(1'b1),
        .ext_ss_n(ext_ss_n), .ext_sck(ext_sck), .ext_mosi(ext_mosi), .ext_miso_in(1'b0), .ext_miso_out(ext_miso_out), .ext_miso_oe(ext_miso_oe), .led1(led1));

    // This block runs the test
    initial begin
        #(20 * 400);
        // First transfer: the external master gets the power-on byte 0x00 back
        ext_xfer(8'h5B, e); check8(e, 8'h00, "ext reply 1");
        spi_exch(8'h00, r); check8(r, 8'h5B, "RP2350 reads 0x5B");
        if (led1 !== 1'b0) begin errs = errs + 1; $display("FAIL: LED 1 pin not lit for bit0 = 1"); end
        // Second transfer: the master gets 0x5B back
        ext_xfer(8'h24, e); check8(e, 8'h5B, "ext reply 2 (previous byte)");
        spi_exch(8'h00, r); check8(r, 8'h24, "RP2350 reads 0x24");
        if (led1 !== 1'b1) begin errs = errs + 1; $display("FAIL: LED 1 pin lit for bit0 = 0"); end
        // The RP2350 can read the same byte again, nothing is consumed
        spi_exch(8'h00, r); check8(r, 8'h24, "RP2350 reads 0x24 again");
        // A third byte
        ext_xfer(8'hFF, e); check8(e, 8'h24, "ext reply 3");
        spi_exch(8'h77, r); check8(r, 8'hFF, "RP2350 reads 0xFF");
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
