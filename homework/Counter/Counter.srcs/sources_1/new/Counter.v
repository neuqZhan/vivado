`timescale 1ns / 1ps

module Counter(clk,out,rst); 
input clk,rst; 
output reg [5:0] out=5'b00000; 
always@(posedge clk,negedge rst) 
begin 
if(!rst) 
out<=6'b0; 
else if(out==6'd19) 
out<=6'b0; 
else 
out<=out+1'b1; 
end 
endmodule 

