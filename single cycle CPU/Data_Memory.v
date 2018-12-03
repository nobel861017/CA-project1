module Data_Memory
(
	clk_i,
	MemWrite_i,
	MemRead_i,
	addr_i,
	data_i,
	data_o
);

// Interface
input				clk_i;
input				MemWrite_i;
input				MemRead_i;
input   [31 : 0]	addr_i;
input	[31 : 0]	data_i;
output  [31 : 0]	data_o;

// Data memory
reg		[7 : 0]	    memory [0 : 31];

assign	data_o = (MemRead_i == 1'b1)? {((memory[addr_i][7] == 1'b0)? 24'b0 : 24'b1) , memory[addr_i]} : 32'b0;

always @(posedge clk_i)
	begin
		if (MemWrite_i == 1'b1)
			begin
				memory[addr_i][7 : 0] <= data_i[7 : 0];
			end
	end

endmodule
