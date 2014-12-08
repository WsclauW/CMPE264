// Floating point modules 
// By Z. Baumgartner and A. Chen
// Info: this module takes in two floating point numbers and outputs the product.
// Bit 31 of the floating point is the SIGN BIT
// Bit 30 - 23 is the EXPONENT
// Bit 22 - 0 is the  SIGNIFICAND
`timescale 1ns/1ps

module topLevel(input start, clk,
						input [31:0] val_1, val_2,
						output done,
						output [31:0] val_out,
						output [2:0] CS,
						output wire changed);
	wire loadFirstStage, loadSecondStage,ack;
	controlUnit CU(.ack(ack),.start(start), .clk(clk), .changed(changed), .loadFirstStage(loadFirstStage), .loadSecondStage(loadSecondStage), .done(done), .CS(CS));
	floating_multiplier f_mult(.ack(ack), .a(val_1), .b(val_2), .CLK(clk), .loadInReg(loadFirstStage), .loadOutReg(loadSecondStage), .changed(changed), .c(val_out));
endmodule

module controlUnit(input start, clk, changed,
							output reg loadFirstStage, loadSecondStage, done, ack,
							output reg [2:0] CS);
	//reg [2:0] CS, NS;
	reg [2:0] NS;
	parameter 	state0 = 3'b000,	//idle
						state1 = 3'b001,	//loading inputs
						state2 = 3'b010,	//loading output
						state3 = 3'b011,	//wait
						state4 = 3'b100;	//done
	
	always @ (CS, start)
	begin
		case(CS)
			state0: begin
				if(start) 
					NS = state1;
				else 
					NS = state0;
			end
			
			state1: begin 
				NS = state2;
			end
			
			state2: begin
				NS = state3;
			end
			
			state3: begin
				if (changed==0)
					NS = state3;
				else
					NS = state4;
			end
		
			state4: begin
				NS = state0;
			end
			default: NS = state0;
		endcase
	end
	
	
	always @(posedge clk)
	begin
		CS = NS;
	end
	
	always @ (CS)
	begin
		case(CS)
			state0: begin
				loadFirstStage = 0;
				loadSecondStage = 0;
				done = 0;
				ack = 1;
			end
			
			state1: begin
				loadFirstStage = 1;
				loadSecondStage = 0;
				done = 0;
				ack = 0;
			end
			
			state2: begin
				loadFirstStage = 0;
				loadSecondStage = 1;
				done = 0;
				ack = 0;
			end
			
			state3: begin		//wait state
				loadFirstStage = 0;
				loadSecondStage = 1;
				done = 0;
				ack = 0;
			end
			
			state4: begin		//done state
				loadFirstStage = 0;
				loadSecondStage = 0;
				done = 1;
				ack = 1;
			end
		endcase
	end
endmodule

module floating_multiplier(input [31:0] a, b,
									input CLK, loadInReg, loadOutReg, ack,
									output changed,
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
		smart_register outputNum_register(.ack(ack), .in({sign2OutputReg, adder_out, significand_out}), .set(loadOutReg), .CLK(CLK), .changed(changed), .out(c));
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

module smart_register(input [31:0] in,
						input set, CLK, ack,
						output reg changed,
						output reg [31:0] out);
		always @ (posedge CLK)
		begin
			if (set)
				begin
					if(out == in)
						changed = 0;
					else
						changed = 1;
					out = in;
				end
			else
				out = out;
		end
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