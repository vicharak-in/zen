// sobel_core.v - streaming 3x3 Sobel edge filter on a raster pixel stream, picture size set at run time (up to MAXW wide).
// One input pixel per step. After a lead-in of W+1 steps every step also gives one output byte, so a frame of W*H pixels
// needs W+1 extra steps (feed zeros) to push out the last W+1 results. The 1-pixel border of the picture is output as 0.
// Output for the centre pixel (y, x) is min(255, |Gx| + |Gy|) with Gx = right - left columns, Gy = bottom - top rows.

`default_nettype none

module sobel_core #(
    parameter MAXW = 640                    // widest picture the line buffer holds
) (
    input  wire                      clk,       // clock
    input  wire                      rst,       // synchronous reset, active high
    input  wire                      start,     // one-clock pulse: new frame (loads w_m1 / h_m1), top of the picture
    input  wire                      step,      // one-clock pulse: take pix_in as the next pixel (only while ready)
    input  wire [7:0]                pix_in,    // next pixel of the raster scan
    input  wire [$clog2(MAXW)-1:0]   w_m1,      // picture width minus 1 (stable during a frame)
    input  wire [15:0]               h_m1,      // picture height minus 1 (stable during a frame)
    output wire                      ready,     // high when idle: a step can be accepted
    output wire                      last,      // high while the pixel to be stepped in next is the last of the frame
    output reg                       out_valid, // one-clock pulse: out_data is the next output byte
    output reg  [7:0]                out_data   // edge magnitude of the pixel one line and one column behind the input
);

    // Width of the column counter.
    localparam AW = $clog2(MAXW);
    // Step states.
    localparam [1:0] S_IDLE = 2'd0, S_READ = 2'd1, S_SHIFT = 2'd2, S_OUT = 2'd3;

    // Line buffer: low byte = pixel one line up, high byte = pixel two lines up, for each column.
    reg [15:0]   lbuf [0:MAXW-1];
    // Step state.
    reg [1:0]    st;
    // Column of the pixel being stepped in.
    reg [AW-1:0] col;
    // Line of the pixel being stepped in.
    reg [15:0]   row;
    // Steps still to skip before outputs are valid.
    reg [15:0]   skip;
    // Pixel latched for this step.
    reg [7:0]    pix;
    // Line buffer read data.
    reg [15:0]   rd;
    // 3x3 window, top row (two lines up), oldest column first.
    reg [7:0]    a0, a1, a2;
    // 3x3 window, middle row (one line up), oldest column first.
    reg [7:0]    b0, b1, b2;
    // 3x3 window, bottom row (current line), oldest column first.
    reg [7:0]    c0, c1, c2;

    // Ready while no step is in progress.
    assign ready = (st == S_IDLE);
    // The next pixel is the last one of the picture.
    assign last  = (col == w_m1) && (row == h_m1);

    // Weighted sum of the right column (1, 2, 1).
    wire [10:0] pr = a2 + {b2, 1'b0} + c2;
    // Weighted sum of the left column (1, 2, 1).
    wire [10:0] pl = a0 + {b0, 1'b0} + c0;
    // Weighted sum of the bottom row (1, 2, 1).
    wire [10:0] pb = c0 + {c1, 1'b0} + c2;
    // Weighted sum of the top row (1, 2, 1).
    wire [10:0] pt = a0 + {a1, 1'b0} + a2;
    // Absolute horizontal gradient.
    wire [10:0] ax = (pr >= pl) ? (pr - pl) : (pl - pr);
    // Absolute vertical gradient.
    wire [10:0] ay = (pb >= pt) ? (pb - pt) : (pt - pb);
    // Sum of the two gradients.
    wire [11:0] sum = ax + ay;
    // Magnitude clamped to a byte.
    wire [7:0]  mag = (sum > 12'd255) ? 8'd255 : sum[7:0];
    // The window holds a full 3x3 neighbourhood of an inner pixel (not on the picture border).
    wire        inner = (col >= 2) && (row >= 2) && (row <= h_m1);

    // Step machine: latch the pixel, read the line buffer, shift the window and line buffer, then output a byte.
    always @(posedge clk) begin
        // out_valid is a single-clock pulse.
        out_valid <= 1'b0;
        // Reset or restart at the top of a frame.
        if (rst | start) begin
            // Idle.
            st   <= S_IDLE;
            // First column.
            col  <= 0;
            // First line.
            row  <= 16'd0;
            // Outputs are valid only after the lead-in of one line plus one pixel.
            skip <= w_m1 + 16'd2;
        end else begin
            // State dispatch.
            case (st)
                // Wait for a step and latch its pixel.
                S_IDLE: if (step) begin
                    // Keep the pixel.
                    pix <= pix_in;
                    // Go and read the line buffer.
                    st  <= S_READ;
                end
                // Read the two pixels above this column.
                S_READ: begin
                    // Registered read of the line buffer.
                    rd <= lbuf[col];
                    // Next state.
                    st <= S_SHIFT;
                end
                // Update the line buffer and slide the window one column.
                S_SHIFT: begin
                    // Old one-line-up pixel moves to two lines up, the new pixel becomes one line up.
                    lbuf[col] <= {rd[7:0], pix};
                    // Top row slides left and takes the new column.
                    a0 <= a1; a1 <= a2; a2 <= rd[15:8];
                    // Middle row slides left and takes the new column.
                    b0 <= b1; b1 <= b2; b2 <= rd[7:0];
                    // Bottom row slides left and takes the new column.
                    c0 <= c1; c1 <= c2; c2 <= pix;
                    // Next state.
                    st <= S_OUT;
                end
                // Output the filtered byte and advance the position.
                S_OUT: begin
                    // Border pixels are 0, inner pixels get the magnitude.
                    out_data  <= inner ? mag : 8'd0;
                    // Valid once the lead-in is over.
                    out_valid <= (skip == 16'd0);
                    // Count the lead-in down.
                    if (skip != 16'd0) skip <= skip - 16'd1;
                    // Last column: wrap to the next line.
                    if (col == w_m1) begin
                        // First column.
                        col <= 0;
                        // Next line.
                        row <= row + 16'd1;
                    end else col <= col + 1'b1;
                    // Back to idle.
                    st <= S_IDLE;
                end
            endcase
        end
    end

endmodule

`default_nettype wire
