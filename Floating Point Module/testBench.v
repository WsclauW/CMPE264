`timescale 1ns/1ps
module testbench_topLevel();
	reg [31:0] value0, value1;
	reg start, clk;
	wire done;
	wire [31:0] out;
	wire [2:0] CS;
	wire changed;
	
	initial
		begin
			value0 = 32'b0000000100000000000000000000011;
			value1 = 32'b0000000010000000000000000000010;
			start = 0;
			clk = 0;
			#10
			start = 1;
			#100		// needs to be 10x clock cycles
			start = 0;
			#300
			#50 $stop;
			#10 $finish;
		end
	always #10 clk = ~clk ; 
	topLevel DUT(.changed(changed),.start(start), .clk(clk), .val_1(value0), .val_2(value1), .done(done), .val_out(out), .CS(CS));
endmodule

/*
module testbench_floatingMult();
	reg [31:0] value0, value1;
	reg loadTheRegs, clk;
	wire [31:0] out;
	wire changed;
	initial
		begin
			////////////////seeeeeeeevvvvvvvvvvvvvvvvvvvvvvv
			value0 = 32'b0000000100000000000000000000011;
			value1 = 32'b0000000010000000000000000000010;
			loadTheRegs = 0;
			clk = 0;
			#20
			loadTheRegs = 1;
			#200
			loadTheRegs=0;
			#50 $stop;
			#10 $finish;
		end
	always #5 clk = ~clk ; 
	floating_multiplier DUT(.changed(changed),.a(value0), .b(value1), .CLK(clk), .loadInReg(loadTheRegs), .loadOutReg(loadTheRegs), .c(out));
endmodule
*/
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