// ov7670_writer.v - turns the RP2350 pixel stream into frame buffer write signals
`default_nettype none

module ov7670_writer #(
    parameter ADDR_WIDTH = 13,                 // Address bits
    parameter FRAME_SIZE = 4800                // Pixels per frame
) (
    input  wire                  clk,          // Write-side clock (the RP2350 signals are asynchronous to it)
    input  wire                  rst_n,        // Active-low reset
    input  wire [7:0]            pixel,        // Pixel byte from the RP2350 (stable while we is high)
    input  wire                  we,           // Pixel valid strobe from the RP2350
    input  wire                  vsync_in,     // Frame start from the RP2350 (rising edge starts a frame)
    output reg  [ADDR_WIDTH-1:0] waddr,        // Frame buffer write address
    output reg  [7:0]            wdata,        // Frame buffer write data
    output reg                   we_bram,      // Frame buffer write enable
    output reg                   frame_done,   // One-clock pulse when the last pixel of a frame is written
    output wire                  frame_start   // One-clock pulse when a new frame starts
);

    // Synchronizer chain for the pixel strobe, the top two bits are used for edge detection
    reg [2:0] we_sync;
    // Synchronizer chain for the frame start, the top two bits are used for edge detection
    reg [2:0] vs_sync;
    // Address where the next pixel will be stored
    reg [ADDR_WIDTH-1:0] next_addr;
    // Set once a full frame has been written, further pixels are ignored until the next frame start
    reg full;

    // One-clock pulse for each new pixel strobe
    wire we_pulse = we_sync[1] & ~we_sync[2];
    // One-clock pulse for each new frame start
    wire vs_pulse = vs_sync[1] & ~vs_sync[2];

    // A new frame start is reported to the outside
    assign frame_start = vs_pulse;

    // This block brings the asynchronous RP2350 strobes into the clk domain
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin                          // Clear both chains on reset
            we_sync <= 3'd0;                       // Pixel strobe chain cleared
            vs_sync <= 3'd0;                       // Frame start chain cleared
        end else begin                             // Normal operation
            we_sync <= {we_sync[1:0], we};         // Shift the pixel strobe through the chain
            vs_sync <= {vs_sync[1:0], vsync_in};   // Shift the frame start through the chain
        end
    end

    // This block captures each pixel and drives the frame buffer write port
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin                          // Clear everything on reset
            next_addr  <= {ADDR_WIDTH{1'b0}};      // Next pixel goes to address zero
            full       <= 1'b0;                    // Frame is not full
            waddr      <= {ADDR_WIDTH{1'b0}};      // Write address cleared
            wdata      <= 8'd0;                    // Write data cleared
            we_bram    <= 1'b0;                    // No write in progress
            frame_done <= 1'b0;                    // No frame completed yet
        end else begin                             // Normal operation
            we_bram    <= 1'b0;                    // Default: no write this clock
            frame_done <= 1'b0;                    // Default: no frame-done pulse this clock
            if (vs_pulse) begin                    // A new frame starts, this takes priority over a pixel
                next_addr <= {ADDR_WIDTH{1'b0}};   // Restart at the first address
                full      <= 1'b0;                 // Allow writes again
            end else if (we_pulse && !full) begin  // A new pixel arrives and there is room
                wdata   <= pixel;                  // Capture the pixel byte
                waddr   <= next_addr;              // Write it at the next free address
                we_bram <= 1'b1;                   // Pulse the memory write enable
                if (next_addr == FRAME_SIZE - 1) begin // This was the last pixel of the frame
                    full       <= 1'b1;            // Ignore further pixels until the next frame
                    frame_done <= 1'b1;            // Announce the completed frame
                end else begin                     // More pixels to come
                    next_addr <= next_addr + 1'b1; // Advance to the next address
                end
            end
        end
    end

endmodule

`default_nettype wire
