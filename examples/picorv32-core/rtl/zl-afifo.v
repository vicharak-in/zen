// zl-afifo.v - small dual-clock FIFO (gray-coded pointers) used to carry bytes between the Zen Link clock and a slower core clock.
// The read data is the oldest entry and is visible without a read request (first-word-fall-through, registered output); rd pops it. Writing when full or reading when empty is ignored.
// rcount (read side) and wspace (write side) are conservative: they lag the other side by a few clocks of their own domain, and the FIFO holds 2**AW - 1 bytes.

module zl_afifo #(
    parameter AW = 6,   // Address bits: the FIFO holds 2**AW bytes
    parameter DW = 8,   // Data width
    parameter LITE = 0  // 1 = smaller: rcount and wspace only tell 0 or 1 (flags only), no fill-level arithmetic
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

    // Pointers seen from the other side, converted to binary and registered (they only lag, which is safe)
    reg [AW:0] rbin_w = {(AW+1){1'b0}};
    reg [AW:0] wbin_r = {(AW+1){1'b0}};
    // Entries in use seen from the write side (registered, one clock old)
    reg [AW:0] used_w = {(AW+1){1'b0}};
    // Flags and counts, all registered so the 50 MHz paths stay short
    reg        full_q  = 1'b0;                      // Write side: no entry may be written (one entry is kept spare because the flag lags)
    reg [AW:0] wspace_q = DEPTH[AW:0] - 1'b1;       // Write side: free entries, never more than the true number
    reg        empty_q = 1'b1;                      // Read side: nothing to read
    reg [AW:0] rcount_q = {(AW+1){1'b0}};           // Read side: entries available, never more than the true number

    assign full   = full_q;
    assign wspace = wspace_q;
    assign empty  = empty_q;
    assign rcount = rcount_q;
    // Read pointer after this clock edge (moves on when the oldest entry is popped)
    wire [AW:0] rbin_n = (rd && !empty_q) ? rbin + 1'b1 : rbin;
    // Entries the read side will see after this edge
    wire [AW:0] used_rn = wbin_r - rbin_n;
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
        end else if (wr && !full_q) begin
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
        end else if (rd && !empty_q) begin
            // Advance the pointer
            rbin  <= rbin + 1'b1;
            // Register its gray code
            rgray <= (rbin + 1'b1) ^ ((rbin + 1'b1) >> 1);
        end
    end

    generate
        if (!LITE) begin : g_full
            // Write side: fill level from the registered read pointer, then the flags (full one entry early because the flag lags)
            always @(posedge wclk) begin
                rbin_w <= g2b(rg_s2);
                used_w <= wbin - rbin_w;
                full_q <= (used_w >= DEPTH[AW:0] - 1'b1);
                wspace_q <= (used_w >= DEPTH[AW:0] - 1'b1) ? {(AW+1){1'b0}} : (DEPTH[AW:0] - 1'b1 - used_w);
            end
            // Read side: entries available after this edge, and the empty flag
            always @(posedge rclk) begin
                wbin_r <= g2b(wg_s2);
                rcount_q <= used_rn;
                empty_q  <= (used_rn == {(AW+1){1'b0}});
            end
        end else begin : g_lite
            // Write side: pointer after this edge in gray code, compared with the (lagging) read pointer: full when it is one lap ahead
            wire [AW:0] wbin_n  = wbin + ((wr && !full_q) ? 1'b1 : 1'b0);
            wire [AW:0] wgray_n = wbin_n ^ (wbin_n >> 1);
            always @(posedge wclk) begin
                if (!wrst_n) full_q <= 1'b0;
                else full_q <= (wgray_n == {~rg_s2[AW:AW-1], rg_s2[AW-2:0]});
                wspace_q <= {{AW{1'b0}}, ~full_q};
            end
            // Read side: empty when the pointer after this edge equals the (lagging) write pointer
            wire [AW:0] rgray_n = rbin_n ^ (rbin_n >> 1);
            always @(posedge rclk) begin
                if (!rrst_n) empty_q <= 1'b1;
                else empty_q <= (rgray_n == wg_s2);
                rcount_q <= {{AW{1'b0}}, ~empty_q};
            end
        end
    endgenerate

endmodule
