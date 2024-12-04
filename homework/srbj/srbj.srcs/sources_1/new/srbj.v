`timescale 1ns / 1ps


module srbj( input a,
 input b,
 input c,
 output d
  );
   assign d=a&b|a&c|b&c;
  
endmodule
