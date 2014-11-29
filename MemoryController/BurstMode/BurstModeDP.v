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
	input [2:0]    Mode,
	input [19:0]   AddressIn,
	input [15:0]   DataIn,
	inout  [15:0]  	ConDataBus,
	output reg [19:0] ConAddressOut
    );

//Micron Memory Register Configurations for burst\\
parameter RegSel   = 2'b10;
parameter Resrv    = 1'b0;
parameter OpMode   = 1'b0;
parameter InitLat  = 1'b0;
parameter LatCount = 3'b011;
parameter WaitPol  = 1'b1;
parameter WaitCon  = 1'b1;
parameter DriveS   = 2'b01;
parameter BurstW   = 1'b1;
parameter BurstL   = 3'b111;




parameter BCR = {RegSel, Resrv, Resrv, OpMode, InitLat, LatCount,
				 WaitPol, Resrv, WaitCon, Resrv, Resrv, DriveS,
				 BurstW, BurstL}; // Explained on page 23 of datasheet


parameter RCR = 20'b0000000000000010000; // Explained on page 27 of datasheet

//Data Path Mode Definitions\\
parameter Idle    = 3'b000;
parameter Read    = 3'b001;
parameter Con     = 3'b010;
parameter Write   = 3'b011;
parameter Address = 3'b100;

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
						ConAddressOut = 20'b00000000000000111111;
						DataReg       = 16'b11010111011011010011;
					end
				Address:
					begin
						ConAddressOut = 20'b00000000000000111111;
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
