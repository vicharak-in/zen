// This module connects the camera writer, frame buffer and VGA output
module cam_top
  import cam_pkg::*;
(
  input  logic       wclk,        // Write-side clock
  input  logic       wclk_rst_n,  // Write-side active-low reset
  input  logic       vga_clk,     // VGA pixel clock (25 MHz)
  input  logic       vga_rst_n,   // VGA-side active-low reset
  input  logic [7:0] cam_pixel,   // Pixel byte from the RP2350
  input  logic       cam_we,      // Pixel valid strobe
  input  logic       cam_vsync,   // Frame start from the RP2350
  output logic [7:0] vga_rgb,     // Pixel data to the VGA pins
  output logic       vga_hsync,   // VGA horizontal sync
  output logic       vga_vsync,   // VGA vertical sync
  output logic       frame_done   // One-clock pulse when a full frame has been captured (wclk domain)
);

  // Write address from the writer to the frame buffer
  logic [ADDR_WIDTH-1:0] waddr;
  // Write data from the writer to the frame buffer
  logic [7:0]            wdata;
  // Write enable from the writer to the frame buffer
  logic                  we_bram;
  // Read address from the reader to the frame buffer
  logic [ADDR_WIDTH-1:0] raddr;
  // Read data from the frame buffer to the reader
  logic [7:0]            rdata;
  // Horizontal sync from the timing generator
  logic                  hsync_t;
  // Vertical sync from the timing generator
  logic                  vsync_t;
  // Visible-area flag from the timing generator
  logic                  active_t;
  // Visible-area column from the timing generator
  logic [9:0]            x_t;
  // Visible-area row from the timing generator
  logic [9:0]            y_t;

  // This contains the instantiation for ov7670_writer
  ov7670_writer u_writer (
    .wclk       (wclk),
    .rst_n      (wclk_rst_n),
    .pixel      (cam_pixel),
    .we         (cam_we),
    .vsync_in   (cam_vsync),
    .waddr      (waddr),
    .wdata      (wdata),
    .we_bram    (we_bram),
    .frame_done (frame_done)
  );

  // This contains the instantiation for cam_bram
  cam_bram u_bram (
    .wclk  (wclk),
    .we    (we_bram),
    .waddr (waddr),
    .wdata (wdata),
    .rclk  (vga_clk),
    .raddr (raddr),
    .rdata (rdata)
  );

  // This contains the instantiation for vga_timing
  vga_timing u_timing (
    .clk    (vga_clk),
    .rst_n  (vga_rst_n),
    .hsync  (hsync_t),
    .vsync  (vsync_t),
    .active (active_t),
    .x      (x_t),
    .y      (y_t)
  );

  // This contains the instantiation for vga_reader
  vga_reader u_reader (
    .clk       (vga_clk),
    .rst_n     (vga_rst_n),
    .x         (x_t),
    .y         (y_t),
    .active    (active_t),
    .hsync_in  (hsync_t),
    .vsync_in  (vsync_t),
    .rdata     (rdata),
    .raddr     (raddr),
    .rgb       (vga_rgb),
    .hsync_out (vga_hsync),
    .vsync_out (vga_vsync)
  );

endmodule
