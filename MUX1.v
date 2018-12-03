module MUX1
(
	data1_i,
	data2_i,
	select_i,
	data_o
);

input  data1_i;
input  data2_i;
input  select_i;
output data_o;

assign data_o = (select_i == 1'b0)? data1_i : data2_i;

endmodule
