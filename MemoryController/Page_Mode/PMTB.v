`timescale 1ns / 1ps

module PMTB;

	// Inputs
	reg aReset;
	reg Clock;
	reg [21:0] DIN_Address;
	reg [2:0] DIN_Length;
	reg CIN_PM;

	// Outputs
	wire [22:0] DOUT_ADDR;
	wire [15:0] DOUT_CPU;
	wire [7:0] COUT_CRAM;
	wire COUT_OUTFIFO;
	wire [3:0] COUT_STATUS;
	wire COUT_PM;

	// Bidirs
	wire [15:0] DIO_CRAM;

	// Instantiate the Unit Under Test (UUT)
	Page_Mode uut (
		.aReset(aReset),
		.Clock(Clock),
		.DIN_Address(DIN_Address),
		.DIN_Length(DIN_Length),
		.CIN_PM(CIN_PM),
		.DOUT_ADDR(DOUT_ADDR),
		.DOUT_CPU(DOUT_CPU),
		.COUT_CRAM(COUT_CRAM),
		.COUT_OUTFIFO(COUT_OUTFIFO),
		.COUT_STATUS(COUT_STATUS),
		.COUT_PM(COUT_PM),
		.DIO_CRAM(DIO_CRAM)
	);

	always begin
		#10 Clock = 1'b0;
		#10 Clock = 1'b1;
	end

	initial begin
		// Initialize Inputs
		aReset = 1'b0;
		Clock = 1'b1;
		DIN_Address = 22'h000000;
		DIN_Length = 3'h0;
		CIN_PM = 1'b0;

		// Wait 100 ns for global reset to finish
		#50;
		aReset = 1'b1;
		#20;
		aReset = 1'b0;
		#30;

		// Add stimulus here
		DIN_Address = 22'h000000;
		DIN_Length = 3'h7;
		CIN_PM = 1'b1;
		#20;
		DIN_Address = 22'h000000;
		DIN_Length = 3'h0;
		CIN_PM = 1'b0;
		#1820;

		$finish;

	end

endmodule
