`timescale 1ns/100ps

module tb;

//Declare needed wire and reg for testing module.
reg  [31 : 0] a;
reg  [31 : 0] b;
wire [31 : 0] result;
wire		  zero;

//Test your module here.
ALU ALU(a , b , 3'b001 , result , zero);

initial
	begin
		//Output result.
		$monitor("a = %d , b = %d , result = %d\n" , a , b , result);
	end

initial
	begin
		//Set variable.
		a = 32'd100; b = 32'd28;
		# 100 a = 32'd56; b = 32'd31;
		# 100;
		$finish;
	end

endmodule
