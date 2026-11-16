// flight_engine.v - 3D plane transform engine built on one shared CORDIC core
// One start pulse runs a whole job:
//   1. vectoring: roll  = atan2(ay, az), xm = K*sqrt(ay^2 + az^2)
//   2. vectoring: pitch = atan2(-ax, sqrt(ay^2 + az^2)); y is scaled by K with shift-add so both gains match
//   3. for every vertex of the ROM (pre-scaled by 1/K^3): rotate by yaw (x,z), pitch (y,z) and roll (x,y);
//      the idle axis of each stage is multiplied by K with shift-add, so the whole vector gets the gain K^3
// Results: the measured roll and pitch angles, and NV*3 int16 words on the result RAM write port

`default_nettype none

module flight_engine #(
    parameter NV = 19                         // number of vertices in the ROM
) (
    input  wire               clk,            // fabric clock
    input  wire               start,          // one-clock pulse: run a job
    input  wire signed [15:0] ax,             // accelerometer x (forward)
    input  wire signed [15:0] ay,             // accelerometer y (right)
    input  wire signed [15:0] az,             // accelerometer z (up)
    input  wire        [15:0] yaw,            // yaw angle from the MCU
    input  wire        [15:0] roll_trim,      // roll angle that counts as level
    input  wire        [15:0] pitch_trim,     // pitch angle that counts as level
    output reg                busy,           // high while a job runs
    output reg         [15:0] roll_m,         // measured roll angle
    output reg         [15:0] pitch_m,        // measured pitch angle
    output reg                ram_we,         // result RAM write enable
    output reg         [5:0]  ram_wa,         // result RAM word address
    output reg         [15:0] ram_wd          // result RAM word
);
    // Datapath width of the CORDIC (20 bits = 16 bit values with 3 guard bits and headroom for the gain)
    localparam W = 20;
    // State: waiting for a job
    localparam [3:0] S_IDLE = 4'd0;
    // State: start the roll vectoring
    localparam [3:0] S_V1   = 4'd1;
    // State: wait for the roll vectoring
    localparam [3:0] S_V1W  = 4'd2;
    // State: start the pitch vectoring
    localparam [3:0] S_V2   = 4'd3;
    // State: wait for the pitch vectoring
    localparam [3:0] S_V2W  = 4'd4;
    // State: load one vertex from the ROM
    localparam [3:0] S_LD   = 4'd5;
    // State: start one rotation of the vertex
    localparam [3:0] S_OP   = 4'd6;
    // State: wait for the rotation
    localparam [3:0] S_OPW  = 4'd7;
    // State: write the rotated vertex to the result RAM
    localparam [3:0] S_ST   = 4'd8;

    // Current state
    reg [3:0] st = S_IDLE;
    // Vertex index
    reg [5:0] vi;
    // Load / store sub counter (x, y, z)
    reg [1:0] sub;
    // Rotation number of the vertex: 0 yaw, 1 pitch, 2 roll
    reg [1:0] op;
    // Working vertex coordinates
    reg signed [W-1:0] vx, vy, vz;
    // Magnitude from the roll vectoring (K gain), the x operand of the pitch vectoring
    reg signed [W-1:0] xm;
    // Roll angle after the trim
    reg [15:0] roll_u;
    // Pitch angle after the trim
    reg [15:0] pitch_u;

    // This function multiplies by K = 1.6467602 with shifts and adds: 1 + 1/2 + 1/8 + 1/64 + 1/256 + 1/512
    function signed [W-1:0] mulk(input signed [W-1:0] v);
        // Sum of the shifted copies
        mulk = v + (v >>> 1) + (v >>> 3) + (v >>> 6) + (v >>> 8) + (v >>> 9);
    endfunction

    // ROM address of the current vertex coordinate: 3 * vertex + component
    wire [6:0] rom_a = {1'b0, vi} * 3 + sub;
    // ROM data
    wire signed [15:0] rom_d;

    // CORDIC core control and operands
    reg c_start = 1'b0;
    // Core mode
    reg c_vec = 1'b0;
    // Core x operand
    reg signed [W-1:0] c_x;
    // Core y operand
    reg signed [W-1:0] c_y;
    // Core angle operand
    reg [15:0] c_ang;
    // Core x result
    wire signed [W-1:0] c_xo;
    // Core y result
    wire signed [W-1:0] c_yo;
    // Core angle result
    wire [15:0] c_ango;
    // Core busy flag (not used here)
    wire c_busy;
    // Core done pulse
    wire c_done;

    // Accelerometer values with 3 guard bits
    wire signed [W-1:0] ax3 = {{(W-16){ax[15]}}, ax} <<< 3;
    // y with guard bits
    wire signed [W-1:0] ay3 = {{(W-16){ay[15]}}, ay} <<< 3;
    // z with guard bits
    wire signed [W-1:0] az3 = {{(W-16){az[15]}}, az} <<< 3;

    // This contains the instantiation for the vertex ROM
    vert_rom u_rom (.addr(rom_a), .data(rom_d));

    // This contains the instantiation for the CORDIC core
    cordic_core #(.W(W)) u_core (
        .clk(clk), .start(c_start), .vec(c_vec), .x_in(c_x), .y_in(c_y), .ang_in(c_ang),
        .x_out(c_xo), .y_out(c_yo), .ang_out(c_ango), .busy(c_busy), .done(c_done)
    );

    // This block is the sequencer: two vectoring jobs, then three rotations for every vertex
    always @(posedge clk) begin
        // The core start is a one-clock pulse
        c_start <= 1'b0;
        // The RAM write enable is a one-clock pulse
        ram_we  <= 1'b0;
        // Choose the action by state
        case (st)
            // Wait for a job
            S_IDLE: begin
                // Not busy
                busy <= 1'b0;
                // A job was requested
                if (start) begin
                    // Busy from now on
                    busy <= 1'b1;
                    // Go to the first vectoring
                    st <= S_V1;
                end
            end
            // Roll: atan2(ay, az)
            S_V1: begin
                // Start the core in vectoring mode with x = az, y = ay
                c_start <= 1'b1; c_vec <= 1'b1; c_x <= az3; c_y <= ay3;
                // Wait for the result
                st <= S_V1W;
            end
            // Wait for the roll result
            S_V1W: if (c_done) begin
                // Keep the measured roll and the magnitude
                roll_m <= c_ango; xm <= c_xo;
                // Roll with the trim removed
                roll_u <= c_ango - roll_trim;
                // Next: pitch
                st <= S_V2;
            end
            // Pitch: atan2(-ax, magnitude)
            S_V2: begin
                // Start the core in vectoring mode with x = magnitude, y = -ax * K
                c_start <= 1'b1; c_vec <= 1'b1; c_x <= xm; c_y <= mulk(-ax3);
                // Wait for the result
                st <= S_V2W;
            end
            // Wait for the pitch result
            S_V2W: if (c_done) begin
                // Keep the measured pitch
                pitch_m <= c_ango;
                // Pitch with the trim removed
                pitch_u <= c_ango - pitch_trim;
                // Start with vertex 0, component x
                vi <= 6'd0; sub <= 2'd0;
                // Load it
                st <= S_LD;
            end
            // Load x, y, z of the vertex (the ROM is combinational, one clock per component)
            S_LD: begin
                // Choose the component
                case (sub)
                    // x, with guard bits
                    2'd0: vx <= {{(W-16){rom_d[15]}}, rom_d} <<< 3;
                    // y, with guard bits
                    2'd1: vy <= {{(W-16){rom_d[15]}}, rom_d} <<< 3;
                    // z, with guard bits
                    default: vz <= {{(W-16){rom_d[15]}}, rom_d} <<< 3;
                endcase
                // After z start the rotations with the yaw
                if (sub == 2'd2) begin sub <= 2'd0; op <= 2'd0; st <= S_OP; end
                // Otherwise the next component
                else sub <= sub + 2'd1;
            end
            // Start one rotation
            S_OP: begin
                // Rotation mode
                c_start <= 1'b1; c_vec <= 1'b0;
                // Choose the operands by rotation number
                case (op)
                    // Yaw turns the x-z plane
                    2'd0: begin c_x <= vx; c_y <= vz; c_ang <= yaw;     end
                    // Pitch turns the y-z plane
                    2'd1: begin c_x <= vy; c_y <= vz; c_ang <= pitch_u; end
                    // Roll turns the x-y plane
                    default: begin c_x <= vx; c_y <= vy; c_ang <= roll_u; end
                endcase
                // Wait for the result
                st <= S_OPW;
            end
            // Wait for the rotation and put the results back; the idle axis gets the gain K by shift-add
            S_OPW: if (c_done) begin
                // Choose the register mapping by rotation number
                case (op)
                    // Yaw result in x and z, y scaled
                    2'd0: begin vx <= c_xo; vz <= c_yo; vy <= mulk(vy); end
                    // Pitch result in y and z, x scaled
                    2'd1: begin vy <= c_xo; vz <= c_yo; vx <= mulk(vx); end
                    // Roll result in x and y, z scaled
                    default: begin vx <= c_xo; vy <= c_yo; vz <= mulk(vz); end
                endcase
                // After the roll the vertex is finished
                if (op == 2'd2) begin sub <= 2'd0; st <= S_ST; end
                // Otherwise the next rotation
                else begin op <= op + 2'd1; st <= S_OP; end
            end
            // Write x, y, z (without the guard bits) to the result RAM
            S_ST: begin
                // Write this clock
                ram_we <= 1'b1;
                // RAM word address of the component
                ram_wa <= {1'b0, vi} * 3 + sub;
                // Choose the component
                case (sub)
                    // x
                    2'd0: ram_wd <= vx[W-1:3];
                    // y
                    2'd1: ram_wd <= vy[W-1:3];
                    // z
                    default: ram_wd <= vz[W-1:3];
                endcase
                // After z the vertex is stored
                if (sub == 2'd2) begin
                    // Restart the component counter
                    sub <= 2'd0;
                    // Last vertex: the job is done
                    if (vi == NV - 1) st <= S_IDLE;
                    // Otherwise load the next vertex
                    else begin vi <= vi + 6'd1; st <= S_LD; end
                // Otherwise the next component
                end else sub <= sub + 2'd1;
            end
            // Any other state: go back to idle
            default: st <= S_IDLE;
        endcase
    end
endmodule

`default_nettype wire
