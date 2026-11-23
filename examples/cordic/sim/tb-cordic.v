// tb-cordic.v - self-checking testbench: real Zen Link frames send the request bytes of the Shrike example and the next transfer returns the result, which is compared
// with the exact value (cos / sin / tan within the engine's Q1.6 accuracy of about 0.07, the multiply exactly).

`timescale 1ns/1ps

module tb_cordic;

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
    // Error budget: the 7-iteration Q1.6 engine is accurate to about 4 steps (0.066 worst case here), the tangent to about 5
    real tol_cs = 5.0 / 64.0;
    real tol_tan = 7.0 / 64.0;
    // Largest errors seen
    real max_cs = 0.0, max_tan = 0.0;
    // Test angle and results
    real rad, got, exact, diff;
    integer deg, a, b, i, packet;

    // This contains the instantiation for the design under test
    cordic_zen4_top dut (.clk(clk), .link_clk_in(m_clk), .link_csn_in(m_csn), .link_d_in(d_bus), .link_d_out(f_out), .link_d_oe(f_oe), .btn1(1'b1), .led1(led1));

    // Converts a reply byte to a signed Q1.6 value
    function real q16(input [7:0] v);
        begin q16 = $itor($signed(v)) / 64.0; end
    endfunction

    // Sends a request and returns the reply of the following transfer (the Shrike fpga_query)
    task query(input [7:0] pkt, output [7:0] reply);
        reg [7:0] t;
        begin spi_exch(pkt, t); spi_exch(8'h00, reply); end
    endtask

    // This block runs the test
    initial begin
        #(20 * 400);
        // Angles in degrees: cos, sin and tan against the exact functions
        for (i = 0; i < 6; i = i + 1) begin
            deg = i * 9;                       // 0, 9, 18, 27, 36, 45
            rad = deg * 3.14159265358979 / 180.0;
            packet = $rtoi(rad * 64.0) & 8'h3F;
            query(packet[7:0] | 8'h00, r); got = q16(r); exact = $cos(rad); diff = (got > exact) ? got - exact : exact - got;
            if (diff > max_cs) max_cs = diff;
            if (diff > tol_cs) begin errs = errs + 1; $display("FAIL: cos(%0d deg) = %f, exact %f", deg, got, exact); end
            query(packet[7:0] | 8'h40, r); got = q16(r); exact = $sin(rad); diff = (got > exact) ? got - exact : exact - got;
            if (diff > max_cs) max_cs = diff;
            if (diff > tol_cs) begin errs = errs + 1; $display("FAIL: sin(%0d deg) = %f, exact %f", deg, got, exact); end
            query(packet[7:0] | 8'hC0, r); got = q16(r); exact = $tan(rad); diff = (got > exact) ? got - exact : exact - got;
            if (diff > max_tan) max_tan = diff;
            if (diff > tol_tan) begin errs = errs + 1; $display("FAIL: tan(%0d deg) = %f, exact %f", deg, got, exact); end
        end
        // Multiply: all 3-bit signed pairs
        for (a = -4; a < 4; a = a + 1) begin
            for (b = -4; b < 4; b = b + 1) begin
                query(8'h80 | ((a & 7) << 3) | (b & 7), r);
                if ($signed(r) !== a * b) begin errs = errs + 1; $display("FAIL: %0d * %0d = %0d", a, b, $signed(r)); end
            end
        end
        $display("max error: cos/sin %f, tan %f", max_cs, max_tan);
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
