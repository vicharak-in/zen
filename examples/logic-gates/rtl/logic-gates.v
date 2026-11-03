// Ported from the Vicharak Shrike examples (GPL-2.0) to the Zen 4 (Trion T4F81); logic unchanged, Renesas pad/enable ports removed.
// logic-gates.v - the six basic gates from the Shrike logic_gates example (AND, OR, NOT, NAND, NOR, XOR), pure combinational

// 2-input AND gate
module and_gate (input wire a, input wire b, output wire y);
    // AND of the inputs
    assign y = a & b;
endmodule

// 2-input OR gate
module or_gate (input wire a, input wire b, output wire y);
    // OR of the inputs
    assign y = a | b;
endmodule

// Single-input NOT gate
module not_gate (input wire a, output wire y);
    // Inverted input
    assign y = ~a;
endmodule

// 2-input NAND gate
module nand_gate (input wire a, input wire b, output wire y);
    // Output of the inner AND
    wire and_output;
    // AND of the inputs
    assign and_output = a & b;
    // Inverted AND
    assign y = ~and_output;
endmodule

// 2-input NOR gate
module nor_gate (input wire a, input wire b, output wire y);
    // Output of the inner OR
    wire or_output;
    // OR of the inputs
    assign or_output = a | b;
    // Inverted OR
    assign y = ~or_output;
endmodule

// 2-input XOR gate
module xor_gate (input wire a, input wire b, output wire y);
    // XOR of the inputs
    assign y = a ^ b;
endmodule

// All six gates side by side on the same two inputs
module logic_gates (
    input  wire a,        // Input A, active high
    input  wire b,        // Input B, active high
    output wire y_and,    // a AND b
    output wire y_or,     // a OR b
    output wire y_not,    // NOT a
    output wire y_nand,   // a NAND b
    output wire y_nor,    // a NOR b
    output wire y_xor     // a XOR b
);
    // This contains the instantiation for the AND gate
    and_gate  u_and  (.a(a), .b(b), .y(y_and));
    // This contains the instantiation for the OR gate
    or_gate   u_or   (.a(a), .b(b), .y(y_or));
    // This contains the instantiation for the NOT gate
    not_gate  u_not  (.a(a), .y(y_not));
    // This contains the instantiation for the NAND gate
    nand_gate u_nand (.a(a), .b(b), .y(y_nand));
    // This contains the instantiation for the NOR gate
    nor_gate  u_nor  (.a(a), .b(b), .y(y_nor));
    // This contains the instantiation for the XOR gate
    xor_gate  u_xor  (.a(a), .b(b), .y(y_xor));
endmodule
