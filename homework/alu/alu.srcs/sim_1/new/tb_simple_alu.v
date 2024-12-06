`timescale 1ns / 1ps

module tb_simple_alu(

    );
    reg[31:0] src1,src2;
    reg [11:0] control;
    wire[31:0] result;
    
    simple_alu alu(.alu_control(control),
                   .alu_src1(src1),
                   .alu_src2(src2),
                   .alu_result(result)
                );
    
    initial begin
         src1 = 0;
         src2 = 1;
         control = 12'b0000_0000_0001;//assign语句只能用于驱动wire信号类型，不能用于驱动reg类型，这里不能用assign src = 0 ;
         // 打印初始值
        $display("Initial values: src1 = %d, src2 = %d, control = %b", src1, src2, control);
        
        // 让模拟进行一段时间
        #200;
        
        // 执行多个测试
        $finish;
    end

    parameter size = 12;
    
    reg [4:0] j=0;
    integer i=0;
    always #10 begin    
        
         
                 src1 = $random;
                 src2 = $random;//always语句也不能在always语句中使用，这在 Verilog 中是非法的。assign 应该在顶层模块之外使用，
    //控制信号变化
            
               for (i=0;i<size;i=i+1) begin
                    if(i==j)
                       begin
                           control[i] = 1'b1;
                       end
                    else
                       begin
                            control[i] = 1'b0;
                       end
               end           
               j = (j+1) % 12;// 使 j 循环在 [0, 11] 范围内
    end
endmodule
