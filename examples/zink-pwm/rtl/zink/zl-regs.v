// zl_regs.v - Zen Link register bank.
// Byte-address map (all registers are 8 bit):
//   0x00        ID       RO   8'h5A
//   0x01        ID_INV   RO   ~ID (8'hA5), so a floating or stuck bus cannot pass for a link
//   0x02        SCRATCH  RW   loopback test register
//   0x03        VERSION  RO   8'h01
//   0x10+i      CTRL[i]  RW   written by the MCU, wired out to your Verilog (i < NCTRL <= 16)
//   0x20+j      STAT[j]  RO   driven by your Verilog, read by the MCU     (j < NSTAT <= 16)
//   0x100+      not handled here - goes to the user bus in zen_link.v
// Unmapped addresses inside 0x00-0xFF read as zero and ignore writes.

module zl_regs #(
    parameter       NCTRL   = 4,       // number of MCU-written control registers (max 16)
    parameter       NSTAT   = 4,       // number of FPGA-driven status registers (max 16)
    parameter [7:0] ID      = 8'h5A,   // value returned by the ID register
    parameter [7:0] VERSION = 8'h01    // value returned by the VERSION register
) (
    input  wire                clk,       // FPGA system clock
    input  wire                rst_n,     // active-low synchronous reset
    input  wire [7:0]          addr,      // address bits [7:0]
    input  wire                wr,        // write strobe, already qualified with "address in bank"
    input  wire [7:0]          wdata,     // write data
    output reg  [7:0]          rdata,     // read data (combinational from addr)
    output wire [8*NCTRL-1:0]  ctrl_flat, // all control registers, register i = ctrl_flat[8*i +: 8]
    input  wire [8*NSTAT-1:0]  stat_flat  // all status registers,  register j = stat_flat[8*j +: 8]
);

    // Scratch register.
    reg [7:0] scratch = 8'h00;
    // Control register storage (starts at 0 so the outputs are defined from power-up, reset is tied high).
    reg [8*NCTRL-1:0] ctrl_q = {(8*NCTRL){1'b0}};
    // Loop index used by the read mux and the write decode.
    integer k;

    // Control registers are visible to the user logic.
    assign ctrl_flat = ctrl_q;

    // Register writes: SCRATCH and the control registers.
    // On reset everything clears; on a write strobe the addressed register loads wdata.
    always @(posedge clk) begin
        // Reset branch.
        if (!rst_n) begin
            // Clear the scratch register.
            scratch <= 8'd0;
            // Clear every control register.
            ctrl_q  <= {(8*NCTRL){1'b0}};
        end else if (wr) begin
            // SCRATCH lives at address 0x02.
            if (addr == 8'h02) scratch <= wdata;
            // CTRL[i] lives at addresses 0x10..0x1F.
            for (k = 0; k < NCTRL; k = k + 1)
                // Load the register whose address matches.
                if (addr == (8'h10 + k)) ctrl_q[8*k +: 8] <= wdata;
        end
    end

    // Read mux: pick ID / ID_INV / SCRATCH / VERSION / CTRL[i] / STAT[j] by address, zero otherwise.
    // Purely combinational so rdata is valid in the same clk as the address.
    always @* begin
        // Default for unmapped addresses.
        rdata = 8'd0;
        // ID register.
        if (addr == 8'h00) rdata = ID;
        // Inverted ID register.
        if (addr == 8'h01) rdata = ~ID;
        // SCRATCH register.
        if (addr == 8'h02) rdata = scratch;
        // VERSION register.
        if (addr == 8'h03) rdata = VERSION;
        // Control register read-back.
        for (k = 0; k < NCTRL; k = k + 1)
            // Select CTRL[k].
            if (addr == (8'h10 + k)) rdata = ctrl_q[8*k +: 8];
        // Status registers.
        for (k = 0; k < NSTAT; k = k + 1)
            // Select STAT[k].
            if (addr == (8'h20 + k)) rdata = stat_flat[8*k +: 8];
    end

endmodule
