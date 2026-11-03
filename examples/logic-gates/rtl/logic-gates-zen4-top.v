// logic-gates-zen4-top.v - board top for logic_gates on the Zen 4: buttons are the inputs, the six gate outputs go to header pads.
// Pressing a button makes its input 1 (the buttons are active low). LED 1 shows AND, LED 2 shows XOR. No clock is needed.

module logic_gates_zen4_top (
    input  wire       btn1,    // Button 1, active low: input A
    input  wire       btn2,    // Button 2, active low: input B
    output wire [5:0] gates,   // Header pads: {XOR, NOR, NAND, NOT, OR, AND}, active high
    output wire       led1,    // LED 1, active low: AND
    output wire       led2     // LED 2, active low: XOR
);

    // Gate inputs, 1 = button pressed
    wire a = ~btn1;
    wire b = ~btn2;

    // This contains the instantiation for the six gates
    logic_gates u_gates (.a(a), .b(b), .y_and(gates[0]), .y_or(gates[1]), .y_not(gates[2]), .y_nand(gates[3]), .y_nor(gates[4]), .y_xor(gates[5]));

    // LED 1 sinks current: a low pin lights it
    assign led1 = ~gates[0];
    // LED 2 sinks current: a low pin lights it
    assign led2 = ~gates[5];

endmodule
