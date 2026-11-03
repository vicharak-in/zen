// This module is the dual-clock frame buffer memory
module cam_bram
  import cam_pkg::*;
(
  input  logic                  wclk,   // Write-side clock
  input  logic                  we,     // Write enable
  input  logic [ADDR_WIDTH-1:0] waddr,  // Write address
  input  logic [7:0]            wdata,  // Write data (one pixel)
  input  logic                  rclk,   // Read-side clock
  input  logic [ADDR_WIDTH-1:0] raddr,  // Read address
  output logic [7:0]            rdata   // Read data (one pixel, valid one rclk after raddr)
);

  // Memory array holding one full camera frame
  logic [7:0] mem [0:FRAME_SIZE-1];

  // This block writes one pixel into the memory on the write clock
  always_ff @(posedge wclk) begin
    if (we)                    // Only write when the enable is high
      mem[waddr] <= wdata;     // Store the pixel at the write address
  end

  // This block reads one pixel from the memory on the read clock
  always_ff @(posedge rclk) begin
    rdata <= mem[raddr];       // Registered read so the memory maps to block RAM
  end

endmodule
