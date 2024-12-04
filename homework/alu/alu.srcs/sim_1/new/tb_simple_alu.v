`timescale 1ns / 1ps

module tb_simple_alu(

    );
    reg[31:0] src1,src2;
    reg [11:0] control;
    wire[31:0] result;
    
    simple_alu alu(.alu_control(control),.alu_src1(src1),.alu_src2(src2),
    .alu_result(result));
//    integer i,j=0;
    
    initial begin
        assign src1 = 0;
        assign src2 = 1;
        assign control = 12'b000000000001;
       
    end
       
      always #10 begin    
                assign src1 = $random;
                assign src2 = $random;
//                for (i=0;i<12;i=i+1) begin
//                        if(i==j)
//                            control[i] = 1'b1;
//                        else
//                            control[i] = 1'b0;
//                end
//                j = (j+1) % 12;
    end
endmodule
