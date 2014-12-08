`timescale 1ns / 1ps

module Page_Mode (	input aReset,
							input Clock,
							input [21:0] DIN_Address,
							input [2:0] DIN_Length,
							input CIN_PM,
							output [22:0] DOUT_ADDR,
							output [15:0] DOUT_CPU,
							output [7:0] COUT_CRAM,
							output COUT_OUTFIFO,
							output [3:0] COUT_STATUS,
							output COUT_PM,
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

//Safe One-Hot FSM Encoding
	parameter DEFAULT		= 9'h000;
	parameter Initialize	= 9'h001;
	parameter Standby		= 9'h002;
	parameter SA_R			= 9'h004;
	parameter SA_RCR_A	= 9'h008;
	parameter SA_RCR_D	= 9'h010;
	parameter SA_BCR_A	= 9'h020;
	parameter SA_BCR_D	= 9'h040;
	parameter aRead		= 9'h080;
	parameter PMRead		= 9'h100;

	wire [1:0] C_Address;
	wire [1:0] C_HWords;
	wire [3:0] C_aTimer;
	wire [1:0] C_Step;
	wire C_SA_A;
	wire [1:0] C_SA_D;
	wire C_BusOut;
	wire S_HWOne;
	wire S_aTOne;
	wire [3:0] S_SOut;

	DP # (	.aTB(aTB),
				.RWC(RWC),
				.PC(PC),
				.RCR_D(RCR_D),
				.BCR_D(BCR_D)
	) DataPath (	.aReset(aReset),
						.DIN_Address(DIN_Address),
						.DIN_Length(DIN_Length),
						.Clock(Clock),
						.C_Address(C_Address),
						.C_HWords(C_HWords),
						.C_aTimer(C_aTimer),
						.C_Step(C_Step),
						.C_SA_A(C_SA_A),
						.C_SA_D(C_SA_D),
						.C_BusOut(C_BusOut),
						.DOUT_ADDR(DOUT_ADDR),
						.DOUT_CPU(DOUT_CPU),
						.S_HWOne(S_HWOne),
						.S_aTOne(S_aTOne),
						.S_SOut(S_SOut),
						.DIO_CRAM(DIO_CRAM)
	);

	CU # (	.DEFAULT(DEFAULT),
				.Initialize(Initialize),
				.Standby(Standby),
				.SA_R(SA_R),
				.SA_RCR_A(SA_RCR_A),
				.SA_RCR_D(SA_RCR_D),
				.SA_BCR_A(SA_BCR_A),
				.SA_BCR_D(SA_BCR_D),
				.aRead(aRead),
				.PMRead(PMRead)
	) ControlUnit (	.aReset(aReset),
							.Clock(Clock),
							.CIN_PM(CIN_PM),
							.S_HWOne(S_HWOne),
							.S_aTOne(S_aTOne),
							.S_SOut(S_SOut),
							.C_Address(C_Address),
							.C_HWords(C_HWords),
							.C_aTimer(C_aTimer),
							.C_Step(C_Step),
							.C_SA_A(C_SA_A),
							.C_SA_D(C_SA_D),
							.C_BusOut(C_BusOut),
							.COUT_CRAM(COUT_CRAM),
							.COUT_OUTFIFO(COUT_OUTFIFO),
							.COUT_STATUS(COUT_STATUS),
							.COUT_PM(COUT_PM)
	);

endmodule
