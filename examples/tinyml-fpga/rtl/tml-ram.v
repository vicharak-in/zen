// tml-ram.v - simple dual-port RAM (one write port, one read port, registered read output). This is the only memory primitive of the design:
// to move tinyml-fpga to another FPGA, replace the body of this module with that vendor's RAM and keep the ports.

module tml_ram #(
    parameter AW = 10, // Address width: the RAM holds 2**AW words
    parameter DW = 8   // Data width in bits
) (
    input  wire          clk,   // Clock for both ports
    input  wire          we,    // Write enable
    input  wire [AW-1:0] waddr, // Write address
    input  wire [DW-1:0] wdata, // Write data
    input  wire [AW-1:0] raddr, // Read address
    output reg  [DW-1:0] rdata  // Read data, valid one clock after raddr (registered output)
);

    // Storage array
    reg [DW-1:0] mem [0:(1<<AW)-1];

    // This block is the RAM: a write on the write port and a registered read on the read port
    always @(posedge clk) begin
        if (we) mem[waddr] <= wdata;   // Store the word when the write enable is high
        rdata <= mem[raddr];           // Read data appears one clock later (old data if the same address is written in this clock)
    end

endmodule
