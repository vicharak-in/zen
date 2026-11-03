// zl-afifo.v - small dual-clock FIFO (gray-coded pointers) used to carry bytes between the Zen Link clock and a slower core clock.
// The read data is the oldest entry and is visible without a read request (first-word-fall-through, registered output); rd pops it. Writing when full or reading when empty is ignored.
// rcount (read side) and wspace (write side) are conservative: they lag the other side by two clocks of their own domain.

module zl_afifo #(
    parameter AW = 6,   // Address bits: the FIFO holds 2**AW bytes
    parameter DW = 8    // Data width
) (
    input  wire          wclk,     // Write-side clock
    input  wire          wrst_n,   // Write-side reset, active low
    input  wire          wr,       // Push wdata (ignored when full)
    input  wire [DW-1:0] wdata,    // Data to push
    output wire          full,     // High when no entry is free
    output wire [AW:0]   wspace,   // Free entries seen from the write side
    input  wire          rclk,     // Read-side clock
    input  wire          rrst_n,   // Read-side reset, active low
    input  wire          rd,       // Pop the oldest entry (ignored when empty)
    output wire [DW-1:0] rdata,    // Oldest entry (valid while empty is low)
    output wire          empty,    // High when there is nothing to read
    output wire [AW:0]   rcount    // Entries available seen from the read side
);

    // Number of entries
    localparam DEPTH = 1 << AW;

    // Storage
    reg [DW-1:0] mem [0:DEPTH-1];
    // Binary write pointer (write clock domain)
    reg [AW:0] wbin = {(AW+1){1'b0}};
    // Binary read pointer (read clock domain)
    reg [AW:0] rbin = {(AW+1){1'b0}};
    // Gray copy of the write pointer, registered in the write domain
    reg [AW:0] wgray = {(AW+1){1'b0}};
    // Gray copy of the read pointer, registered in the read domain
    reg [AW:0] rgray = {(AW+1){1'b0}};
    // Write pointer synchronised into the read domain (two flops)
    reg [AW:0] wg_s1 = {(AW+1){1'b0}}, wg_s2 = {(AW+1){1'b0}};
    // Read pointer synchronised into the write domain (two flops)
    reg [AW:0] rg_s1 = {(AW+1){1'b0}}, rg_s2 = {(AW+1){1'b0}};

    // Converts a gray code value to binary
    function [AW:0] g2b(input [AW:0] g);
        integer i;
        begin
            g2b[AW] = g[AW];
            for (i = AW - 1; i >= 0; i = i - 1) g2b[i] = g2b[i+1] ^ g[i];
        end
    endfunction

    // Read pointer in binary as seen from the write side
    wire [AW:0] rbin_w = g2b(rg_s2);
    // Write pointer in binary as seen from the read side
    wire [AW:0] wbin_r = g2b(wg_s2);
    // Entries in use seen from the write side
    wire [AW:0] used_w = wbin - rbin_w;
    // Entries in use seen from the read side
    wire [AW:0] used_r = wbin_r - rbin;

    // Full when every entry is in use
    assign full   = (used_w == DEPTH[AW:0]);
    // Free entries
    assign wspace = DEPTH[AW:0] - used_w;
    // Empty when nothing is in use
    assign empty  = (used_r == {(AW+1){1'b0}});
    // Entries available to read
    assign rcount = used_r;
    // Read pointer after this clock edge (moves on when the oldest entry is popped)
    wire [AW:0] rbin_n = (rd && !empty) ? rbin + 1'b1 : rbin;
    // Registered read port: always holds the entry at the read pointer (a plain synchronous read, so large FIFOs map to block RAM)
    reg [DW-1:0] rdata_q;
    // Oldest entry
    assign rdata  = rdata_q;

    // Write side: store the byte, advance the pointer and register its gray code, and synchronise the read pointer
    always @(posedge wclk) begin
        // Synchronise the read pointer into this domain
        rg_s1 <= rgray;
        rg_s2 <= rg_s1;
        if (!wrst_n) begin
            // Reset clears the pointer
            wbin  <= {(AW+1){1'b0}};
            wgray <= {(AW+1){1'b0}};
        end else if (wr && !full) begin
            // Store the byte
            mem[wbin[AW-1:0]] <= wdata;
            // Advance the pointer
            wbin  <= wbin + 1'b1;
            // Register its gray code
            wgray <= (wbin + 1'b1) ^ ((wbin + 1'b1) >> 1);
        end
    end

    // Read side: advance the pointer on a pop, refresh the registered read data and synchronise the write pointer
    always @(posedge rclk) begin
        // Read the entry the pointer will point at after this edge (a fresh write reaches it before empty goes low)
        rdata_q <= mem[rbin_n[AW-1:0]];
        // Synchronise the write pointer into this domain
        wg_s1 <= wgray;
        wg_s2 <= wg_s1;
        if (!rrst_n) begin
            // Reset clears the pointer
            rbin  <= {(AW+1){1'b0}};
            rgray <= {(AW+1){1'b0}};
        end else if (rd && !empty) begin
            // Advance the pointer
            rbin  <= rbin + 1'b1;
            // Register its gray code
            rgray <= (rbin + 1'b1) ^ ((rbin + 1'b1) >> 1);
        end
    end

endmodule
