// Floating point modules 
// By Z. Baumgartner and A. Chen
// Info: this module takes in two floating point numbers and outputs the product.
// Bit 31 of the floating point is the SIGN BIT
// Bit 30 - 23 is the EXPONENT
// Bit 22 - 0 is the  SIGNIFICAND

module floating_multiplier(input [31:0] a, b, 
									output [31:0] c);
									
endmodule

module xort(input a, b,
				output	c);
	assign c = a^b;
endmodule

module exponentAddition(input [7:0] a, b, 
									output [7:0] hi_output, low_output);
		reg [15:0] sum;
		always@(*)
			assign sum = a + b;
			assign low_output = sum[7:0];
			assign hi_output = sum[15:8];
endmodule

module exponentUpdate(input [7:0] a,b,
									output [7:0] c);
endmodule

// multiplier takes two significands and multiplies them together
module multiplier(input [22:0] significand1, significand2,
						output [22:0] hi_output, low_output);
	reg [45:0] product;
	always@(*)
		assign product = significand1 * significand2;
		assign low_output = product[22:0];
		assign hi_output = product[45:23];
endmodule

module normalizeModule();
endmodule

module carryNet();
endmodule

module sticky();
endmodule