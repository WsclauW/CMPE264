`timescale 1ns/1ps

module testbench_floatingMult();
	reg [31:0] value0, value1;
	reg loadTheRegs, clk;
	wire [31:0] out;
	initial
		begin
			////////////////seeeeeeeevvvvvvvvvvvvvvvvvvvvvvv
			value0 = 32'b0000000100000000000000000000011;
			value1 = 32'b0000000010000000000000000000010;
			loadTheRegs = 0;
			clk = 0;
			#20
			loadTheRegs = 1;
			#20
			loadTheRegs=0;
			#50 $stop;
			#10 $finish;
		end
	always #5 clk = ~clk ; 
	floating_multiplier DUT(.a(value0), .b(value1), .CLK(clk), .loadInReg(loadTheRegs), .loadOutReg(loadTheRegs), .c(out));
endmodule

/*
module testbench_xor();
	reg a, b;
	wire c;
	x_or testxor(.a(a), .b(b), .c(c));
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
*/
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