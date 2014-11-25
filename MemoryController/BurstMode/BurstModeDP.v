`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:00:58 11/24/2014 
// Design Name: 
// Module Name:    BurstModeDP 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module BurstModeDP(
	input [1:0] Mode,
	input [19:0]  AddressIn,
	input [15:0]  DataIn,
	inout  [15:0]  ConDataBus,
	output reg [19:0] ConAddressOut
    );

//Micron Memory Register Configurations for burst\\
parameter BCR = 20'b1000001110101001111; // Explained on page 23 of datasheet
parameter RCR = 20'b0000000000000010000; // Explained on page 27 of datasheet

//Data Path Mode Definitions\\
parameter Idle  = 2'b00;
parameter Read  = 2'b01;
parameter Con = 2'b10;
parameter Write   = 2'b11;

//Internal Registers\\
reg [15:0] DataReg;


always@ (Mode)
	begin
	//Default to prevent latches
	
	ConAddressOut = 20'b00000000000000000000;
	DataReg = 0;
		

		case(Mode)
				Idle:
					begin
				
						ConAddressOut = 20'b00000000000000000000;
					end
				Read:
					begin
						
					end
				Write:
					begin
						
					end
				Con:
					begin
						DataReg = 0;
						ConAddressOut = BCR;
					end

			endcase
	end

assign ConDataBus = (Mode[0] & Mode[1]) ? DataReg : 16'bz; 



endmodule
