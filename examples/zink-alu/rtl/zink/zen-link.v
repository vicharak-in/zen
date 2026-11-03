// zen_link.v - top level of the Zen Link FPGA endpoint.
// Pins: 8 data bits (bidirectional), CLK and CS_N (inputs from the RP2350).
// From your Verilog the link looks like:
//   ctrl_flat : registers the MCU writes   (read them as ctrl_flat[8*i +: 8])
//   stat_flat : registers you drive        (the MCU reads them)
//   usr_*     : optional bus for anything at address >= 0x100 (RAMs, FIFOs, ...)
// Bus rules for usr_*: usr_wr/usr_rd are one-clk strobes, usr_addr is stable for
// several clks before them, usr_rdata must be valid (combinational from usr_addr,
// or a registered RAM output) in the clk where usr_rd is high.

module zen_link #(
    parameter NCTRL = 4, // MCU-written control registers (max 16)
    parameter NSTAT = 4  // FPGA-driven status registers (max 16)
) (
    input  wire                clk,         // FPGA system clock (oscillator)
    input  wire                rst_n,       // active-low synchronous reset (tie to 1 if unused)
    input  wire                link_clk_in, // GPIO28 side: link CLK from the RP2350
    input  wire                link_csn_in, // GPIO29 side: link CS_N from the RP2350
    input  wire [7:0]          link_d_in,   // data pins, input side
    output wire [7:0]          link_d_out,  // data pins, output side
    output wire [7:0]          link_d_oe,   // data pins, output enable (same value on all 8)
    output wire [8*NCTRL-1:0] ctrl_flat,   // MCU-written registers, flattened
    input  wire [8*NSTAT-1:0] stat_flat,   // FPGA-driven registers, flattened
    output wire [15:0]         usr_addr,    // user bus byte address (>= 0x100 when strobing)
    output wire                usr_wr,      // user bus write strobe
    output wire [7:0]         usr_wdata,   // user bus write data
    output wire                usr_rd,      // user bus read strobe
    input  wire [7:0]         usr_rdata    // user bus read data
);

    // Byte address from the slave.
    wire [15:0] cpu_addr;
    // Write strobe from the slave.
    wire        cpu_wr;
    // Write data from the slave.
    wire [7:0] cpu_wdata;
    // Read strobe from the slave.
    wire        cpu_rd;
    // Read data returned to the slave.
    wire [7:0] cpu_rdata;
    // Single output-enable bit from the slave.
    wire        d_oe;
    // Read data from the register bank.
    wire [7:0] bank_rdata;
    // High when the address falls inside the register bank (0x00-0xFF).
    wire        sel_bank = (cpu_addr[15:8] == 8'd0);

    // Pick bank or user data for the read path.
    assign cpu_rdata = sel_bank ? bank_rdata : usr_rdata;
    // User bus mirrors the CPU bus outside the bank.
    assign usr_addr  = cpu_addr;
    // User write data.
    assign usr_wdata = cpu_wdata;
    // User write strobe only when the address is outside the bank.
    assign usr_wr    = cpu_wr & ~sel_bank;
    // User read strobe only when the address is outside the bank.
    assign usr_rd    = cpu_rd & ~sel_bank;
    // Replicate the single output enable for the 8 per-pin OE signals.
    assign link_d_oe = {8{d_oe}};

    // This contains the instantiation for u_slave
    zl_slave u_slave (
        .clk         (clk),
        .rst_n       (rst_n),
        .link_clk_in (link_clk_in),
        .link_csn_in (link_csn_in),
        .link_d_in   (link_d_in),
        .link_d_out  (link_d_out),
        .link_d_oe   (d_oe),
        .cpu_addr    (cpu_addr),
        .cpu_wr      (cpu_wr),
        .cpu_wdata   (cpu_wdata),
        .cpu_rd      (cpu_rd),
        .cpu_rdata   (cpu_rdata)
    );

    // This contains the instantiation for u_regs
    zl_regs #(
        .NCTRL (NCTRL),
        .NSTAT (NSTAT)
    ) u_regs (
        .clk       (clk),
        .rst_n     (rst_n),
        .addr      (cpu_addr[7:0]),
        .wr        (cpu_wr & sel_bank),
        .wdata     (cpu_wdata),
        .rdata     (bank_rdata),
        .ctrl_flat (ctrl_flat),
        .stat_flat (stat_flat)
    );

endmodule
