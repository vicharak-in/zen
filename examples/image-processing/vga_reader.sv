// This module reads the frame buffer and drives the VGA output pins
module vga_reader
  import cam_pkg::*;
(
  input  logic                  clk,         // VGA pixel clock
  input  logic                  rst_n,       // Active-low reset
  input  logic [9:0]            x,           // Visible-area pixel column
  input  logic [9:0]            y,           // Visible-area pixel row
  input  logic                  active,      // High inside the visible area
  input  logic                  hsync_in,    // Horizontal sync from vga_timing
  input  logic                  vsync_in,    // Vertical sync from vga_timing
  input  logic [7:0]            rdata,       // Pixel data from the frame buffer (one clock after raddr)
  output logic [ADDR_WIDTH-1:0] raddr,       // Frame buffer read address
  output logic [7:0]            rgb,         // Pixel data to the VGA pins (black outside the visible area)
  output logic                  hsync_out,   // Horizontal sync, delayed to match the pixel data
  output logic                  vsync_out    // Vertical sync, delayed to match the pixel data
);

  // Active flag after the address register stage
  logic active_d1;
  // Active flag after the memory read stage, lines up with rdata
  logic active_d2;
  // Horizontal sync after the address register stage
  logic hs_d1;
  // Horizontal sync after the memory read stage
  logic hs_d2;
  // Vertical sync after the address register stage
  logic vs_d1;
  // Vertical sync after the memory read stage
  logic vs_d2;

  // This block pipelines the address and the control signals to match the three-clock data path
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin                                      // Clear the pipeline on reset
      raddr     <= '0;                                     // Read address cleared
      active_d1 <= 1'b0;                                   // Stage 1 active cleared
      active_d2 <= 1'b0;                                   // Stage 2 active cleared
      hs_d1     <= 1'b1;                                   // Stage 1 hsync idles high
      hs_d2     <= 1'b1;                                   // Stage 2 hsync idles high
      vs_d1     <= 1'b1;                                   // Stage 1 vsync idles high
      vs_d2     <= 1'b1;                                   // Stage 2 vsync idles high
      rgb       <= 8'd0;                                   // Output black
      hsync_out <= 1'b1;                                   // Output hsync idles high
      vsync_out <= 1'b1;                                   // Output vsync idles high
    end else begin                                         // Normal operation
      raddr     <= ADDR_WIDTH'((y / SCALE) * HRES + (x / SCALE)); // Map the screen position to a camera pixel address
      active_d1 <= active;                                 // Delay active by one clock
      hs_d1     <= hsync_in;                               // Delay hsync by one clock
      vs_d1     <= vsync_in;                               // Delay vsync by one clock
      active_d2 <= active_d1;                              // Delay active by the memory read clock
      hs_d2     <= hs_d1;                                  // Delay hsync by the memory read clock
      vs_d2     <= vs_d1;                                  // Delay vsync by the memory read clock
      rgb       <= active_d2 ? rdata : 8'd0;               // Show the pixel inside the visible area, black outside
      hsync_out <= hs_d2;                                  // Output the aligned hsync
      vsync_out <= vs_d2;                                  // Output the aligned vsync
    end
  end

endmodule
