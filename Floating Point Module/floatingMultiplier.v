// Floating point modules 
// By Z. Baumgartner and A. Chen
// Info: this module takes in two floating point numbers and outputs the product.
// Bit 31 of the floating point is the SIGN BIT
// Bit 30 - 23 is the EXPONENT
// Bit 22 - 0 is the  SIGNIFICAND

module controUnit();
endmodule

module dataPath();
endmodule

module floating_multiplier(input [31:0] a, b,
									input CLK, loadInReg, loadOutReg,
									output [31:0] c);
		
		wire [31:0] num0_out, num1_out;
		wire [7:0] subtract_out, adder_out;
		wire [22:0] significand_out;
		wire sign, sign2OutputReg;
		
		register num0(.in(a), .set(loadInReg), .CLK(CLK), .out(num0_out));
		register num1(.in(b), .set(loadInReg), .CLK(CLK), .out(num1_out));
		subtractor subtract(.a(num0_out[30:23]), .b(subtract_out));
		exponentAdder adder(.a(subtract_out), .b(num1_out[30:23]), .sum(adder_out));
		x_or out_sign(.a(num0_out[31]), .b(num1_out[31]), .c(sign2OutputReg));
		multiplier multer(.significand1(num0_out[22:0]), .significand2(num1_out[22:0]), .product(significand_out));
		register outputNum_register(.in({sign2OutputReg, adder_out, significand_out}), .set(loadOutReg), .CLK(CLK), .out(c));
endmodule

// xor module
module x_or(input a, b,
				output	c);
		assign c = a^b;
endmodule

/*
exponentAddition takes the exponents from both floating points and 
adds them, producting two outputs named hi_output and low_output
*/
module exponentAdder(input [7:0] a, b, 
									output reg [7:0] sum);
		always@(*)
		begin
			sum = a + b - 1;
		end
endmodule

module subtractor(input [7:0] a,
							output reg[7:0] b);
		reg [7:0] difference;
		always@(*)
			b = a -  8'b11111111;
endmodule

// multiplier takes two significands and multiplies them together
module multiplier(input [22:0] significand1, significand2,
						output reg [22:0] product);
	always@(*)
		product = significand1 * significand2;
endmodule

module register(input [31:0] in,
						input set, CLK, 
						output reg [31:0] out);
		always @ (posedge CLK)
			if (set)
				out = in; 
			else
				out = out;
endmodule

/*
module exponentUpdate(input [7:0] a,b,
									output [7:0] c);
endmodule

module normalizeModule();
endmodule

module carryNet();
endmodule

module sticky();
endmodule

*/