// alu.v - a plain 8-bit ALU. It knows nothing about zink: just operands, an opcode,
// a result and four flags. This is the "your own IP" in the zink_alu example.
//
//   op  operation         result
//   0   ADD               a + b
//   1   SUB               a - b
//   2   AND               a & b
//   3   OR                a | b
//   4   XOR               a ^ b
//   5   NOT              ~a
//   6   SHL1              a << 1
//   7   SHR1              a >> 1
//
// Flags: zero (result == 0), carry (ADD carry out, SUB borrow, bit shifted out by SHL1/SHR1),
//        negative (result bit 7), overflow (signed overflow of ADD / SUB).

`default_nettype none

module alu (
    input  wire [7:0] a,         // operand A
    input  wire [7:0] b,         // operand B (ignored by NOT, SHL1, SHR1)
    input  wire [2:0] op,        // operation select, see table above
    output wire [7:0] result,    // operation result
    output wire       zero,      // 1 when result is 0
    output wire       carry,     // carry out / borrow / shifted-out bit
    output wire       negative,  // copy of result bit 7
    output wire       overflow   // signed overflow (ADD, SUB only)
);

    // 9-bit sum so bit 8 is the carry out of a + b.
    wire [8:0] sum = {1'b0, a} + {1'b0, b};
    // 9-bit difference so bit 8 is the borrow of a - b.
    wire [8:0] dif = {1'b0, a} - {1'b0, b};

    // Result and carry, selected by op (one combinational block).
    reg [8:0] r;
    always @(*) begin
        // Default avoids a latch.
        r = 9'd0;
        case (op)
            // ADD: bit 8 is the carry out.
            3'd0: r = sum;
            // SUB: bit 8 is the borrow.
            3'd1: r = dif;
            // AND: no carry.
            3'd2: r = {1'b0, a & b};
            // OR: no carry.
            3'd3: r = {1'b0, a | b};
            // XOR: no carry.
            3'd4: r = {1'b0, a ^ b};
            // NOT: no carry.
            3'd5: r = {1'b0, ~a};
            // SHL1: carry is the bit shifted out of the top.
            3'd6: r = {a[7], a[6:0], 1'b0};
            // SHR1: carry is the bit shifted out of the bottom.
            3'd7: r = {a[0], 1'b0, a[7:1]};
        endcase
    end

    // Result is the low 8 bits.
    assign result   = r[7:0];
    // Carry is bit 8 of the selected operation.
    assign carry    = r[8];
    // Zero flag.
    assign zero     = (r[7:0] == 8'd0);
    // Negative flag (two's complement sign bit).
    assign negative = r[7];
    // Signed overflow: ADD when operands share a sign the result lacks; SUB when operands differ and result sign differs from a.
    assign overflow = (op == 3'd0) ? (~(a[7] ^ b[7]) & (a[7] ^ r[7])) :
                      (op == 3'd1) ? ( (a[7] ^ b[7]) & (a[7] ^ r[7])) : 1'b0;

endmodule

`default_nettype wire
