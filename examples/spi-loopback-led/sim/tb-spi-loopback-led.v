// tb-spi-loopback-led.v - self-checking testbench: a model of the RP2350 drives real Zen Link frames into the board top, the same sequence as the Shrike example
// (0xAB then 0xFF, each as select / byte / release). The reply to each byte must be the byte before it, and the LED must follow 0xAB / 0xFF.

`timescale 1ns/1ps

module tb_spi_loopback_led;

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
    // Reply byte
    reg [7:0] r;

    // This contains the instantiation for the design under test
    spi_loopback_led_zen4_top dut (.clk(clk), .link_clk_in(m_clk), .link_csn_in(m_csn), .link_d_in(d_bus), .link_d_out(f_out), .link_d_oe(f_oe), .btn1(1'b1), .led1(led1));

    // This block runs the test
    initial begin
        #(20 * 400);
        // Link ID
        rdn(16'h0000, 2); check8(rb[0], 8'h5A, "ID"); check8(rb[1], 8'hA5, "ID_INV");
        // Power-on state: echo register is 0, LED off
        spi_exch(8'hAB, r); check8(r, 8'h00, "first reply");
        if (led1 !== 1'b0) begin errs = errs + 1; $display("FAIL: LED 1 pin not lit after 0xAB"); end
        spi_exch(8'hFF, r); check8(r, 8'hAB, "reply after AB");
        if (led1 !== 1'b1) begin errs = errs + 1; $display("FAIL: LED 1 pin lit after 0xFF"); end
        spi_exch(8'h55, r); check8(r, 8'hFF, "reply after FF");
        if (led1 !== 1'b1) begin errs = errs + 1; $display("FAIL: LED changed on 0x55"); end
        // Several bytes in one select, like a multi-byte SPI frame
        spi_sel(1); spi_xfer(8'hAB, r); check8(r, 8'h55, "frame byte 1"); spi_xfer(8'h12, r); check8(r, 8'hAB, "frame byte 2"); spi_xfer(8'h34, r); check8(r, 8'h12, "frame byte 3"); spi_sel(0);
        if (led1 !== 1'b0) begin errs = errs + 1; $display("FAIL: LED not on after 0xAB inside a frame"); end
        // Select state reads back
        rdn(16'h0101, 1); check8(rb[0], 8'h00, "select released");
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
