module d_flip_flop_rst(clk,d,rst,q); 
input d; 
input clk; 
input rst; 
output q; 
reg q;
always @ (posedge clk,posedge rst)
begin
 if(rst)
q <=0; 
else
 q <= d;
end
 endmodule