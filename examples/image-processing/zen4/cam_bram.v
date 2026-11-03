// cam_bram.v - dual-port frame buffer memory with a registered read so it maps to block RAM
`default_nettype none

module cam_bram #(
    parameter ADDR_WIDTH = 13,                 // Address bits
    parameter DEPTH      = 4800                // Number of pixels stored
) (
    input  wire                  wclk,         // Write-side clock
    input  wire                  we,           // Write enable
    input  wire [ADDR_WIDTH-1:0] waddr,        // Write address
    input  wire [7:0]            wdata,        // Write data (one pixel)
    input  wire                  rclk,         // Read-side clock
    input  wire [ADDR_WIDTH-1:0] raddr,        // Read address
    output reg  [7:0]            rdata         // Read data (one pixel, valid one rclk after raddr)
);

    // Memory array holding one full frame
    reg [7:0] mem [0:DEPTH-1];

    // This block writes one pixel into the memory on the write clock
    always @(posedge wclk) begin
        if (we)                                // Only write when the enable is high
            mem[waddr] <= wdata;               // Store the pixel at the write address
    end

    // This block reads one pixel from the memory on the read clock
    always @(posedge rclk) begin
        rdata <= mem[raddr];                   // Registered read so the memory maps to block RAM
    end

endmodule

`default_nettype wire
