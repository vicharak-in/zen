// This is the stress testbench: runs a random dependent-instruction program and dumps the stored register results so two regfile variants can be diffed
`timescale 1ns/1ps
module tb_stress;
reg clk=0; reg btn1=0; wire led1,led2;
zen_picorv32_top #(.MEM_WORDS(1024),.FIRMWARE("fw.hex")) dut(.clk(clk),.btn1(btn1),.led1(led1),.led2(led2),.uart_tx());
always #10 clk=~clk;
integer i;
initial begin
 repeat(10) @(posedge clk); btn1=1;
 repeat(20000) @(posedge clk);
 $display("led2=%b",led2);
 for(i=448+16;i<448+32;i=i+1) $display("%0d %08x",i,dut.mem[i]);
 for(i=448;i<448+16;i=i+1) $display("%0d %08x",i,dut.mem[i]);
 $finish;
end
endmodule
