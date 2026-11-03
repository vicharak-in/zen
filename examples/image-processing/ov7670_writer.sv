// This module turns the camera pixel stream into frame buffer write signals
module ov7670_writer
  import cam_pkg::*;
(
  input  logic                  wclk,        // Write-side clock (the RP2350 signals are asynchronous to it)
  input  logic                  rst_n,       // Active-low reset
  input  logic [7:0]            pixel,       // Pixel byte from the RP2350 (stable while we is high)
  input  logic                  we,          // Pixel valid strobe from the RP2350
  input  logic                  vsync_in,    // Frame start from the RP2350 (rising edge starts a frame)
  output logic [ADDR_WIDTH-1:0] waddr,       // Frame buffer write address
  output logic [7:0]            wdata,       // Frame buffer write data
  output logic                  we_bram,     // Frame buffer write enable
  output logic                  frame_done   // One-clock pulse when the last pixel of a frame is written
);

  // Synchronizer chain for the pixel strobe, the top two bits are used for edge detection
  logic [2:0] we_sync;
  // Synchronizer chain for the frame start, the top two bits are used for edge detection
  logic [2:0] vs_sync;
  // One-clock pulse for each new pixel strobe
  logic       we_pulse;
  // One-clock pulse for each new frame start
  logic       vs_pulse;
  // Address where the next pixel will be stored
  logic [ADDR_WIDTH-1:0] next_addr;
  // Set once a full frame has been written, further pixels are ignored until the next frame start
  logic       full;

  // This block brings the asynchronous RP2350 strobes into the wclk domain
  always_ff @(posedge wclk or negedge rst_n) begin
    if (!rst_n) begin                          // Clear both chains on reset
      we_sync <= '0;                           // Pixel strobe chain cleared
      vs_sync <= '0;                           // Frame start chain cleared
    end else begin                             // Normal operation
      we_sync <= {we_sync[1:0], we};           // Shift the pixel strobe through the chain
      vs_sync <= {vs_sync[1:0], vsync_in};     // Shift the frame start through the chain
    end
  end

  // A pixel strobe pulse is a rising edge on the synchronized strobe
  assign we_pulse = we_sync[1] & ~we_sync[2];
  // A frame start pulse is a rising edge on the synchronized frame start
  assign vs_pulse = vs_sync[1] & ~vs_sync[2];

  // This block captures each pixel and drives the frame buffer write port
  always_ff @(posedge wclk or negedge rst_n) begin
    if (!rst_n) begin                          // Clear everything on reset
      next_addr  <= '0;                        // Next pixel goes to address zero
      full       <= 1'b0;                      // Frame is not full
      waddr      <= '0;                        // Write address cleared
      wdata      <= '0;                        // Write data cleared
      we_bram    <= 1'b0;                      // No write in progress
      frame_done <= 1'b0;                      // No frame completed yet
    end else begin                             // Normal operation
      we_bram    <= 1'b0;                      // Default: no write this clock
      frame_done <= 1'b0;                      // Default: no frame-done pulse this clock
      if (vs_pulse) begin                      // A new frame starts, this takes priority over a pixel
        next_addr <= '0;                       // Restart at the first address
        full      <= 1'b0;                     // Allow writes again
      end else if (we_pulse && !full) begin    // A new pixel arrives and there is room
        wdata   <= pixel;                      // Capture the pixel byte
        waddr   <= next_addr;                  // Write it at the next free address
        we_bram <= 1'b1;                       // Pulse the memory write enable
        if (next_addr == FRAME_SIZE - 1) begin // This was the last pixel of the frame
          full       <= 1'b1;                  // Ignore further pixels until the next frame
          frame_done <= 1'b1;                  // Announce the completed frame
        end else begin                         // More pixels to come
          next_addr <= next_addr + 1'b1;       // Advance to the next address
        end
      end
    end
  end

endmodule
