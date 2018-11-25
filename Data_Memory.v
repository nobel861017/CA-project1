module Data_Memory
(
	clk,
	MemWrite_i,
	MemRead_i,
	addr_i,
	data_i,
	data_o
);

// Interface
input				clk;
input				MemWrite_i;
input				MemRead_i;
input   [31 : 0]	addr_i;
input	[31 : 0]	data_i;
output  [31 : 0]	data_o;

// Data memory
reg		[31 : 0]	memory [0 : 7];
reg					tmp;

assign	addi_o = tmp;

always @(posedge clk)
	begin
		if (MemWrite_i == 1'b1)
			begin
				memory[addr_i] <= data_i;
			end
		if (MemRead_i == 1'b1)
			begin
				tmp = memory[addr_i];
			end
	end

endmodule
