module IF_ID
(
    clk_i,
    PC_i,
    PC_o,
    inst_i,
    inst_o,
);

input           clk_i;
input  [31 : 0] PC_i;
output [31 : 0] PC_o;
input  [31 : 0] inst_i;
output [31 : 0] inst_o;

reg    [31 : 0] PC_reg;
reg    [31 : 0] inst_reg;
   
assign PC_o = PC_reg;
assign inst_o = inst_reg;
 
always@(posedge clk_i)
    begin
        PC_reg <= PC_i;
        inst_reg <= inst_i;
    end
   
endmodule 
