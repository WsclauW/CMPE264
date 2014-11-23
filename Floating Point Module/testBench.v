`timescale 1ns/1ps

module testbench_xor();
	reg a, b;
	wire c;
	xort testxor(.a(a), .b(b), .c(c));
	initial
		begin
			a = 1'b0;
			b = 1'b0;
			#100;
			a = 1'b1;
			b = 1'b0;
			#100;
			a = 1'b0;
			b = 1'b1;
			#100;
			a = 1'b1;
			b = 1'b1;
		end
endmodule

/*
module testbench_multiplier();
	reg [22:0] a, b;
	wire [22:0] c, d;
	multiplier multi(.significand1(a), .significand2(b), .hi_output(c), .low_output(d));
	initial
		begin
			a = 2;
			b = 4;
			#100;
			a = 2;
			b = 2;
			#100;
			a = 4;
			b = 5;
		end
endmodule
*/