`timescale 1ns / 1ps


module tb_srbj(
    );
    reg a,b,c; 
    wire d;
    srbj sl(a,b,c,d); 
    initial
    begin
    a=0;b=0;c=0; 
    end
    always #10 {a,b,c}={a,b,c}+1; 
endmodule
