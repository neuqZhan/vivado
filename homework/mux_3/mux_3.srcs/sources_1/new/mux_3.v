`timescale 1ns / 1ps

module mux_3
(
    input wire in0,
    input wire in1,
    input wire in2,
    //3个输入端
    input wire [1:0] sel,//选择端
    output reg out//输出端
);
always@(*)
 case(sel)
 2'b00 : out = in0;//由于 always 块中的赋值语句是针对 寄存器类型 进行的，因此必须显式声明 out 为 reg 类型
 2'b01 : out = in1;//out不能为wire类型

 default : out = in2;
endcase

/* 也可使用 assign 语句实现三路选择器（更简洁）
    assign out = (sel == 2'b00) ? in0 :
                 (sel == 2'b01) ? in1 :
                 in2; // 默认选择 in2
*/
endmodule
