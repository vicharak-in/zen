// tb_zen_link.v - cocotb wrapper for zen_link.
// Models the real board: the 8 data pins are a shared tri-state bus driven by
// either the "RP2350" (m_* regs, driven from cocotb) or the FPGA (triplet outputs).
// Also provides a 256-byte user RAM behind the user bus (addresses 0x100-0x1FF)
// and a sticky bus-contention flag.
`timescale 1ns/1ps

module tb_zen_link #(
    parameter RAM_REG = 0, // 1 = user RAM has a registered (BRAM-style) read output
    parameter NCTRL   = 4, // control registers
    parameter NSTAT   = 4  // status registers
) ();

    // FPGA system clock (driven by cocotb).
    reg clk;
    // Active-low reset (driven by cocotb).
    reg rst_n;
    // Link CLK driven by the RP2350 model.
    reg m_clk;
    // Link CS_N driven by the RP2350 model.
    reg m_csn;
    // Data byte driven by the RP2350 model.
    reg [7:0] m_d;
    // 1 while the RP2350 model drives the data pins.
    reg m_oe;
    // Status registers driven by cocotb (what the FPGA user logic would provide).
    reg [8*NSTAT-1:0] stat_flat;

    // Control registers as seen by the FPGA user logic.
    wire [8*NCTRL-1:0] ctrl_flat;
    // FPGA data output side of the triplet.
    wire [7:0] f_out;
    // FPGA data output enables.
    wire [7:0] f_oe;
    // Shared tri-state data pins.
    wire [7:0] d_bus;
    // User bus signals.
    wire [15:0] usr_addr;
    wire        usr_wr;
    wire [7:0]  usr_wdata;
    wire        usr_rd;
    wire [7:0]  usr_rdata;
    // Sticky flag: set if both sides ever drive the data pins at once.
    reg contention;

    // Per-pin tri-state drivers, RP2350 side.
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
        // Clock and reset.
        clk = 1'b0; rst_n = 1'b0;
        // Link idle: CLK low, CS_N high, nobody drives data.
        m_clk = 1'b0; m_csn = 1'b1; m_d = 8'd0; m_oe = 1'b0;
        // Status inputs and contention flag.
        stat_flat = {(8*NSTAT){1'b0}}; contention = 1'b0;
    end

    // Contention detector: flags any time both ends enable their drivers.
    always @(m_oe or f_oe) if (m_oe && (|f_oe)) contention = 1'b1;

    // User RAM storage.
    reg [7:0] mem [0:255];
    // Registered read value (used when RAM_REG = 1).
    reg [7:0] mem_q;
    // Byte index into the RAM.
    wire [7:0] ma = usr_addr[7:0];

    // Loop index used to zero the RAM at time 0.
    integer j;
    // Zero the user RAM so unwritten words read as 0 instead of X.
    initial for (j = 0; j < 256; j = j + 1) mem[j] = 8'd0;

    // User RAM: synchronous write, optionally registered read.
    always @(posedge clk) begin
        // Write the RAM when the user bus writes.
        if (usr_wr) mem[ma] <= usr_wdata;
        // Registered read, one clk after the address.
        mem_q <= mem[ma];
    end

    // Combinational or registered read data.
    assign usr_rdata = RAM_REG ? mem_q : mem[ma];

    // This contains the instantiation for dut
    zen_link #(
        .NCTRL (NCTRL),
        .NSTAT (NSTAT)
    ) dut (
        .clk         (clk),
        .rst_n       (rst_n),
        .link_clk_in (m_clk),
        .link_csn_in (m_csn),
        .link_d_in   (d_bus),
        .link_d_out  (f_out),
        .link_d_oe   (f_oe),
        .ctrl_flat   (ctrl_flat),
        .stat_flat   (stat_flat),
        .usr_addr    (usr_addr),
        .usr_wr      (usr_wr),
        .usr_wdata   (usr_wdata),
        .usr_rd      (usr_rd),
        .usr_rdata   (usr_rdata)
    );

endmodule
