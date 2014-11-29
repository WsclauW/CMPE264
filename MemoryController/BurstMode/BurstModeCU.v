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
module BurstModeCU(
	input [15:0] DataIn,
	input [19:0] AddressIn,
	input [3:0] DelayCount,
	input CE,
	input CLK,
	input ConWait,
	output reg ResetCount,
	output reg CountCE,
	output reg [2:0] Mode,
	output reg Yield,
	output reg Finished,
	output reg ConCRE,
	output reg ConCE,  // Active low
	output reg ConWE,  // Active low
	output reg ConOE,  // Active low
	output reg ConADV, // Active low
	output reg ConLB,  // Active low
	output reg ConUB   // Active Low
    );


// One Hot Mealy State Definitions\\
parameter Idle     		 = 8'b00000001;
parameter Configure 	 = 8'b00000010;
parameter Wait     		 = 8'b00000100;
parameter ReadStart      = 8'b00001000;
parameter ReadContinue   = 8'b00010000;
parameter WriteStart     = 8'b00100000;
parameter WriteContinue  = 8'b01000000;
parameter Done      	 = 8'b10000000;

//Data Path Mode Definitions\\
parameter DPIdle    = 3'b000;
parameter DPRead    = 3'b001;
parameter DPCon     = 3'b010;
parameter DPWrite   = 3'b011;
parameter DPAddress = 3'b100;

//State Registers\\
reg [7:0] NextState    = 6'b000001;
reg [7:0] CurrentState = 6'b000001;

//Internal Registers\\
reg [3:0] Counter;
reg Delay;

reg ClearDelay;
reg DelaySig;

always@(CurrentState,Counter,CE, Delay)
	begin

	//Default Values to prevent latching \\ 
	Yield   = 0;
	Finished = 0;
	ConCE   = 1;
	ConWE   = 1;
	ConOE   = 1;
	ConADV  = 1;
	ConLB   = 1;
	ConUB   = 1;
	ConCRE  = 0;	
	Mode    = DPIdle;
	NextState = Idle;
	ResetCount = 0;
	CountCE = 0;
	DelaySig = 0;
	ClearDelay = 0;

		case(CurrentState)
			Idle:
				begin
					if(CE)
						begin

							NextState = Configure;
						end
					else 
						begin
							ConADV = 1'b1;
							ConCRE = 1'b0;
							ConCE  = 1'b1;
							ConOE  = 1'b1;
							ConWE  = 1'b1;
							NextState = Idle;
						end
				end

			Configure:
				begin
				 if(Delay)
							begin
								Mode    = DPCon;
								ConCRE  = 1;
								ConADV  = 0;
								ConCE   = 0;
								ConWE   = 0;
								DelaySig = 0;
								ClearDelay = 0;
								NextState = Wait;
							end
				else
					begin
						Mode  = DPCon;
								ConCRE  = 1;
								ConADV  = 1;
								ConCE   = 0;
								ConWE   = 1;
								DelaySig = 1;
								ClearDelay = 0;
								NextState = Configure;
					end
						
				end

			Wait:
				begin
					if(Counter == 3)
						begin
							ResetCount = 1;
							CountCE    = 0;
							NextState  = WriteStart;
						end
					else
						begin
							ResetCount = 0;
							CountCE    = 1;
							NextState  = Wait;
						end
				end

			ReadStart:
				begin
					if(Counter == 4)
						begin
							Mode = DPIdle;
							ConADV = 1;
							ConCE  = 0;
							ConWE  = 0;
							ConUB  = 0;
							ConLB  = 0;
							ResetCount = 1;
							CountCE    = 0;
							DelaySig = 0;
							ClearDelay =1;
							NextState = ReadContinue;
						end
					else if (Delay)
						begin
							Mode = DPAddress;
							ConADV = 1;
							ConCE  = 0;
							ConWE  = 0;
							ConUB  = 0;
							ConLB  = 0;
							CountCE = 1;
							ResetCount = 0;
							DelaySig = 1;
							ClearDelay =0;
							NextState = ReadStart;
						end
					else	
						begin
							Mode = DPAddress;
							ConADV = 1;
							ConCE  = 1;
							ConWE  = 1;
							ConUB  = 1;
							ConLB  = 1;
							CountCE = 1;
							ResetCount = 0;
							DelaySig = 1;
							ClearDelay =0;
							NextState = ReadStart;
						end
				
				end

			ReadContinue:
				begin
					if(Wait)
						begin
							NextState = Wait;
							Mode  = DPIdle;
							ConCE = 0;
						end
					else if(Finished) // Note! place holder logic
						begin
							NextState = Done;	
						end
					else
						begin
							Mode  = DPRead;
							ConCE = 0;
							NextState = ReadContinue;
						end
					
				end

			WriteStart:
				begin
					if(Counter == 1)
						begin
							Mode = DPAddress;
							ConADV = 1;
							ConCE  = 0;
							ConWE  = 0;
							ConUB  = 0;
							ConLB  = 0;
							ResetCount = 1;
							CountCE    = 0;
							ClearDelay = 1;
							DelaySig   = 0;
							NextState = WriteContinue;
						end
					else if(Delay)
						begin
							Mode = DPAddress;
							ConADV = 0;
							ConCE  = 0;
							ConWE  = 0;
							ConUB  = 0;
							ConLB  = 0;
							CountCE = 1;
							ResetCount = 0;
							ClearDelay = 0;
							DelaySig   = 1;
							NextState = WriteStart;
						end
					else	
						begin
							Mode = DPAddress;
							DelaySig = 1;
							ConADV = 1;
							ConCE  = 1;
							ConWE  = 1;
							ConUB  = 1;
							ConLB  = 1;
							CountCE = 1;
							ResetCount = 0;
							NextState = WriteStart;
						end
				end

			WriteContinue:
						begin
							Mode  = DPWrite;
							ConCE = 0;
							ConUB  = 0;
							ConLB  = 0;
							NextState = WriteContinue;
						end


			Done:
				begin
				
				end

			default:
				begin
				
				end
			
		endcase

	end

//State transition block\\
always @(posedge CLK)
	begin	
		CurrentState = NextState;
	end

//Counter Flipfop
always @(negedge CLK or posedge CountCE)
	begin
		if(CountCE)
			begin
				Counter = DelayCount;
			end
		else 
			begin
				Counter = 1'h0;
			end
	end
//Delay siganl\\
always @(negedge CLK or posedge ClearDelay)
	begin
		if(ClearDelay)
			begin
				Delay <= 0;
			end
		else 
			begin
			Delay <= DelaySig;
			end
	end

endmodule

module BurstCounter(
	input CountCE,
	input ResetCount,
	input clk,
	output [3:0] CountOut
	);

reg [3:0] Count = 1'h0;

always @(posedge clk or posedge ResetCount)
	begin
		if(CountCE)
			begin
				Count <= Count + 1;	
			end
		else if(ResetCount)
			begin
				Count <= 0;
			end
		else 
			begin
				Count <= Count;
			end
	end

assign CountOut = CountCE ? Count : 4'b0;
	

endmodule