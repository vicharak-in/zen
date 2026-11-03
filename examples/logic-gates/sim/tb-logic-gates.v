// tb-logic-gates.v - self-checking testbench: all four input combinations against the truth tables

`timescale 1ns/1ps

module tb_logic_gates;

    // Inputs
    reg a = 1'b0, b = 1'b0;
    // Outputs
    wire y_and, y_or, y_not, y_nand, y_nor, y_xor;
    // Error counter
    integer errs = 0;
    // Loop variable
    integer i;

    // This contains the instantiation for the design under test
    logic_gates dut (.a(a), .b(b), .y_and(y_and), .y_or(y_or), .y_not(y_not), .y_nand(y_nand), .y_nor(y_nor), .y_xor(y_xor));

    // This block applies every input combination and compares with the expected values
    initial begin
        for (i = 0; i < 4; i = i + 1) begin
            {a, b} = i[1:0];
            #5;
            if (y_and  !== (a & b))    begin errs = errs + 1; $display("FAIL: AND  %b%b -> %b", a, b, y_and);  end
            if (y_or   !== (a | b))    begin errs = errs + 1; $display("FAIL: OR   %b%b -> %b", a, b, y_or);   end
            if (y_not  !== ~a)         begin errs = errs + 1; $display("FAIL: NOT  %b -> %b",  a,    y_not);  end
            if (y_nand !== ~(a & b))   begin errs = errs + 1; $display("FAIL: NAND %b%b -> %b", a, b, y_nand); end
            if (y_nor  !== ~(a | b))   begin errs = errs + 1; $display("FAIL: NOR  %b%b -> %b", a, b, y_nor);  end
            if (y_xor  !== (a ^ b))    begin errs = errs + 1; $display("FAIL: XOR  %b%b -> %b", a, b, y_xor);  end
        end
        if (errs == 0) $display("ALL PASS"); else $display("SOME FAILED");
        $finish;
    end

endmodule
