// byte-fifo.v - 512 byte FIFO in block RAM. A read request returns the byte one clock later (rd_valid).

module byte_fifo (
    input  wire       clk,       // Clock
    input  wire       rst,       // Synchronous reset, active high
    input  wire       clr,       // One clock pulse: empty the FIFO and clear the overflow flag
    input  wire       wr_en,     // One clock pulse: store wr_data (dropped and flagged when full)
    input  wire [7:0] wr_data,   // Byte to store
    input  wire       rd_en,     // One clock pulse: read the oldest byte (only when not empty)
    output reg  [7:0] rd_data,   // Byte that was read, valid when rd_valid is high
    output reg        rd_valid,  // One clock pulse, one clock after rd_en
    output wire       empty,     // High when there is nothing to read
    output reg        overflow   // Sticky: a byte was dropped because the FIFO was full
);

    // Storage array (maps to block RAM)
    reg [7:0] mem [0:511];
    // Write pointer
    reg [8:0] wp;
    // Read pointer
    reg [8:0] rp;
    // Number of bytes stored (0..512)
    reg [9:0] count;

    // Empty flag
    assign empty = (count == 10'd0);
    // Full flag
    wire full = (count == 10'd512);

    // This block holds the RAM: write port and registered read port
    always @(posedge clk) begin
        if (wr_en && !full) mem[wp] <= wr_data; // Store the byte
        rd_data <= mem[rp];                     // Read the byte at the read pointer
    end

    // This block keeps the pointers, the fill count and the flags
    always @(posedge clk) begin
        rd_valid <= rd_en;                                      // The data is valid one clock after the request
        if (rst || clr) begin
            wp       <= 9'd0;                                   // Empty
            rp       <= 9'd0;                                   // Empty
            count    <= 10'd0;                                  // Empty
            rd_valid <= 1'b0;                                   // Drop any pending read
            if (rst) overflow <= 1'b0;                          // A reset clears the flag
            else overflow <= 1'b0;                              // So does a clear
        end else begin
            if (wr_en && full) overflow <= 1'b1;                // Remember that a byte was lost
            if (wr_en && !full) wp <= wp + 9'd1;                // Advance the write pointer
            if (rd_en && !empty) rp <= rp + 9'd1;               // Advance the read pointer
            case ({wr_en && !full, rd_en && !empty})
                2'b10:   count <= count + 10'd1;                // One more byte stored
                2'b01:   count <= count - 10'd1;                // One byte less stored
                default: count <= count;                        // No change or both at once
            endcase
        end
    end

endmodule
