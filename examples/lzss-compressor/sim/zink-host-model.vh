// zink-host-model.vh - testbench include: a model of the RP2350 side of the Zen Link (drives real link frames into a design, reads replies).
// Include it inside a testbench module that already has: reg clk (50 MHz). It declares the link signals and the tasks wr1, wrn, rdn, check8.
// Wire the design under test with .link_clk_in(m_clk), .link_csn_in(m_csn), .link_d_in(d_bus), .link_d_out(f_out), .link_d_oe(f_oe).

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
    // Bytes to write in a burst
    reg [7:0] wb [0:255];

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

    // Writes n bytes from wb[0..n-1] starting at addr (one burst frame, n <= 128)
    task wrn(input [15:0] addr, input integer n);
        integer k;
        begin begin_frame(8'h00 | (n - 1), addr); for (k = 0; k < n; k = k + 1) beat_out(wb[k]); end_frame; end
    endtask

    // Reads n bytes starting at addr into rb[0..n-1] (one burst frame, n <= 128)
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

    // Checks a value
    task check8(input [7:0] got, input [7:0] exp, input [255:0] what);
        begin
            if (got !== exp) begin errs = errs + 1; $display("FAIL: %0s got %h expected %h", what, got, exp); end
        end
    endtask
