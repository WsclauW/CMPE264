`timescale 1ns / 1ps

//DataPath
module DP (	input aReset,
				input [21:0] DIN_Address,
				input [2:0] DIN_Length,
				input Clock,
				input [1:0] C_Address,
				input [1:0] C_HWords,
				input [3:0] C_aTimer,
				input [1:0] C_Step,
				input C_SA_A,
				input [1:0] C_SA_D,
				input C_BusOut,
				output [22:0] DOUT_ADDR,
				output [15:0] DOUT_CPU,
				output S_HWOne,
				output S_aTOne,
				output [3:0] S_SOut,
				inout [15:0] DIO_CRAM
);

	parameter integer aTB = 3;	//aTimerBits
//85ns access
	parameter integer RWC = 5;	//ReadWriteCycles > 85ns
	parameter integer PC = 2;	//PageCycles > 25ns
//70ns access
//	parameter integer RWC = 4;	//ReadWriteCycles > 70ns
//	parameter integer PC = 2;	//PageCycles > 20ns

	parameter [15:0] RCR_D = 16'h0010 | 16'h0080;	//RCR = Default | Page Mode Enable
	parameter [15:0] BCR_D = 16'h9D1F;					//BCR = Default

	wire [22:0] Address_Out;
	wire [15:0] Data_Out;

//Address Register
	address Address (	.In(DIN_Address),
							.aReset(aReset),
							.Clock(Clock),
							.Load(C_Address[1]),
							.Inc(C_Address[0]),
							.Out(Address_Out)
	);

//HalfWords Register
	hwords HWords (	.In(DIN_Length),
							.aReset(aReset),
							.Clock(Clock),
							.Load(C_HWords[1]),
							.Dec(C_HWords[0]),
							.HWOne(S_HWOne)
	);

//Asynchronous Timer
	atimer # (	.aTB(aTB),
					.RWC(RWC),
					.PC(PC)
	) aTimer (	.aReset(aReset),
					.Clock(Clock),
					.Clear(C_aTimer[3]),
					.aRW(C_aTimer[2]),
					.aPage(C_aTimer[1]),
					.Dec(C_aTimer[0]),
					.aTOne(S_aTOne)
	);

//Step Register
	step Step (	.aReset(aReset),
					.Clock(Clock),
					.Clear(C_Step[1]),
					.Inc(C_Step[0]),
					.SOut(S_SOut)
	);

//DOUT_ADDR Multiplexer
	amultiplexer AMultiplexer (	.Zero(Address_Out),
											.One(23'h7FFFFF),
											.SA(C_SA_A),
											.Out(DOUT_ADDR)
	);

//DOUT_CRAM Decoder
	ddecoder # (	.RCR_D(RCR_D),
						.BCR_D(BCR_D)
	) DDecoder (	.SA(C_SA_D),
						.Out(Data_Out)
	);

//DIO_CRAM Tristate Buffer
	bbuffer BBuffer (	.In(Data_Out),
							.BusOut(C_BusOut),
							.Out(DIO_CRAM)
	);

	assign DOUT_CPU = DIO_CRAM;

endmodule

module address (	input [21:0] In,
						input aReset,
						input Clock,
						input Load,
						input Inc,
						output reg [22:0] Out
);

	always @ (posedge aReset or posedge Clock) begin
		if (aReset) begin
			Out <= 23'h000000;
		end else if (Load) begin
			Out <= {In, 1'b0};							//word alignment
		end else if (Inc) begin
			Out <= {Out[22:4], Out[3:0] + 4'h1};	//adjacent addresses
		end else begin
			Out <= Out;
		end
	end

endmodule

module hwords (	input [2:0] In,
						input aReset,
						input Clock,
						input Load,
						input Dec,
						output HWOne
);

	reg [3:0] HWords;

	always @ (posedge aReset or posedge Clock) begin
		if (aReset) begin
			HWords <= 4'h0;
		end else if (Load) begin
			HWords <= {In, 1'b0};
		end else if (Dec) begin
			HWords <= HWords - 4'd1;
		end else begin
			HWords <= HWords;
		end
	end

	assign HWOne = (HWords == 4'h1) ? 1'b1 : 1'b0;

endmodule

module atimer (	input aReset,
						input Clock,
						input Clear,
						input aRW,
						input aPage,
						input Dec,
						output aTOne
);

	parameter integer aTB = 3;	//aTimerBits
	parameter integer RWC = 5;	//ReadWriteCycles > 85ns
	parameter integer PC = 2;	//PageCycles > 25ns

	reg [aTB-1:0] aTimer;

	always @ (posedge aReset or posedge Clock) begin
		if (aReset) begin
			aTimer <= 3'h0;
		end else if (Clear) begin
			aTimer <= 3'h0;
		end else if (aRW) begin
			aTimer <= RWC;
		end else if (aPage) begin
			aTimer <= PC;
		end else if (Dec) begin
			aTimer <= aTimer - 1'd1;
		end else begin
			aTimer <= aTimer;
		end
	end

	assign aTOne = (aTimer == 3'h1) ? 1'b1 : 1'b0;

endmodule

module step (	input aReset,
					input Clock,
					input Clear,
					input Inc,
					output reg [3:0] SOut
);

	always @ (posedge aReset or posedge Clock) begin
		if (aReset) begin
			SOut <= 4'h0;
		end else if (Clear) begin
			SOut <= 4'h0;
		end else if (Inc) begin
			SOut <= SOut + 4'd1;
		end else begin
			SOut <= SOut;
		end
	end

endmodule

module amultiplexer (	input [22:0] Zero,
								input [22:0] One,
								input SA,
								output [22:0] Out
);

	assign Out = (SA) ? One : Zero;

endmodule

module ddecoder (	input [1:0] SA,
						output reg [15:0] Out
);

	parameter [15:0] RCR_D = 16'h0010 | 16'h0080;
	parameter [15:0] BCR_D = 16'h9D1F;

	always @ * begin
		case (SA)
			2'b00:	begin
							Out = 16'h0000;	//SA_RCR_A
						end
			2'b01:	begin
							Out = RCR_D;	//SA_RCR_D
						end
			2'b10:	begin
							Out = 16'h0001;	//SA_BCR_A
						end
			2'b11:	begin
							Out = BCR_D;	//SA_BCR_D
						end
			default:	begin
							Out = 16'h0000;
						end
		endcase
	end

endmodule

module bbuffer (	input [15:0] In,
						input BusOut,
						output [15:0] Out
);

	assign Out = (BusOut) ? In : 16'hzzzz;

endmodule
