// This is a 1024-byte receive FIFO between the UART receiver and the core: it lets the host send the next block while the core is still working on the current one.
// The core takes a byte only when it asks for one (pop); a byte is never dropped as long as the host keeps at most one request ahead (the host keeps at most two chunks of 448 bytes ahead, so at most about 900 bytes wait here).
`timescale 1 ns / 1 ps

module rx_fifo #(
    // Address width: the FIFO holds 2**AW bytes
    parameter AW = 10
) (
    // System clock
    input  wire       clk,
    // Active-low reset
    input  wire       rst_n,
    // A new byte from the UART receiver
    input  wire       push,
    // The byte to store
    input  wire [7:0] din,
    // The core takes the byte at the head this clock
    input  wire       pop,
    // A byte is available at dout
    output wire       valid,
    // The byte at the head of the FIFO
    output reg  [7:0] dout
);

    // Storage: 2**AW bytes (block RAM)
    reg [7:0] mem [0:(1<<AW)-1];
    // Write pointer (next free slot)
    reg [AW-1:0] wp;
    // Write pointer one clock later: a byte counts as present only after it has been readable for a clock
    reg [AW-1:0] wp_d;
    // Read pointer (the head)
    reg [AW-1:0] rp;
    // Read pointer after this clock's pop
    wire [AW-1:0] rp_n = pop ? rp + 1'b1 : rp;

    // The FIFO holds a readable byte when the delayed write pointer differs from the read pointer
    assign valid = (wp_d != rp);

    // FIFO always block: write on push, keep dout equal to the byte at the (next) read pointer
    always @(posedge clk) begin
        if (!rst_n) begin
            // Reset: empty
            wp   <= {AW{1'b0}};
            wp_d <= {AW{1'b0}};
            rp   <= {AW{1'b0}};
        end else begin
            // Store the incoming byte and advance the write pointer
            if (push) begin
                mem[wp] <= din;
                wp      <= wp + 1'b1;
            end
            // Delay the write pointer by one clock
            wp_d <= wp;
            // Advance the read pointer on a pop
            rp   <= rp_n;
        end
        // Read the byte at the next head position (a registered read, so dout is the head one clock after rp changes)
        dout <= mem[rp_n];
    end

endmodule
