`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/09 14:21:05
// Design Name: 
// Module Name: simplelu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module simple_alu(
    input [31:0] alu_control,
    input [31:0] alu_src1,
    input [31:0] alu_src2,
    output [31:0] alu_result
    );
    
    wire op_add;
    wire op_sub;
    wire op_slt;
    wire op_sltu;//
    wire op_and;
    wire op_or;
    wire op_xor;
    wire op_nor;
    wire op_sll;//shift left logic
    wire op_srl;// shift right logic
    wire op_sra;//shift right arithmetic
    wire op_lui;
    
    assign op_add = alu_control[0];
    assign op_sub = alu_control[1];
    assign op_slt = alu_control[2];
    assign op_sltu = alu_control[3];
    assign op_and = alu_control[4];
    assign op_or = alu_control[5];
    assign op_xor = alu_control[6];
    assign op_nor = alu_control[7];
    assign op_sll = alu_control[8];
    assign op_srl = alu_control[9];
    assign op_sra = alu_control[10];
    assign op_lui = alu_control[11];
    
    //result
    wire [31:0] add_sub_result;//add=sub because two's complement
    wire [31:0] slt_result;//set less than
    wire [31:0] sltu_result;//set less than unsigned
    wire [31:0] and_result;
    wire [31:0] or_result;
    wire [31:0] xor_result;
    wire [31:0] nor_result;
    wire [31:0] sll_result;
    wire [31:0] srl_result;
    wire [31:0] sra_result;
    wire [31:0] lui_result;

//how to get result    
    assign and_result = alu_src1 & alu_src2;
    assign or_result = alu_src1 | alu_src2;
    assign xor_result = alu_src1 ^ alu_src2;
    assign nor_result = ~ or_result;
    assign lui_result = {alu_src2[15:0],16'b0};//??can't learn
    
    wire [31:0] adder_a;//
    wire [31:0] adder_b;
    wire            adder_cin;
    wire [31:0] adder_result;
    wire            adder_cout;
    
    assign adder_a = alu_src1;
    assign adder_b =  (op_sub|op_slt|op_sltu)?~alu_src2:alu_src2;
    //judgement op_sub if true then ~alu_src2 else alu_src2              
    //(a+b)'s implement =(a)'s implement + (b)'s implement
    //(a-b)'s implement =(a)'s implement + (-b)'s implement=(a)'s implement + (b)'s implement
    // relation? b's implement and (-b)'s implement
    // if b>0, (-b)'s implement=~(b'simplement)+1
    //if b<0, (-b)'s implement=~(b'simplement)+1
    assign adder_cin = (op_sub|op_slt|op_sltu)? 1'b1:1'b0;
    assign {adder_cout,adder_result}=adder_a+adder_b+adder_cin;
    
    assign add_sub_result =  adder_result;
    assign slt_result[31:1]=31'b0;
    assign slt_result[0]=(alu_src1[31]&~alu_src2[31])
    |(~(alu_src1[31]^alu_src2[31])&adder_result[31]);//***
    //one
    // - and -
    //+ and +
    //judgement with (alu_src1[31]&~alu_src2[31])
    //two
    //+ and - or - and + 
    //judgement with (~(alu_src1[31]^alu_src2[31])&adder_result[31])
    
    assign sltu_result[31:0]=31'b0;
    assign sltu_result[0]=~adder_cout;
    assign sll_result = alu_src2 << alu_src1[4:0];
    assign srl_result =alu_src2 >> alu_src1[4:0];
    assign sra_result = ($signed(alu_src2)) >>> alu_src1[4:0]; //>>> sra
    
    assign alu_result = ({32{op_add|op_sub}}&add_sub_result)
    |    ({32{op_slt}}&slt_result)
    |    ({32{op_sltu}}&sltu_result)
    |    ({32{op_and}}&and_result)
    |    ({32{op_or}}&or_result)
    |    ({32{op_xor}}&xor_result)
    |    ({32{op_nor}}&nor_result)
    |    ({32{op_sll}}&sll_result)
    |    ({32{op_srl}}&srl_result)
    |    ({32{op_sra}}&sra_result)
    |    ({32{op_lui}}&lui_result);
endmodule
