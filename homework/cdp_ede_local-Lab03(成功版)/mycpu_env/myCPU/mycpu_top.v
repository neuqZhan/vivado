module mycpu_top(
    input  wire        clk,//时钟信号
    input  wire        resetn,//复位信号
    // inst sram interface
    output wire        inst_sram_we,//输出指令存储器的使能
    output wire [31:0] inst_sram_addr,//（输出）存入指令存储器的地址
    output wire [31:0] inst_sram_wdata,//（输出）存入指令存储器的指令
    input  wire [31:0] inst_sram_rdata,//从指令存储器读取的指令
    // data sram interface
    output wire        data_sram_we,//输出数据存储器的使能
    output wire [31:0] data_sram_addr,//（输出）存入数据存储器的地址
    output wire [31:0] data_sram_wdata,//（输出）存入数据存储器的指令
    input  wire [31:0] data_sram_rdata,//从数据存储器读取的指令
    // trace debug interface
    output wire [31:0] debug_wb_pc,//输出pc
    output wire [ 3:0] debug_wb_rf_we,//输出寄存器的使能
    output wire [ 4:0] debug_wb_rf_wnum,//输出寄存器写入的地址
    output wire [31:0] debug_wb_rf_wdata//输出寄存器写入的数据
);
reg         reset;//复位
always @(posedge clk) reset <= ~resetn; //上升沿时，复位信号变化一次
//添加一处
// reg         valid;
// always @(posedge clk) begin
//     if (reset) begin
//         valid <= 1'b0;
//     end
//     else begin
//         valid <= 1'b1;
//     end
// end
//
wire [31:0] seq_pc;//
wire [31:0] nextpc;//npc
wire        br_taken;//跳转条件
wire [31:0] br_target;//跳转目标
wire [31:0] inst;//指令码
reg  [31:0] pc;//程序计数器

wire [11:0] alu_op;//alu操作码数组，用于决定alu的操作
wire        load_op;//加载操作，但是好像没用到
wire        src1_is_pc;//判断寄存器存入数据1是不是P-C的条件
wire        src2_is_imm;//判断寄存器存入数据2是不是I-M-M的条件
wire        res_from_mem;//判断最终结果是不是来自M-E-M的条件
wire        dst_is_r1;//根据    来判断存入位置是否为1
wire        gr_we;//根据是否跳转为使能赋值，跳转则为0，不跳转为1
wire        mem_we;//数据存储器的使能
wire        src_reg_is_rd;//判断寄存器地址2是不是R-D的条件
wire [4: 0] dest;//寄存器存入数据的位置
wire [31:0] rj_value;
wire [31:0] rkd_value;
wire [31:0] imm;
wire [31:0] br_offs;
wire [31:0] jirl_offs;

wire [ 5:0] op_31_26;
wire [ 3:0] op_25_22;
wire [ 1:0] op_21_20;
wire [ 4:0] op_19_15;
wire [ 4:0] rd;
wire [ 4:0] rj;
wire [ 4:0] rk;
wire [11:0] i12;
wire [19:0] i20;
wire [15:0] i16;
wire [25:0] i26;

wire [63:0] op_31_26_d;
wire [15:0] op_25_22_d;
wire [ 3:0] op_21_20_d;
wire [31:0] op_19_15_d;

wire        inst_add_w;
wire        inst_sub_w;
wire        inst_slt;
wire        inst_sltu;
wire        inst_nor;
wire        inst_and;
wire        inst_or;
wire        inst_xor;
wire        inst_slli_w;
wire        inst_srli_w;
wire        inst_srai_w;
wire        inst_addi_w;//立即数加法，将寄存器与立即数相加
wire        inst_ld_w;//加载(l-o-a-d)指令，从内存中读取数据。指令表中为L-B指令
wire        inst_st_w;//存储(S-T-O-R-E)指令，将数据写入内存。指令表中为S-B指令
wire        inst_jirl;//在M-I-P-S指令集中为J-A-L-R(J-U-M-P R-E-G-I-S-T-E-R A-N-D L-I-N-K)指令，意为为寄存器跳转。跳转目标为寄存器 rs 中的值(P-C=寄存器【rs】)。同时将该分支对应延迟槽指令之后的指令的 P-C 值保存至寄存器rd中（寄存器【rd】=P-C +8）。
wire        inst_b;//这里是 B-R-A-N-C-H的缩写，在M-I-P-S指令集中为J指令，意为为条件跳转，公式为 P-C=P-C(31-28)+立即数（26位）+00（即左移两位）。
wire        inst_bl;//这里是 B-R-A-N-C-H A-N-D L-I-N-K的缩写，在M-I-P-S指令集中为J-A-L（可以记作 J-U-P-M A-N-D L-I-N-K）指令，意为为链接跳转，公式为 P-C=P-C(31-28)+立即数（26位）+00（即左移两位）并且31号寄存器=P-C +8
wire        inst_beq;//分支跳转指令,两值相等则转移,符号扩展（立即数左移两位的结果）
wire        inst_bne;//分支跳转指令,两值不相等则转移,符号扩展（立即数左移两位的结果），与beq操作相同，仅是判断条件不同

wire        need_ui5;
wire        need_si12;//按需符号扩展（12位数版）
wire        need_si16;//按需符号扩展（16位数版）
wire        need_si20;//按需符号扩展（20位数版）
wire        need_si26;//按需符号扩展（26位数版）
wire        src2_is_4;

wire [ 4:0] rf_raddr1;
wire [31:0] rf_rdata1;
wire [ 4:0] rf_raddr2;
wire [31:0] rf_rdata2;
wire        rf_we   ;//寄存器的使能
wire [ 4:0] rf_waddr;
wire [31:0] rf_wdata;

wire [31:0] alu_src1   ;
wire [31:0] alu_src2   ;
wire [31:0] alu_result ;
//修改一处
wire [31:0] mem_result;
wire [31:0] final_result;   //原来的  wire [31:0] ms_final_result;


assign seq_pc   = pc + 3'h4;//原来为assign seq_pc       = fs_pc + 3'h4;
assign nextpc   = br_taken ? br_target : seq_pc;
//修改一处
always @(posedge clk) begin
    if (reset) begin
        pc <= 32'h1bfffffc;  //原来pc <= 32'h1c000000;
    end
    else begin
        pc <= nextpc;
    end
end

assign inst_sram_we    = 1'b0;
assign inst_sram_addr  = pc;
assign inst_sram_wdata = 32'b0;
assign inst            = inst_sram_rdata;//从指令存储器中读取指令码

assign op_31_26  = inst[31:26];//31-26操作码6位
assign op_25_22  = inst[25:22];//25-22操作码4位
assign op_21_20  = inst[21:20];//21-20操作码2位
assign op_19_15  = inst[19:15];//19-15操作码5位

assign rd   = inst[ 4: 0];//4-0指令码5位
assign rj   = inst[ 9: 5];//9-5指令码5位
assign rk   = inst[14:10];//14-10指令码5位

assign i12  = inst[21:10];//21-10指令码12位
assign i20  = inst[24: 5];//24-5指令码20位
assign i16  = inst[25:10];//25-10指令码16位
assign i26  = {inst[ 9: 0], inst[25:10]};//0-9和25-10指令码26位

decoder_6_64 u_dec0(.in(op_31_26 ), .out(op_31_26_d ));//将31-26六位操作码编译成六十四位码
decoder_4_16 u_dec1(.in(op_25_22 ), .out(op_25_22_d ));//将25-22四位操作码编译成16位码
decoder_2_4  u_dec2(.in(op_21_20 ), .out(op_21_20_d ));//将20-21两位操作码编译成四位码
decoder_5_32 u_dec3(.in(op_19_15 ), .out(op_19_15_d ));//将15-19五位操作码编译成32位码

assign inst_add_w  = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h00];
assign inst_sub_w  = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h02];
assign inst_slt    = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h04];
assign inst_sltu   = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h05];
assign inst_nor    = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h08];
assign inst_and    = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h09];
assign inst_or     = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h0a];
assign inst_xor    = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h0b];
assign inst_slli_w = op_31_26_d[6'h00] & op_25_22_d[4'h1] & op_21_20_d[2'h0] & op_19_15_d[5'h01];
assign inst_srli_w = op_31_26_d[6'h00] & op_25_22_d[4'h1] & op_21_20_d[2'h0] & op_19_15_d[5'h09];
assign inst_srai_w = op_31_26_d[6'h00] & op_25_22_d[4'h1] & op_21_20_d[2'h0] & op_19_15_d[5'h11];
assign inst_addi_w = op_31_26_d[6'h00] & op_25_22_d[4'ha];
assign inst_ld_w   = op_31_26_d[6'h0a] & op_25_22_d[4'h2];
assign inst_st_w   = op_31_26_d[6'h0a] & op_25_22_d[4'h6];
assign inst_jirl   = op_31_26_d[6'h13];//在M-I-P-S指令集中为J-A-L-R(J-U-M-P R-E-G-I-S-T-E-R A-N-D L-I-N-K)指令，意为为寄存器跳转。跳转目标为寄存器 rs 中的值(P-C=寄存器【rs】)。同时将该分支对应延迟槽指令之后的指令的 P-C 值保存至寄存器rd中（寄存器【rd】=P-C +8）。
assign inst_b      = op_31_26_d[6'h14];//这里是 B-R-A-N-C-H的缩写，在M-I-P-S指令集中为J指令，意为为条件跳转，公式为 P-C=P-C(31-28)+立即数（26位）+00（即左移两位）
assign inst_bl     = op_31_26_d[6'h15];//这里是 B-R-A-N-C-H A-N-D L-I-N-K的缩写，在M-I-P-S指令集中为J-A-L（可以记作 J-U-P-M A-N-D L-I-N-K）指令，意为为链接跳转，公式为 P-C=P-C(31-28)+立即数（26位）+00（即左移两位）并且31号寄存器=P-C +8
assign inst_beq    = op_31_26_d[6'h16];//指令31-26位为000100为跳转指令
assign inst_bne    = op_31_26_d[6'h17];//指令31-26位为000101为跳转指令
assign inst_lu12i_w= op_31_26_d[6'h05] & ~inst[25];

assign alu_op[ 0] = inst_add_w | inst_addi_w | inst_ld_w | inst_st_w
                    | inst_jirl | inst_bl;
assign alu_op[ 1] = inst_sub_w;
assign alu_op[ 2] = inst_slt;
assign alu_op[ 3] = inst_sltu;
assign alu_op[ 4] = inst_and;//指定为按位与操作，其他也为相对应的操作
assign alu_op[ 5] = inst_nor;
assign alu_op[ 6] = inst_or;
assign alu_op[ 7] = inst_xor;
assign alu_op[ 8] = inst_slli_w;
assign alu_op[ 9] = inst_srli_w;
assign alu_op[10] = inst_srai_w;
assign alu_op[11] = inst_lu12i_w;

assign need_ui5   =  inst_slli_w | inst_srli_w | inst_srai_w;
assign need_si12  =  inst_addi_w | inst_ld_w | inst_st_w;//
assign need_si16  =  inst_jirl | inst_beq | inst_bne;
assign need_si20  =  inst_lu12i_w;
assign need_si26  =  inst_b | inst_bl;
assign src2_is_4  =  inst_jirl | inst_bl;

//修改一处
//原来的
// assign imm = src2_is_4 ? 32'h4                      :
//              need_si20 ? {i20[19:0], 12'b0}         :   //按需符号扩展 
// /*need_ui5 || need_si12*/{{20{i12[11]}}, i12[11:0]} ;             
assign imm = src2_is_4 ? 32'h4                      :
             need_si20 ? {i20[19:0], 12'b0}         :   //按需符号扩展 
             need_ui5  ?  rk                        :   
/*need_ui5 || need_si12*/{{20{i12[11]}}, i12[11:0]} ;

assign br_offs = need_si26 ? {{ 4{i26[25]}}, i26[25:0], 2'b0} : //判断是26位立即数还是16位立即数来判断是无条件（链接）跳转还是（不）相等跳转
                             {{14{i16[15]}}, i16[15:0], 2'b0} ;//相等跳转与不相等跳转

assign jirl_offs = {{14{i16[15]}}, i16[15:0], 2'b0};//寄存器链接跳转

assign src_reg_is_rd = inst_beq | inst_bne | inst_st_w;

assign src1_is_pc    = inst_jirl | inst_bl;

assign src2_is_imm   = inst_slli_w |
                       inst_srli_w |
                       inst_srai_w |
                       inst_addi_w |
                       inst_ld_w   |
                       inst_st_w   |
                       inst_lu12i_w|
                       inst_jirl   |
                       inst_bl     ;

assign res_from_mem  = inst_ld_w;//根据使用从内存加载操作来为其赋值，如果是则为1，不是则为0
assign dst_is_r1     = inst_bl;//
//修改一处           //原来  assign gr_we         = ~inst_st_w & ~inst_beq & ~inst_bne & ~inst_b & ~inst_bl;
assign gr_we         = ~inst_st_w & ~inst_beq & ~inst_bne & ~inst_b;//不进行跳转操作则为1，进行跳转则为0
assign mem_we        = inst_st_w;//根据是否进行存储操作为数据存储器使能赋值，进行为1，不进行为0
assign dest          = dst_is_r1 ? 5'd1 : rd;

assign rf_raddr1 = rj; 
assign rf_raddr2 = src_reg_is_rd ? rd :rk;
regfile u_regfile(
    .clk    (clk      ),
    .raddr1 (rf_raddr1),
    .rdata1 (rf_rdata1),
    .raddr2 (rf_raddr2),
    .rdata2 (rf_rdata2),
    .we     (rf_we    ),//接入存储器的使能
    .waddr  (rf_waddr ),
    .wdata  (rf_wdata )
    );

assign rj_value  = rf_rdata1;//寄存器值1
assign rkd_value = rf_rdata2;//寄存器值2
//修改添加定义valid
 wire valid =1'b1;
assign rj_eq_rd = (rj_value == rkd_value);//判断值是否相等，即相等跳转和不相等跳转的判断条件
assign br_taken = (   inst_beq  &&  rj_eq_rd//判断是否发生相等跳转
                   || inst_bne  && !rj_eq_rd//判断是否发生不相等跳转
                   || inst_jirl//判断是否发生寄存器链接跳转
                   || inst_bl//判断是否发生无条件链接跳转
                   || inst_b//判断是否发生无条件跳转
                  ) && valid; //原来的) && ds_valid;
//修改了一处
assign br_target = (inst_beq || inst_bne || inst_bl || inst_b) ? (pc + br_offs) : //修改ds_pc为 P-C          //发生前面四种跳转的跳转目标
                                                   /*inst_jirl*/ (rj_value + jirl_offs);//发生寄存器链接跳转的跳转目标

assign alu_src1 = src1_is_pc  ? pc[31:0] : rj_value;
assign alu_src2 = src2_is_imm ? imm : rkd_value;
//修改一处
alu u_alu(
    .alu_op     (alu_op    ),//输入alu操作码，来决定alu执行的操作
    .alu_src1   (alu_src1  ),//输入操作数1    //原来 .alu_src1   (alu_src2  ),
    .alu_src2   (alu_src2  ),//输入操作数2
    .alu_result (alu_result)//输出alu的计算结果
    );
//修改一处
assign data_sram_en    = (res_from_mem || mem_we) && valid;   //原来的assign data_sram_en    = (rfrom_mem || mem_we) && valid;   //data_sram_en` 的使能条件缺失**  - 通常 SRAM 的使能信号 (`data_sram_en`) 应与读/写操作相关联。
assign data_sram_we    = mem_we;//为数据存储器存入使能
assign data_sram_addr  = alu_result;//将alu的运行结果存入数据存储器
assign data_sram_wdata = rkd_value;

assign mem_result   = data_sram_rdata;
assign final_result = res_from_mem ? mem_result : alu_result;//根据条件判断最终结果来自内存还是alu

assign rf_we    = gr_we;//根据是否跳转来为寄存器使能赋值，跳转则为0（即不进行存储），不跳转则为1（即进行存储）
assign rf_waddr = dest;
assign rf_wdata = final_result;//将最终结果写回寄存器

// debug info generate
//修改一处
assign debug_wb_pc       = pc;//将程序计数器存入调试
assign debug_wb_rf_we   = {4{rf_we}}; //原来的assign debug_wb_rf_wen   = {4{rf_we}};   //将寄存器写使能存入调试
assign debug_wb_rf_wnum  = dest;//将寄存器地址存入调试
assign debug_wb_rf_wdata = final_result;//将写入的数据存入调试

endmodule
