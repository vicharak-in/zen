// vga_timing.v - generates 640x480 @ 60 Hz sync signals and the visible-area pixel position
`default_nettype none

module vga_timing (
    input  wire       clk,     // VGA pixel clock (25 MHz)
    input  wire       rst_n,   // Active-low reset
    output wire       hsync,   // Horizontal sync (active low)
    output wire       vsync,   // Vertical sync (active low)
    output wire       active,  // High inside the visible 640x480 area
    output wire [9:0] x,       // Visible-area pixel column (0 outside the visible area)
    output wire [9:0] y        // Visible-area pixel row (0 outside the visible area)
);

    // Visible pixels per line
    localparam H_VISIBLE = 640;
    // Horizontal front porch in pixel clocks
    localparam H_FRONT   = 16;
    // Horizontal sync pulse width in pixel clocks
    localparam H_SYNC    = 96;
    // Horizontal back porch in pixel clocks
    localparam H_BACK    = 48;
    // Visible lines per frame
    localparam V_VISIBLE = 480;
    // Vertical front porch in lines
    localparam V_FRONT   = 10;
    // Vertical sync pulse width in lines
    localparam V_SYNC    = 2;
    // Vertical back porch in lines
    localparam V_BACK    = 33;
    // Total pixel clocks per line including blanking
    localparam H_TOTAL   = H_VISIBLE + H_FRONT + H_SYNC + H_BACK;
    // Total lines per frame including blanking
    localparam V_TOTAL   = V_VISIBLE + V_FRONT + V_SYNC + V_BACK;

    // Pixel counter across one full line including blanking
    reg [9:0] hcnt;
    // Line counter across one full frame including blanking
    reg [9:0] vcnt;

    // This block counts pixels along each line and lines along each frame
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin                          // Clear both counters on reset
            hcnt <= 10'd0;                         // Start at the first pixel
            vcnt <= 10'd0;                         // Start at the first line
        end else if (hcnt == H_TOTAL - 1) begin    // End of a line
            hcnt <= 10'd0;                         // Wrap to the first pixel
            if (vcnt == V_TOTAL - 1)               // End of a frame
                vcnt <= 10'd0;                     // Wrap to the first line
            else                                   // Still inside the frame
                vcnt <= vcnt + 10'd1;              // Move to the next line
        end else begin                             // Middle of a line
            hcnt <= hcnt + 10'd1;                  // Move to the next pixel
        end
    end

    // Horizontal sync is low during the sync pulse that follows the front porch
    assign hsync  = ~((hcnt >= H_VISIBLE + H_FRONT) && (hcnt < H_VISIBLE + H_FRONT + H_SYNC));
    // Vertical sync is low during the sync pulse that follows the front porch
    assign vsync  = ~((vcnt >= V_VISIBLE + V_FRONT) && (vcnt < V_VISIBLE + V_FRONT + V_SYNC));
    // The pixel is visible when both counters are inside the visible area
    assign active = (hcnt < H_VISIBLE) && (vcnt < V_VISIBLE);
    // Column output is the counter inside the visible area and zero outside
    assign x      = active ? hcnt : 10'd0;
    // Row output is the counter inside the visible area and zero outside
    assign y      = active ? vcnt : 10'd0;

endmodule

`default_nettype wire
