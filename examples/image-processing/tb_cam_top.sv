// This is the self-checking testbench for the camera-to-VGA pipeline
`timescale 1ns/1ps
module tb_cam_top
  import cam_pkg::*;
;

  // Write-side clock (50 MHz)
  logic wclk = 1'b0;
  // VGA pixel clock (25 MHz)
  logic vga_clk = 1'b0;
  // Write-side active-low reset
  logic wclk_rst_n = 1'b0;
  // VGA-side active-low reset
  logic vga_rst_n = 1'b0;
  // Pixel byte driven like the RP2350 would
  logic [7:0] cam_pixel = 8'd0;
  // Pixel strobe driven like the RP2350 would
  logic cam_we = 1'b0;
  // Frame start driven like the RP2350 would
  logic cam_vsync = 1'b0;
  // VGA pixel data from the design
  logic [7:0] vga_rgb;
  // VGA horizontal sync from the design
  logic vga_hsync;
  // VGA vertical sync from the design
  logic vga_vsync;
  // Frame captured pulse from the design
  logic frame_done;

  // Set when the frame_done pulse has been seen
  logic frame_done_seen = 1'b0;
  // Enables the output checker
  logic check_en = 1'b0;
  // Number of visible pixels compared
  integer active_cnt = 0;
  // Number of pixel mismatches
  integer pix_err = 0;
  // Number of sync mismatches
  integer sync_err = 0;
  // Loop index for the frame playback
  integer i;
  // Clock count while checking
  integer chk_cycles = 0;

  // Expected pixel value for a camera address
  function automatic logic [7:0] pat(input integer a);
    pat = a[7:0] ^ a[15:8];
  endfunction

  // This contains the instantiation for cam_top
  cam_top dut (
    .wclk       (wclk),
    .wclk_rst_n (wclk_rst_n),
    .vga_clk    (vga_clk),
    .vga_rst_n  (vga_rst_n),
    .cam_pixel  (cam_pixel),
    .cam_we     (cam_we),
    .cam_vsync  (cam_vsync),
    .vga_rgb    (vga_rgb),
    .vga_hsync  (vga_hsync),
    .vga_vsync  (vga_vsync),
    .frame_done (frame_done)
  );

  // Write-side clock generation, 20 ns period
  always #10 wclk = ~wclk;
  // VGA clock generation, 40 ns period
  always #20 vga_clk = ~vga_clk;

  // This block remembers that frame_done pulsed
  always @(posedge wclk) begin
    if (frame_done) frame_done_seen <= 1'b1;   // Latch the pulse
  end

  // Three-stage history of the timing generator outputs, to line up with the three-clock output pipeline
  logic [9:0] x_d1, x_d2, x_d3, y_d1, y_d2, y_d3;
  logic       a_d1, a_d2, a_d3, h_d1, h_d2, h_d3, v_d1, v_d2, v_d3;

  // This block delays the timing outputs and compares the design output against the expected image
  always @(posedge vga_clk) begin
    x_d1 <= dut.x_t;  x_d2 <= x_d1;  x_d3 <= x_d2;           // Delay the column
    y_d1 <= dut.y_t;  y_d2 <= y_d1;  y_d3 <= y_d2;           // Delay the row
    a_d1 <= dut.active_t; a_d2 <= a_d1; a_d3 <= a_d2;        // Delay the visible flag
    h_d1 <= dut.hsync_t;  h_d2 <= h_d1; h_d3 <= h_d2;        // Delay hsync
    v_d1 <= dut.vsync_t;  v_d2 <= v_d1; v_d3 <= v_d2;        // Delay vsync
    if (check_en) begin                                      // Only check after the frame is loaded
      chk_cycles <= chk_cycles + 1;                          // Count checked clocks
      if (vga_hsync !== h_d3 || vga_vsync !== v_d3)          // Syncs must match the delayed timing
        sync_err <= sync_err + 1;                            // Record a sync mismatch
      if (a_d3) begin                                        // Inside the visible area
        active_cnt <= active_cnt + 1;                        // Count the visible pixel
        if (vga_rgb !== pat((y_d3 / SCALE) * HRES + (x_d3 / SCALE))) // Compare against the expected pixel
          pix_err <= pix_err + 1;                            // Record a pixel mismatch
      end else if (vga_rgb !== 8'd0)                         // Outside the visible area the output must be black
        pix_err <= pix_err + 1;                              // Record a blanking mismatch
    end
  end

  // This block runs the test sequence
  initial begin
    repeat (10) @(posedge wclk);                 // Hold reset for a few clocks
    wclk_rst_n = 1'b1;                           // Release the write-side reset
    vga_rst_n  = 1'b1;                           // Release the VGA-side reset
    repeat (10) @(posedge wclk);                 // Let things settle
    cam_vsync = 1'b1;                            // Start a frame with a rising vsync
    repeat (6) @(posedge wclk);                  // Hold it for a few clocks
    cam_vsync = 1'b0;                            // Drop vsync
    repeat (6) @(posedge wclk);                  // Wait before the first pixel
    for (i = 0; i < FRAME_SIZE; i = i + 1) begin // Send every pixel of the frame
      cam_pixel = pat(i);                        // Put the pixel on the bus
      repeat (2) @(posedge wclk);                // Let the data settle before the strobe
      cam_we = 1'b1;                             // Raise the strobe
      repeat (3) @(posedge wclk);                // Hold the strobe
      cam_we = 1'b0;                             // Drop the strobe
      repeat (3) @(posedge wclk);                // Gap before the next pixel
    end
    repeat (20) @(posedge wclk);                 // Let the last write finish
    if (!frame_done_seen) begin                  // frame_done must have pulsed
      $display("FAIL: frame_done never pulsed");
      $finish;
    end
    @(posedge vga_clk);                          // Align to the VGA clock
    check_en = 1'b1;                             // Start checking the output
    repeat (H_TOTAL * V_TOTAL + 8) @(posedge vga_clk); // Check exactly one frame period plus pipeline margin
    check_en = 1'b0;                             // Stop checking
    @(posedge vga_clk);                          // Let the final counts settle
    $display("checked clocks = %0d, visible pixels = %0d (expect %0d)", chk_cycles, active_cnt, 640 * 480);
    $display("pixel errors = %0d, sync errors = %0d", pix_err, sync_err);
    if (pix_err == 0 && sync_err == 0 && active_cnt >= 640 * 480 - 8 && active_cnt <= 640 * 480 + 8)
      $display("PASS");
    else
      $display("FAIL");
    $finish;
  end

  // This block stops a hung simulation
  initial begin
    #60_000_000;                                 // 60 ms of simulated time
    $display("FAIL: timeout");
    $finish;
  end

endmodule
