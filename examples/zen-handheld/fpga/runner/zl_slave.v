// zl_slave.v - Zen Link bus slave (FPGA side of the RP2350 <-> Trion link).
// Decodes link frames from the RP2350 into a simple CPU-style register bus.
// Everything runs in the FPGA 'clk' domain: the link CLK and CS_N are treated as
// ordinary data inputs, synchronised and edge-detected (no logic is clocked by
// link CLK, so there is no burst-clock CDC deadlock).
//
// Frame (CS_N low for the whole frame, 8 data bits per link-clock rising edge):
//   byte 0 : CMD   bit7 = 1 read / 0 write, bits[6:0] = (number of bytes - 1)
//   byte 1 : ADDR  address [15:8]
//   byte 2 : ADDR  address [7:0]
//   write  : one data byte per rising edge, from edge 4 on
//   read   : one turnaround rising edge, then one data byte per cycle,
//            driven by this module after each falling edge.
// Registers are 8 bits wide. Burst: the address auto-increments after every byte.

module zl_slave (
    input  wire        clk,         // FPGA system clock (all logic is in this domain)
    input  wire        rst_n,       // active-low synchronous reset (tie high if unused)
    input  wire        link_clk_in, // link CLK pin from the RP2350 (idle low)
    input  wire        link_csn_in, // link CS_N pin from the RP2350 (low = frame active)
    input  wire [7:0]  link_d_in,   // link data pins, input side of the {in,out,oe} triplet
    output reg  [7:0]  link_d_out,  // link data pins, output side of the triplet
    output reg         link_d_oe,   // link data pins, output enable (1 = FPGA drives)
    output wire [15:0] cpu_addr,    // address of the current byte
    output reg         cpu_wr,      // one-clk write strobe, cpu_addr and cpu_wdata valid
    output wire [7:0]  cpu_wdata,   // write data for the current byte
    output reg         cpu_rd,      // one-clk read strobe, cpu_rdata must be valid in this clk
    input  wire [7:0]  cpu_rdata    // read data for cpu_addr, sampled while cpu_rd is high
);

    // Phase encodings of the frame state machine.
    localparam [2:0] PH_CMD   = 3'd0; // waiting for the command byte
    localparam [2:0] PH_AH    = 3'd1; // waiting for address high byte
    localparam [2:0] PH_AL    = 3'd2; // waiting for address low byte
    localparam [2:0] PH_WD    = 3'd3; // receiving write data bytes
    localparam [2:0] PH_TURN  = 3'd4; // read turnaround clock (bus owned by nobody)
    localparam [2:0] PH_RD    = 3'd5; // driving read data bytes
    localparam [2:0] PH_RDEND = 3'd6; // last byte sent, release the bus at next fall
    localparam [2:0] PH_IDLE  = 3'd7; // frame complete, ignore everything until CS_N high

    // Three-stage synchroniser for the link CLK (stage 2 = aligned, stage 3 = delayed).
    reg [2:0] clk_sy;
    // Three-stage synchroniser for CS_N.
    reg [2:0] csn_sy;
    // First stage of the data synchroniser.
    reg [7:0] d_sy1;
    // Second stage of the data synchroniser, aligned with clk_sy[1].
    reg [7:0] d_sy2;

    // Synchronised link CLK rising edge pulse (one clk wide).
    wire rise = clk_sy[1] & ~clk_sy[2];
    // Synchronised link CLK falling edge pulse (one clk wide).
    wire fall = ~clk_sy[1] & clk_sy[2];
    // High while CS_N is high (no frame in progress).
    wire csn_idle = csn_sy[1];
    // Data byte as seen at the synchronised rising edge.
    wire [7:0] d = d_sy2;

    // Current phase of the frame.
    reg [2:0] ph;
    // Latched direction of the frame (1 = read).
    reg is_rd;
    // Bytes still to go after the current one (CMD[6:0] counts down to 0).
    reg [6:0] bytes_left;
    // Latched high byte of the address.
    reg [7:0] ah;
    // Address of the current byte.
    reg [15:0] addr_q;
    // Write data register, holds the byte while cpu_wr is high.
    reg [7:0] wsh;
    // Read holding register, loaded from cpu_rdata when cpu_rd is high.
    reg [7:0] rhold;
    // One-clk pulse that starts fetching the byte at addr_q.
    reg kick;

    // Address presented to the register bus.
    assign cpu_addr  = addr_q;
    // Write data presented to the register bus.
    assign cpu_wdata = wsh;

    // Synchronisers: bring the three asynchronous link inputs into the clk domain.
    // Each line below is one register stage; they are free-running (no reset needed).
    always @(posedge clk) begin
        // Shift the link CLK pin into the 3-stage synchroniser.
        clk_sy <= {clk_sy[1:0], link_clk_in};
        // Shift the CS_N pin into the 3-stage synchroniser.
        csn_sy <= {csn_sy[1:0], link_csn_in};
        // Capture the data pins (first stage).
        d_sy1  <= link_d_in;
        // Capture the data pins (second stage, aligned with clk_sy[1]).
        d_sy2  <= d_sy1;
    end

    // Frame state machine: runs on the synchronised link edges, one clk wide events.
    // Rising edges consume command/address/write bytes, falling edges drive read bytes.
    // CS_N high (or reset) puts everything back to a clean idle state, so an
    // aborted frame can never commit a partial write.
    always @(posedge clk) begin
        // Default: write strobe is a single-clk pulse.
        cpu_wr <= 1'b0;
        // Default: fetch kick is a single-clk pulse.
        kick   <= 1'b0;
        // Read strobe follows the kick by one clk so cpu_addr is stable first.
        cpu_rd <= kick;
        // Capture the read data in the same clk cpu_rd is high.
        if (cpu_rd) rhold <= cpu_rdata;
        // Advance the address after each committed write byte.
        if (cpu_wr) addr_q <= addr_q + 16'd1;

        // Reset / idle branch: frame abort, release the bus, clear pulses.
        if (!rst_n || csn_idle) begin
            // Return to waiting for the command byte.
            ph        <= PH_CMD;
            // Stop driving the data pins immediately.
            link_d_oe <= 1'b0;
            // Cancel any pending fetch.
            kick      <= 1'b0;
            // Cancel any read strobe.
            cpu_rd    <= 1'b0;
            // Cancel any write strobe (a partial frame never commits).
            cpu_wr    <= 1'b0;
        end else begin
            // Rising link edge: sample one byte from the master.
            if (rise) begin
                // Select the action by phase.
                case (ph)
                    // Command byte: direction and byte count.
                    PH_CMD: begin
                        // Remember whether this is a read.
                        is_rd      <= d[7];
                        // Remember the byte count minus one.
                        bytes_left <= d[6:0];
                        // Next byte is the address high byte.
                        ph         <= PH_AH;
                    end
                    // Address high byte.
                    PH_AH: begin
                        // Hold it until the low byte arrives.
                        ah <= d;
                        // Next byte is the address low byte.
                        ph <= PH_AL;
                    end
                    // Address low byte: address is now complete.
                    PH_AL: begin
                        // Address is the two bytes received.
                        addr_q <= {ah, d};
                        // Reads start fetching right away, writes start receiving.
                        if (is_rd) begin
                            // Wait one turnaround rising edge before driving data.
                            ph   <= PH_TURN;
                            // Kick off the fetch of the first byte.
                            kick <= 1'b1;
                        end else begin
                            // Receive write data from the next rising edge on.
                            ph <= PH_WD;
                        end
                    end
                    // Write data byte: every byte is a complete register write.
                    PH_WD: begin
                        // Hold the byte for the register bus.
                        wsh    <= d;
                        // Fire the write strobe next clk (wsh holds the byte by then).
                        cpu_wr <= 1'b1;
                        // Last byte of the frame: ignore further clocks.
                        if (bytes_left == 7'd0) ph <= PH_IDLE;
                        // Otherwise one byte fewer to go.
                        else bytes_left <= bytes_left - 7'd1;
                    end
                    // Turnaround rising edge: from now on falling edges drive data.
                    PH_TURN: ph <= PH_RD;
                    // Other phases ignore rising edges.
                    default: ;
                endcase
            end
            // Falling link edge: drive the next read byte, or release the bus.
            if (fall) begin
                // Select the action by phase.
                case (ph)
                    // Drive one read byte.
                    PH_RD: begin
                        // Present the fetched byte on the data pins.
                        link_d_out <= rhold;
                        // Take over the data bus.
                        link_d_oe  <= 1'b1;
                        // Last byte of the frame: release the bus at the next falling edge.
                        if (bytes_left == 7'd0) ph <= PH_RDEND;
                        else begin
                            // One byte fewer to go.
                            bytes_left <= bytes_left - 7'd1;
                            // Move to the next address.
                            addr_q     <= addr_q + 16'd1;
                            // Start fetching the next byte (a full link period is available).
                            kick       <= 1'b1;
                        end
                    end
                    // Last byte was sampled by the master, let go of the bus.
                    PH_RDEND: begin
                        // Stop driving the data pins.
                        link_d_oe <= 1'b0;
                        // Frame is finished.
                        ph        <= PH_IDLE;
                    end
                    // Other phases ignore falling edges.
                    default: ;
                endcase
            end
        end
    end

endmodule
