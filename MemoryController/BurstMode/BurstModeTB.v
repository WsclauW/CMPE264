`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:58:56 11/24/2014
// Design Name:   BurstMode
// Module Name:   C:/Users/carlos/Dropbox/CMPE 264/MemoryController/BurstModeTB.v
// Project Name:  MemoryController
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: BurstMode
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module BurstModeTB;

	// Inputs
	reg [15:0] DataIn;
	reg [19:0] AddressIn;
	reg CE;
	reg CLK;
	reg ConWait;

	// Outputs
	wire Yield;
	wire Done;
	wire ConCE;
	wire ConWE;
	wire ConOE;
	wire ConADV;
	wire ConLB;
	wire ConUB;
	wire ConCRE;
	wire [19:0] ConAddressOut;

	// Bidirs
	wire [15:0] ConDataBus;

	// Instantiate the Unit Under Test (UUT)
	BurstMode uut (
		.DataIn(DataIn), 
		.AddressIn(AddressIn), 
		.CE(CE), 
		.CLK(CLK), 
		.ConWait(ConWait), 
		.Yield(Yield), 
		.Done(Done), 
		.ConCRE(ConCRE),
		.ConCE(ConCE), 
		.ConWE(ConWE), 
		.ConOE(ConOE), 
		.ConADV(ConADV), 
		.ConLB(ConLB), 
		.ConUB(ConUB), 
		.ConDataBus(ConDataBus), 
		.ConAddressOut(ConAddressOut)
	);

	initial begin
		// Initialize Inputs
		DataIn = 0;
		AddressIn = 0;
		CE = 0;
		CLK = 0;
		ConWait = 0;

		// Wait 100 ns for global reset to finish
		#10;
		CE = 1; 
		#50
		CE = 0;
		$finish;
		$stop;

        
		// Add stimulus here

	end

always 
	begin
		CLK = ~CLK;
		#10;
	end
      
endmodule

