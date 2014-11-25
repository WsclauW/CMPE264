`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: SJSU
// Engineer: Carlos Fernandez-Martinez
// 
// Create Date:    14:33:00 11/24/2014 
// Design Name: 
// Module Name:    BurstMode 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
// Burst mode for the Micron Celluar RAM found on the NEXYS 3 dev board.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module BurstMode(
	input [15:0] DataIn,
	input [19:0] AddressIn,
	input CE,
	input CLK,
	input ConWait,
	output Yield,
	output Done,
	output ConCRE,
	output ConCE,  // Active low
	output ConWE,  // Active low
	output ConOE,  // Active low
	output ConADV, // Active low
	output ConLB,  // Active low
	output ConUB,  // Active low
	inout [15:0]  ConDataBus,
	output [19:0] ConAddressOut  
);

wire [3:0] DelayCount;
wire ResetCount;
wire CountCE;
wire [1:0] Mode;
BurstModeCU BurstModeCU(
	.DataIn(DataIn),
	.AddressIn(AddressIn),
	.CE(CE),
	.CLK(CLK),
	.ConWait(ConWait),
	.DelayCount(DelayCount),
	.ResetCount(ResetCount),
	.CountCE(CountCE),
	.Mode(Mode),
	.Yield(Yield),
	.Finished(Done),
	.ConCRE(ConCRE),
	.ConCE(ConCE),  // Active low
	.ConWE(ConWE),  // Active low
	.ConOE(ConOE),  // Active low
	.ConADV(ConADV), // Active low
	.ConLB(ConLB),  // Active low
	.ConUB(ConUB)   // Active Low
    );

BurstCounter BurstCounter(
	.CountCE(CountCE),
	.ResetCount(ResetCount),
	.clk(CLK),
	.CountOut(DelayCount)
	);

BurstModeDP BurstModeDP(
	.Mode(Mode),
	.AddressIn(AddressIn),
	.DataIn(DataIn),
	.ConDataBus(ConDataBus),
	.ConAddressOut(ConAddressOut)
    );


endmodule
