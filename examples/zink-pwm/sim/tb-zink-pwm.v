// tb_zink_pwm.v - cocotb wrapper for zink_pwm_top.
// The 8 data pins are a shared tri-state bus: driven by the RP2350 model (m_* regs, from cocotb)
// or by the FPGA (zink_pwm_top outputs).
`timescale 1ns/1ps

module tb_zink_pwm ();

    // FPGA system clock (driven by cocotb).
    reg clk;
    // Link CLK driven by the RP2350 model.
    reg m_clk;
    // Link CS_N driven by the RP2350 model.
    reg m_csn;
    // Data byte driven by the RP2350 model.
    reg [7:0] m_d;
    // 1 while the RP2350 model drives the data pins.
    reg m_oe;

    // FPGA data output side of the triplet.
    wire [7:0] f_out;
    // FPGA data output enables.
    wire [7:0] f_oe;
    // Shared tri-state data pins.
    wire [7:0] d_bus;
    // LED pins (active low).
    wire led1, led2;

    // Per-pin tri-state drivers.
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : g_pin
            // RP2350 drives pin i when m_oe is set.
            assign d_bus[i] = m_oe    ? m_d[i]   : 1'bz;
            // FPGA drives pin i when its oe is set.
            assign d_bus[i] = f_oe[i] ? f_out[i] : 1'bz;
        end
    endgenerate

    // Initial values so nothing is X before cocotb starts.
    initial begin
        clk = 1'b0;
        m_clk = 1'b0; m_csn = 1'b1; m_d = 8'd0; m_oe = 1'b0;
    end

    // This contains the instantiation for dut
    zink_pwm_top dut (
        .clk         (clk),
        .link_clk_in (m_clk),
        .link_csn_in (m_csn),
        .link_d_in   (d_bus),
        .link_d_out  (f_out),
        .link_d_oe   (f_oe),
        .btn1        (1'b1),
        .btn2        (1'b1),
        .led1        (led1),
        .led2        (led2)
    );

endmodule
