module Sign_Extend
(
	data_i,
	data_o
);

input  [31 : 0] data_i;
output [31 : 0] data_o;

reg    [11 : 0] imm_reg;

assign data_o[11 : 0] = imm_reg[11 : 0];
assign data_o[31 : 12] = (imm_reg[11] == 1'b0)? {20{1'b0}} : {20{1'b1}};

always @(data_i)
	begin
		if (data_i[6 : 0] == 7'b0010011 || data_i[6 : 0] == 0000011) // addi or load
			begin
				imm_reg[11 : 0] = data_i[31 : 20];
			end
		else if (data_i[6 : 0] == 7'b0100011) // store
			begin
				imm_reg[4 : 0] = data_i[11 : 7];
				imm_reg[11 : 5] = data_i[31 : 25];
			end
		else if (data_i[6 : 0] == 7'b1100011) // branch
			begin
				imm_reg[3 : 0] = data_i[11 : 8];
				imm_reg[9 : 4] = data_i[30 : 25];
				imm_reg[10] = data_i[7];
				imm_reg[11] = data_i[31];
			end
	end

endmodule
