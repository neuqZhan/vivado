 `timescale 1ns/1ns 
module test_adder4; 
wire[3:0] sum; 
wire cout; 
reg[3:0] ina,inb; 
reg cin; 
adder4 adder4_1(cout,sum,ina,inb,cin); 
initial begin 
#0 ina = 4'b0001; inb = 4'b1010; cin = 1'b0; 
#5 ina = 4'b0010; inb = 4'b1010; cin = 1'b1; 
#5 ina = 4'b0010; inb = 4'b1110; cin = 1'b0; 
#5 ina = 4'b0011; inb = 4'b1100; cin = 1'b1; 
#5 ina = 4'b0111; inb = 4'b1001; cin = 1'b0; 
#5 ina = 4'b0001; inb = 4'b1100; cin = 1'b1; 
#5 ina = 4'b0011; inb = 4'b1100; cin = 1'b0; 
#5 ina = 4'b0111; inb = 4'b1111; cin = 1'b1; 
#5 $finish; 
end 
initial 
$monitor("At time %t, ina(%b) + inb(%b) + cin(%b) = sum(%b)(%2d),cout(%b)",$time, ina, inb, cin, sum, sum, cout); 
initial 
begin 
$dumpfile("test.vcd"); 
$dumpvars(0,test_adder4); 
end 
endmodule 