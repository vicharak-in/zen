// This module generates VGA sync signals and the visible-area pixel position
module vga_timing
  import cam_pkg::*;
(
  input  logic       clk,     // VGA pixel clock (25 MHz)
  input  logic       rst_n,   // Active-low reset
  output logic       hsync,   // Horizontal sync (active low)
  output logic       vsync,   // Vertical sync (active low)
  output logic       active,  // High inside the visible 640x480 area
  output logic [9:0] x,       // Visible-area pixel column (0 outside the visible area)
  output logic [9:0] y        // Visible-area pixel row (0 outside the visible area)
);

  // Pixel counter across one full line including blanking
  logic [9:0] hcnt;
  // Line counter across one full frame including blanking
  logic [9:0] vcnt;

  // This block counts pixels along each line and lines along each frame
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin                          // Clear both counters on reset
      hcnt <= '0;                              // Start at the first pixel
      vcnt <= '0;                              // Start at the first line
    end else if (hcnt == H_TOTAL - 1) begin    // End of a line
      hcnt <= '0;                              // Wrap to the first pixel
      if (vcnt == V_TOTAL - 1)                 // End of a frame
        vcnt <= '0;                            // Wrap to the first line
      else                                     // Still inside the frame
        vcnt <= vcnt + 1'b1;                   // Move to the next line
    end else begin                             // Middle of a line
      hcnt <= hcnt + 1'b1;                     // Move to the next pixel
    end
  end

  // Horizontal sync is low during the sync pulse that follows the front porch
  assign hsync = ~((hcnt >= H_VISIBLE + H_FRONT) && (hcnt < H_VISIBLE + H_FRONT + H_SYNC));
  // Vertical sync is low during the sync pulse that follows the front porch
  assign vsync = ~((vcnt >= V_VISIBLE + V_FRONT) && (vcnt < V_VISIBLE + V_FRONT + V_SYNC));
  // The pixel is visible when both counters are inside the visible area
  assign active = (hcnt < H_VISIBLE) && (vcnt < V_VISIBLE);
  // Column output is the counter inside the visible area and zero outside
  assign x = active ? hcnt : 10'd0;
  // Row output is the counter inside the visible area and zero outside
  assign y = active ? vcnt : 10'd0;

endmodule
