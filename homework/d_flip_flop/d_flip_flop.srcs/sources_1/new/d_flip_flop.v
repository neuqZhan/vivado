`timescale 1ns / 1ps

module d_flip_flop(d,clk,q); 
    input d; 
    input clk; 
    output q; 
    reg q; 
    always @ (posedge clk)
    begin 
    q <= d;
    end 
endmodule
