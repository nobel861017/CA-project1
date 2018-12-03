module ID_EX
(
    clk_i,
    inst_i,
    inst_o,
    PC_i,
    PC_o,
    RSdata_i,
    RSdata_o,
    RTdata_i,
    RTdata_o,
    imm_i,
    imm_o,
    RDaddr_i,
    RDaddr_o,
    ALUOp_i,
    ALUOp_o,
    ALUSrc_i,
    ALUSrc_o,
    Branch_i,
    Branch_o,
    MemRead_i,
    MemRead_o,
    MemWrite_i,
    MemWrite_o,
    RegWrite_i,
    RegWrite_o,
    MemtoReg_i,
    MemtoReg_o
);

input           clk_i;
input  [31 : 0] inst_i;
input  [31 : 0] inst_o;
input  [31 : 0] PC_i;
output [31 : 0] PC_o;
input  [31 : 0] RSdata_i;
output [31 : 0] RSdata_o;
input  [31 : 0] RTdata_i;
output [31 : 0] RTdata_o;
input  [31 : 0] imm_i;
output [31 : 0] imm_o;
input  [4 : 0]  RDaddr_i;
output [4 : 0]  RDaddr_o;
input  [1 : 0]  ALUOp_i;
output [1 : 0]  ALUOp_o;
input           ALUSrc_i;
output          ALUSrc_o;
input           Branch_i;
output          Branch_o;
input           MemRead_i;
output          MemRead_o;
input           MemWrite_i;
output          MemWrite_o;
input           RegWrite_i;
output          RegWrite_o;
input           MemtoReg_i;
output          MemtoReg_o;

reg    [31 : 0] PC_reg;
reg    [31 : 0] inst_reg;
reg    [31 : 0] RSdata_reg;
reg    [31 : 0] RTdata_reg;
reg    [31 : 0] imm_reg;
reg    [4 : 0]  RDaddr_reg;
reg    [1 : 0]  ALUOp_reg;
reg             ALUSrc_reg;
reg             Branch_reg;
reg             MemRead_reg;
reg             MemWrite_reg;
reg             RegWrite_reg;
reg             MemtoReg_reg;
   
assign PC_o = PC_reg;
assign inst_o = inst_reg;
assign RSdata_o = RSdata_reg;
assign RTdata_o = RTdata_reg;
assign imm_o = imm_reg;
assign RDaddr_o = RDaddr_reg;
assign ALUOp_o = ALUOp_reg;
assign ALUSrc_o = ALUSrc_reg;
assign Branch_o = Branch_reg;
assign MemRead_o = MemRead_reg;
assign MemWrite_o = MemWrite_reg;
assign RegWrite_o = RegWrite_reg;
assign MemtoReg_o = MemtoReg_reg;
 
always@(posedge clk_i)
    begin
        PC_reg <= PC_i;
        inst_reg <= inst_i;
        RSdata_reg <= RSdata_i;
        RTdata_reg <= RTdata_i;
        imm_reg <= imm_i;
        RDaddr_reg <= RDaddr_i;
        ALUOp_reg <= ALUOp_i;
        ALUSrc_reg <= ALUSrc_i;
        Branch_reg <= Branch_i;
        MemRead_reg <= MemRead_i;
        MemWrite_reg <= MemWrite_i;
        RegWrite_reg <= RegWrite_i;
        MemtoReg_reg <= MemtoReg_i;
    end
   
endmodule 
