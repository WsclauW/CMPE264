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
	output reg [1:0] Mode,
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
parameter DPIdle    = 2'b00;
parameter DPRead    = 2'b01;
parameter DPCon     = 2'b10;
parameter DPWrite   = 2'b11;
parameter DPAddress = 4;

//State Registers\\
reg [7:0] NextState    = 6'b000001;
reg [7:0] CurrentState = 6'b000001;


reg [3:0] Counter;


always@(CurrentState,Counter,CE)
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
		case(CurrentState)
			Idle:
				begin
					if(CE)
						begin
							NextState = Configure;
						end
					else 
						begin
							NextState = Idle;
						end
				end
			Configure:
				begin
					if(Counter == 1)
						begin
							Mode = DPIdle;
							ConCRE = 0;
							ConADV = 1;
							ConCE  = 1;
							ConWE  = 1;
							CountCE = 0;
							ResetCount = 1;
							NextState = Idle;
						end
					else 
						begin
							Mode    = DPCon;
							ConCRE  = 1;
							ConADV  = 0;
							ConCE   = 0;
							ConWE   = 0;
							CountCE = 1;
							ResetCount = 0;
							NextState = Configure;
						end
					
				end
			Wait:
				begin
				
				end
			ReadStart:
				begin
				
				end
			ReadContinue:
				begin
					
				end
			WriteStart:
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
							NextState = WriteContinue;
						end
					else if (Counter == 1)
						begin
							Mode = DPIdle;
							ConADV = 1;
							ConCE  = 0;
							ConWE  = 0;
							ConUB  = 0;
							ConLB  = 0;
							CountCE = 1;
							ResetCount = 0;
							NextState = WriteStart;
						end
					else	
						begin
							Mode = DPAddress;
							ConADV = 0;
							ConCE  = 0;
							ConWE  = 1;
							ConUB  = 0;
							ConLB  = 0;
							CountCE = 1;
							ResetCount = 0;
							NextState = WriteStart;
						end
				end
			WriteContinue:
				begin
					if(Wait)
						begin
							NextState = Wait;
							Mode  = DPIdle;
							ConCE = 0;
						end
					else if(Finished) // Note! place holder logic
						begin
							NextState = Done	
						end
					else
						begin
							Mode  = DPWrite;
							ConCE = 0;
							NextState = WriteContinue;
						end
					

					
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

//Counter Flip-Flop
always @(posedge CLK)
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

endmodule

module BurstCounter(
	input CountCE,
	input ResetCount,
	input clk,
	output [3:0] CountOut
	);

reg [3:0] Count = 1'h0;

always @(posedge clk)
	begin
		if(CountCE)
			begin
				Count = Count + 1;	
			end
		else if(ResetCount)
			begin
				Count = 0;
			end
		else 
			begin
				Count = Count;
			end
	end

assign CountOut = CountCE ? Count : 4'b0;
	

endmodule