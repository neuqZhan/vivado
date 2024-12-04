`timescale 1ns / 1ps

module Counter_tb( ); 
reg clk,rst; 
wire [5:0] out; 
initial 
begin 
rst=1; 
clk=0; 
#50 rst=0; 
#30 rst=1; 
end 
always #1 clk=~clk; 
Counter Counter_test(.clk(clk),.rst(rst),.out(out)); 
endmodule