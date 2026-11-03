// This package holds the shared constants for the camera-to-VGA pipeline
package cam_pkg;

  // Camera frame width in pixels (320 for QVGA, 640 for VGA)
  parameter int HRES = 320;
  // Camera frame height in lines (240 for QVGA, 480 for VGA)
  parameter int VRES = 240;

  // Visible pixels per line on the 640x480 screen
  localparam int H_VISIBLE = 640;
  // Horizontal front porch in pixel clocks
  localparam int H_FRONT   = 16;
  // Horizontal sync pulse width in pixel clocks
  localparam int H_SYNC    = 96;
  // Horizontal back porch in pixel clocks
  localparam int H_BACK    = 48;

  // Visible lines per frame on the 640x480 screen
  localparam int V_VISIBLE = 480;
  // Vertical front porch in lines
  localparam int V_FRONT   = 10;
  // Vertical sync pulse width in lines
  localparam int V_SYNC    = 2;
  // Vertical back porch in lines
  localparam int V_BACK    = 33;

  // Total pixels in one camera frame
  localparam int FRAME_SIZE = HRES * VRES;
  // Address bits needed to index the frame buffer
  localparam int ADDR_WIDTH = $clog2(FRAME_SIZE);
  // Screen pixels covered by each camera pixel in each direction
  localparam int SCALE      = H_VISIBLE / HRES;

  // Total pixel clocks per line including blanking
  localparam int H_TOTAL = H_VISIBLE + H_FRONT + H_SYNC + H_BACK;
  // Total lines per frame including blanking
  localparam int V_TOTAL = V_VISIBLE + V_FRONT + V_SYNC + V_BACK;

endpackage
