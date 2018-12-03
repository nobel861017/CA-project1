module MEM_WB
(
    clk_i,
    mem_i,
    mem_o,
    ALUResult_i,
    ALUResult_o,
    RDaddr_i,
    RDaddr_o,
    RegWrite_i,
    RegWrite_o,
    MemtoReg_i,
    MemtoReg_o
);

input           clk_i;
input  [31 : 0] mem_i;
output [31 : 0] mem_o;
input  [31 : 0] ALUResult_i;
output [31 : 0] ALUResult_o;
input  [31 : 0] RDaddr_i;
output [31 : 0] RDaddr_o;
input           RegWrite_i;
output          RegWrite_o;
input           MemtoReg_i;
output          MemtoReg_o;

reg    [31 : 0] mem_reg;
reg    [31 : 0] ALUResult_reg;
reg    [31 : 0] RDaddr_reg;
reg             RegWrite_reg;
reg             MemtoReg_reg;
   
assign mem_o = mem_reg;
assign ALUResult_o = ALUResult_reg;
assign RDaddr_o = RDaddr_reg;
assign RegWrite_o = RegWrite_reg;
assign MemtoReg_o = MemtoReg_reg;
 
always@(posedge clk_i)
    begin
        mem_reg <= mem_i;
        ALUResult_reg <= ALUResult_i;
        RDaddr_reg <= RDaddr_i;
        RegWrite_reg <= RegWrite_i;
        MemtoReg_reg <= MemtoReg_i;
    end
   
endmodule 
