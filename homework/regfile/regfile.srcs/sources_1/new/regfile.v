`timescale 1ns / 1ps


module regfile(
  input         clk,
  input  [4:0]  raddr1,
  output [31:0] rdata1,
  input  [4:0]  raddr2,
  output [31:0] rdata2,
  input         we,//寄存器堆写使能
  input  [4:0]  waddr,//寄存器堆写地址
  input  [31:0] wdata//寄存器堆写数据
);


//32个32位寄存器
reg [31:0] rf[31:0]; 
  // 初始化寄存器堆
  integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            rf[i] = 32'b0;  // 默认初始化所有寄存器为 0
        end
    end
    
// WRITE
always @(posedge clk) begin
        if (we) begin
          rf[waddr] <= wdata;//写入数据
      end
end
// READ OUT 1
assign rdata1 = rf[raddr1];
// READ OUT 2
assign rdata2 = rf[raddr2];
endmodule
