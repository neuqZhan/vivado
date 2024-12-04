`timescale 1ns / 1ns
module d_flip_flop_tb(
 );

    reg clk,d=0; 
    wire q; 
    d_flip_flop u1(.d(d),.clk(clk),.q(q)); 
    initial 
    begin 
    clk = 1; 
    d <= 0; 
    forever 
    begin 
    #60 d <= 1;
    #22 d <= 0; 
    #2 d <= 1; 
    #2 d <= 0; 
    #16 d <= 0;
    end 
    end 
    always #20 clk <= ~clk;
endmodule 

