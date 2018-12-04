module EX_MEM
(
    clk_i,
    sum_i,
    sum_o,
    ALUResult_i,
    ALUResult_o,
    zero_i,
    zero_o,
    RTdata_i,
    RTdata_o,
    RDaddr_i,
    RDaddr_o,
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
input  [31 : 0] sum_i;
output [31 : 0] sum_o;
input  [31 : 0] ALUResult_i;
output [31 : 0] ALUResult_o;
input           zero_i;
output          zero_o;
input  [31 : 0] RTdata_i;
output [31 : 0] RTdata_o;
input  [4 : 0]  RDaddr_i;
output [4 : 0]  RDaddr_o;
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

reg    [31 : 0] sum_reg;
reg    [31 : 0] ALUResult_reg;
reg             zero_reg;
reg    [31 : 0] RTdata_reg;
reg    [4 : 0]  RDaddr_reg;
reg             Branch_reg;
reg             MemRead_reg;
reg             MemWrite_reg;
reg             RegWrite_reg;
reg             MemtoReg_reg;
   
assign sum_o = sum_reg;
assign ALUResult_o = ALUResult_reg;
assign zero_o = zero_reg;
assign RTdata_o = RTdata_reg;
assign RDaddr_o = RDaddr_reg;
assign Branch_o = Branch_reg;
assign MemRead_o = MemRead_reg;
assign MemWrite_o = MemWrite_reg;
assign RegWrite_o = RegWrite_reg;
assign MemtoReg_o = MemtoReg_reg;
 
always@(posedge clk_i)
    begin
        sum_reg <= sum_i;
        ALUResult_reg <= ALUResult_i;
        zero_reg <= zero_i;
        RTdata_reg <= RTdata_i;
        RDaddr_reg <= RDaddr_i;
        Branch_reg <= Branch_i;
        MemRead_reg <= MemRead_i;
        MemWrite_reg <= MemWrite_i;
        RegWrite_reg <= RegWrite_i;
        MemtoReg_reg <= MemtoReg_i;
    end
   
endmodule 
