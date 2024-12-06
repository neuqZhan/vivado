`timescale 1ns / 1ps


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
    
    assign op_add = alu_control[0];//加法操作
    assign op_sub = alu_control[1];//减法操作
    assign op_slt = alu_control[2];//有符号比较，小于置位
    assign op_sltu = alu_control[3];//无符号比较，小于置位
    assign op_and = alu_control[4];//按位与
    assign op_or  = alu_control[5];//按位或非
    assign op_xor = alu_control[6];//按位或
    assign op_nor = alu_control[7];//按位异或
    assign op_sll = alu_control[8];//逻辑左移
    assign op_srl = alu_control[9];//逻辑右移
    assign op_sra = alu_control[10];//算术右移
    assign op_lui = alu_control[11];//高位加载
    
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
/*
    1. $signed(alu_src2)
$signed 是 Verilog 的一个系统任务，用于将输入信号解释为有符号数。
如果 alu_src2 的最高位（第 31 位）是 1，则表示这是一个负数（使用二进制补码表示法）。
如果 alu_src2 的最高位是 0，则表示这是一个非负数。
将 alu_src2 转换为有符号数后，右移操作会根据符号位进行填充。
2. >>>
>>> 表示 算术右移（Arithmetic Right Shift）。
算术右移与逻辑右移的主要区别在于填充位：
逻辑右移（>>）：左侧填充 0。
算术右移（>>>）：左侧填充符号位（即原数的最高有效位）。
如果数是正数（符号位为 0），左侧填充 0。
如果数是负数（符号位为 1），左侧填充 1。
这种行为可以保持符号位的一致性，从而确保算术右移操作与实际除法运算的行为一致。
3. alu_src1[4:0]
alu_src1[4:0] 指定右移的位数，与逻辑右移（SRL）相同，仅用低 5 位来表示移位量（最大为 31）。
工作原理
假设 alu_src2 是一个 32 位带符号数：

如果 alu_src2 = 32'b10000000_00000000_00000000_00001000（负数 -2147483640），并且 alu_src1[4:0] = 5'd2，则：

转换为有符号数后，右移 2 位。
算术右移后：
复制代码
11100000_00000000_00000000_00000010
左侧填充 1，保持符号一致。
结果为负数，数值为 -536870910。
如果 alu_src2 = 32'b00000000_00000000_00000000_00001000（正数 8），并且 alu_src1[4:0] = 5'd2，则：

转换为有符号数后，右移 2 位。
算术右移后：
复制代码
00000000_00000000_00000000_00000010
左侧填充 0。
结果为正数，数值为 2。
与逻辑右移（SRL）的区别
逻辑右移（>>）：

无论正数还是负数，左侧始终填充 0。
通常用于无符号数或单纯的位移操作。
算术右移（>>>）：

保持符号位不变，左侧填充符号位。
用于处理有符号数的右移，通常用于实现除法、数据对齐等。
*/
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
