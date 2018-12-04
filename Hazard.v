module Forward
(
	ID_EX_MemRead_i,
	IF_ID_RSaddr_i,
	IF_ID_RTaddr_i,
	ID_EX_RDaddr_i,
	select_o,
	PC_write_o,
	IF_ID_write_o
);

input          ID_EX_MemRead_i;
input  [6 : 0] IF_ID_RSaddr_i;
input  [6 : 0] IF_ID_RTaddr_i;
input  [6 : 0] ID_EX_RDaddr_i;
output         select_o;

assign select_o = (ID_EX_MemRead_i && (IF_ID_RSaddr_i == ID_EX_RDaddr_i || IF_ID_RTaddr_i == ID_EX_RDaddr_i))? 1'b1 : 1'b0;
assign PC_write_o = (ID_EX_MemRead_i && (IF_ID_RSaddr_i == ID_EX_RDaddr_i || IF_ID_RTaddr_i == ID_EX_RDaddr_i))? 1'b0 : 1'b1;
assign IF_ID_write_o = (ID_EX_MemRead_i && (IF_ID_RSaddr_i == ID_EX_RDaddr_i || IF_ID_RTaddr_i == ID_EX_RDaddr_i))? 1'b0 : 1'b1;

endmodule
