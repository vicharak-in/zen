// cordic_core.v - iterative CORDIC, one shift-add step per clock, rotation or vectoring mode
// Angles are 16-bit binary angles (65536 = 360 degrees); 15 iterations; the gain K = 1.6468 stays in the result
//   vec = 0 (rotation):  (x_out, y_out) = K * rotate((x_in, y_in), ang_in), any angle (quadrant pre-rotation inside)
//   vec = 1 (vectoring): x_out = K * sqrt(x^2 + y^2), ang_out = atan2(y_in, x_in)
// Takes 16 clocks from start to done (1 load + 15 iterations); done is a one-clock pulse; results stay until the next start

`default_nettype none

module cordic_core #(
    parameter W = 20                      // datapath width in bits
) (
    input  wire                clk,       // fabric clock
    input  wire                start,     // one-clock pulse: the inputs are sampled in this clock
    input  wire                vec,       // 0 = rotation mode, 1 = vectoring mode
    input  wire signed [W-1:0] x_in,      // x operand
    input  wire signed [W-1:0] y_in,      // y operand
    input  wire        [15:0]  ang_in,    // rotation angle (rotation mode only)
    output wire signed [W-1:0] x_out,     // x result (K * magnitude in vectoring mode)
    output wire signed [W-1:0] y_out,     // y result
    output wire        [15:0]  ang_out,   // angle result (vectoring mode)
    output reg                 busy,      // high while iterating
    output reg                 done       // one-clock pulse when the result is valid
);
`include "cordic_atan.vh"

    // Working x register
    reg signed [W-1:0] x;
    // Working y register
    reg signed [W-1:0] y;
    // Residual angle (rotation) or accumulated angle (vectoring)
    reg signed [15:0]  z;
    // Half-turn offset added to the angle when the vector had to be flipped (vectoring)
    reg        [15:0]  zoff;
    // Mode of the running job
    reg                mode;
    // Iteration counter
    reg        [3:0]   i;

    // Input angle moved by 45 degrees so the quadrant boundaries sit at the diagonals
    wire [15:0] a  = ang_in + 16'h2000;
    // Quadrant of the input angle (number of 90 degree turns done by swapping x and y)
    wire [1:0]  q  = a[15:14];
    // Remaining angle inside the quadrant, between -45 and +45 degrees
    wire signed [15:0] r = {2'b00, a[13:0]} - 16'h2000;

    // x shifted right by the iteration number (arithmetic)
    wire signed [W-1:0] xs = x >>> i;
    // y shifted right by the iteration number (arithmetic)
    wire signed [W-1:0] ys = y >>> i;
    // Direction: y >= 0 in vectoring mode, z >= 0 in rotation mode
    wire pos = mode ? ~y[W-1] : ~z[15];
    // Angle of this iteration, atan(2^-i)
    wire [15:0] at = atan_tab(i);

    // This block loads a job on start and then performs one CORDIC iteration per clock
    always @(posedge clk) begin
        // The done pulse lasts one clock
        done <= 1'b0;
        // A new job starts
        if (start) begin
            // The core is now busy
            busy <= 1'b1;
            // Remember the mode
            mode <= vec;
            // Start with iteration 0
            i    <= 4'd0;
            // Vectoring mode: keep x positive
            if (vec) begin
                // Flip the vector when x is negative
                x    <= x_in[W-1] ? -x_in : x_in;
                // Flip y with it
                y    <= x_in[W-1] ? -y_in : y_in;
                // Remember the half turn that the flip removed
                zoff <= x_in[W-1] ? 16'h8000 : 16'h0000;
                // The accumulated angle starts at zero
                z    <= 16'sd0;
            // Rotation mode: turn by whole quadrants first
            end else begin
                // Choose the quadrant rotation
                case (q)
                    // 0 degrees
                    2'd0: begin x <=  x_in; y <=  y_in; end
                    // 90 degrees
                    2'd1: begin x <= -y_in; y <=  x_in; end
                    // 180 degrees
                    2'd2: begin x <= -x_in; y <= -y_in; end
                    // 270 degrees
                    default: begin x <= y_in; y <= -x_in; end
                endcase
                // No half-turn offset in rotation mode
                zoff <= 16'h0000;
                // The residual angle to rotate by
                z    <= r;
            end
        // A job is running
        end else if (busy) begin
            // Vectoring: drive y to zero and accumulate the angle
            if (mode) begin
                // New x
                x <= pos ? x + ys : x - ys;
                // New y
                y <= pos ? y - xs : y + xs;
                // New accumulated angle
                z <= pos ? z + $signed(at) : z - $signed(at);
            // Rotation: drive the residual angle to zero
            end else begin
                // New x
                x <= pos ? x - ys : x + ys;
                // New y
                y <= pos ? y + xs : y - xs;
                // New residual angle
                z <= pos ? z - $signed(at) : z + $signed(at);
            end
            // Next iteration
            i <= i + 4'd1;
            // After iteration 14 the job is finished
            if (i == 4'd14) begin
                // Stop iterating
                busy <= 1'b0;
                // Tell the user the result is valid
                done <= 1'b1;
            end
        end
    end

    // The x result is the working register
    assign x_out   = x;
    // The y result is the working register
    assign y_out   = y;
    // The angle result includes the half-turn offset
    assign ang_out = z + zoff;

    // Power-up values of the status flags
    initial begin busy = 0; done = 0; end
endmodule

`default_nettype wire
