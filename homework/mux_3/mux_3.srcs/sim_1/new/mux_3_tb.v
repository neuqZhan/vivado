`timescale 1ns / 1ps

module mux_3_tb( );

 reg in0;
 reg in1;
 reg in2;
 reg [1:0] sel;
 wire out;//在 Verilog 中，如果信号类型不匹配，例如，模块端口定义为 wire 类型，但在 Testbench 中连接的是 reg 类型，Vivado 会报错。

 initial 
 begin 
 in0 = 1'b0;
 in1 = 1'b0;
 in2 = 1'b0;
 sel = 2'b00;
 end
 // 随机生成输入信号
 always #10 in0 = $random % 2;
 always #10 in1 = $random % 2;
 always #10 in2 = $random % 2;
 always #10 sel = $random % 4;

 initial begin
//显示时间格式
 $timeformat(-9, 0, "ns", 6); // 设置时间格式为 ns，精度为 6
 $monitor("@time %t: in0=%b in1=%b in2=%b sel=%b out=%b",$time,in0,in1,in2,sel,out);
 end

 //------------------------mux_3_inst
 mux_3 mux_3_inst 
 (
 .in0(in0), //input in0   
 .in1(in1), //input in1
 .in2(in2), //input in2
 .sel(sel), //inputsel
 .out(out) //output out
 );
endmodule