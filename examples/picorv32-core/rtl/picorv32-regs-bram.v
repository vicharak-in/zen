// This is the block-RAM register file for PicoRV32, plugged in through the core's PICORV32_REGS hook
// This macro tells picorv32.v to use picorv32_regs_bram instead of its built-in asynchronous-read array
`ifndef PICORV32_REGS
`define PICORV32_REGS picorv32_regs_bram
`endif

module picorv32_regs_bram (
    // Core clock (writes happen on its rising edge)
    input  wire        clk,
    // Write enable (already gated by the core: resetn && write && rd != x0)
    input  wire        wen,
    // Write address (destination register index)
    input  wire [5:0]  waddr,
    // Read address for port 1 (source register rs1)
    input  wire [5:0]  raddr1,
    // Read address for port 2 (source register rs2)
    input  wire [5:0]  raddr2,
    // Write data
    input  wire [31:0] wdata,
    // Read data for port 1 (valid before the next rising edge)
    output wire [31:0] rdata1,
    // Read data for port 2 (valid before the next rising edge)
    output wire [31:0] rdata2
);

    // Copy 1 of the register array, read through port 1 (inferred as block RAM)
    reg [31:0] mem1 [0:63];
    // Copy 2 of the register array, read through port 2 (inferred as block RAM)
    reg [31:0] mem2 [0:63];
    // Registered read data for port 1
    reg [31:0] q1 = 32'h0;
    // Registered read data for port 2
    reg [31:0] q2 = 32'h0;

    // Write block: both copies are written together on the rising edge
    always @(posedge clk) begin
        // Only write when the core says so
        if (wen) begin
            // Update copy 1
            mem1[waddr] <= wdata;
            // Update copy 2
            mem2[waddr] <= wdata;
        end
    end

    // Read block: reads on the FALLING edge so the data is ready half a cycle later,
    // which makes the synchronous RAM look like the combinational read the core expects
    always @(negedge clk) begin
        // Read port 1 (the address has been stable since just after the last rising edge)
        q1 <= mem1[raddr1];
        // Read port 2
        q2 <= mem2[raddr2];
    end

    // Drive the core's read data from the registered outputs
    assign rdata1 = q1;
    // Drive the core's read data from the registered outputs
    assign rdata2 = q2;

endmodule
