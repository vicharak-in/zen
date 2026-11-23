// tb-usb-to-spi.v - self-checking testbench: the RP2350 model sends bytes through real Zen Link frames, an SPI slave model on the master pins records what it receives
// and answers 0xA7 / 0x3E; every reply must come back one transfer later. The SPI clock period (128 clocks = 2560 ns) is also checked.

`timescale 1ns/1ps

module tb_usb_to_spi;

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

    // SPI master pins and the slave model
    wire m_ss_n, m_sck, m_mosi;
    reg  m_miso = 1'b0;
    // Byte the slave answers with, and what it received
    reg [7:0] s_tx = 8'hA7;
    reg [7:0] s_rx = 8'h00, last_rx = 8'h00;
    integer sb = 0;
    integer xfers = 0;
    // SCK period measurement
    time t_rise = 0, period = 0;
    // LED 1 pin
    wire led1;
    // Reply
    reg [7:0] r;

    // This contains the instantiation for the design under test
    usb_to_spi_zen4_top dut (.clk(clk), .link_clk_in(m_clk), .link_csn_in(m_csn), .link_d_in(d_bus), .link_d_out(f_out), .link_d_oe(f_oe), .btn1(1'b1),
        .m_ss_n(m_ss_n), .m_sck(m_sck), .m_mosi(m_mosi), .m_miso(m_miso), .led1(led1));

    // Slave model, mode 0: first bit ready when the select falls, next bits on each falling clock, MOSI sampled on rising clocks
    reg sel_seen = 1'b0;
    always @(negedge m_ss_n) begin sb = 0; m_miso = s_tx[7]; sel_seen = 1'b1; end
    always @(posedge m_sck) if (!m_ss_n) begin
        s_rx = {s_rx[6:0], m_mosi};
        if (t_rise != 0) period = $time - t_rise;
        t_rise = $time;
    end
    always @(negedge m_sck) if (!m_ss_n) begin sb = sb + 1; if (sb < 8) m_miso = s_tx[7 - sb]; end
    always @(posedge m_ss_n) if (sel_seen) begin last_rx = s_rx; xfers = xfers + 1; t_rise = 0; sel_seen = 1'b0; end

    // This block runs the test
    initial begin
        #(20 * 400);
        // First byte: the slave must see 0x3C; the RP2350 gets the power-on reply 0x00
        spi_exch(8'h3C, r); check8(r, 8'h00, "reply 1");
        #60_000;
        check8(last_rx, 8'h3C, "slave saw 0x3C");
        if (period != 2560) begin errs = errs + 1; $display("FAIL: SCK period %0d ns, expected 2560 ns", period); end
        if (led1 !== 1'b1) begin errs = errs + 1; $display("FAIL: LED 1 pin lit for bit0 = 0"); end
        // Second byte: the reply of the first transfer (0xA7) comes back now
        s_tx = 8'h3E;
        spi_exch(8'h81, r); check8(r, 8'hA7, "reply 2");
        #60_000;
        check8(last_rx, 8'h81, "slave saw 0x81");
        if (led1 !== 1'b0) begin errs = errs + 1; $display("FAIL: LED 1 pin not lit for bit0 = 1"); end
        // Third byte: the reply to the second transfer (0x3E)
        spi_exch(8'h00, r); check8(r, 8'h3E, "reply 3");
        #60_000;
        if (xfers != 3) begin errs = errs + 1; $display("FAIL: %0d SPI transfers, expected 3", xfers); end
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
