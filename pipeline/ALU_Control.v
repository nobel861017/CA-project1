module ALU_Control
(
    funct_i,
    ALUOp_i,
    ALUCtrl_o
);

input  [31 : 0] funct_i;
input  [1 : 0]  ALUOp_i;
output [3 : 0]  ALUCtrl_o;

reg    [3 : 0]  ALUCtrl_reg;

assign ALUCtrl_o = ALUCtrl_reg;

always @(funct_i or ALUOp_i)
	begin
		if (ALUOp_i == 2'b10) // R-type
			begin
				if (funct_i[14 : 12] == 3'b000)
					begin
						if (funct_i[31 : 25] == 7'b0000000) // add
							begin
								ALUCtrl_reg = 4'b0010;
							end
						else if (funct_i[31 : 25] == 7'b0100000) // sub
							begin
								ALUCtrl_reg = 4'b0110;
							end
						else if (funct_i[31 : 25] == 7'b0000001) //mul
							begin
								ALUCtrl_reg = 4'b0111;
							end
					end
				else if (funct_i[14 : 12] == 3'b111) // and
					begin
						ALUCtrl_reg = 4'b0000;
					end
				else if (funct_i[14 : 12] == 3'b110) //or
					begin
						ALUCtrl_reg = 4'b0001;
					end
			end
		else if (ALUOp_i == 2'b11 || ALUOp_i == 2'b00) // addi or load/store
			begin
				ALUCtrl_reg = 4'b0010;
			end
		else if (ALUOp_i == 2'b01)
			begin
				ALUCtrl_reg = 4'b0110;
			end
	end

endmodule
