`timescale 1ns / 1ps

//ControlUnit
module CU (	input aReset,
				input Clock,
				input CIN_PM,
				input S_HWOne,
				input S_aTOne,
				input [3:0] S_SOut,
				output reg [1:0] C_Address,
				output reg [1:0] C_HWords,
				output reg [3:0] C_aTimer,
				output reg [1:0] C_Step,
				output reg C_SA_A,
				output reg [1:0] C_SA_D,
				output reg C_BusOut,
				output reg [7:0] COUT_CRAM,
				output reg COUT_OUTFIFO,
				output reg [3:0] COUT_STATUS,
				output reg COUT_PM
);

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

	reg [8:0] state;
	reg [8:0] next_state;

	always @ (posedge aReset or posedge Clock) begin
		state <= (aReset) ? DEFAULT : next_state;
	end

	always @ * begin
		case (state)
			Initialize : begin
				if (CIN_PM) begin
					next_state <= Standby;
				end else begin
					next_state <= Initialize;
				end
			end
			Standby : begin
				case (S_SOut)
					4'h0 : begin
						next_state <= SA_R;
					end
					4'h1 : begin
						next_state <= SA_R;
					end
					4'h2 : begin
						next_state <= SA_RCR_A;
					end
					4'h3 : begin
						next_state <= SA_RCR_D;
					end
					4'h4 : begin
						next_state <= SA_R;
					end
					4'h5 : begin
						next_state <= SA_R;
					end
					4'h6 : begin
						next_state <= SA_BCR_A;
					end
					4'h7 : begin
						next_state <= SA_BCR_D;
					end
					4'h8 : begin
						next_state <= aRead;
					end
					default : begin
						next_state <= DEFAULT;	//Fault
					end
				endcase
			end
			SA_R : begin						//SoftwareAccess Read
				if (S_aTOne) begin
					next_state <= Standby;
				end else begin
					next_state <= SA_R;
				end
			end
			SA_RCR_A : begin					//SoftwareAccess RCR Address
				if (S_aTOne) begin
					next_state <= Standby;
				end else begin
					next_state <= SA_RCR_A;
				end
			end
			SA_RCR_D : begin					//SoftwareAccess RCR Data
				if (S_aTOne) begin
					next_state <= Standby;
				end else begin
					next_state <= SA_RCR_D;
				end
			end
			SA_BCR_A : begin					//SoftwareAccess BCR Address
				if (S_aTOne) begin
					next_state <= Standby;
				end else begin
					next_state <= SA_BCR_A;
				end
			end
			SA_BCR_D : begin					//SoftwareAccess BCR Data
				if (S_aTOne) begin
					next_state <= Standby;
				end else begin
					next_state <= SA_BCR_D;
				end
			end
			aRead : begin						//AsynchronousRead
				if (S_aTOne) begin
					next_state <= PMRead;
				end else begin
					next_state <= aRead;
				end
			end
			PMRead : begin								//PageModeRead
				case ({S_aTOne, S_HWOne})
					2'b00 : begin
						next_state <= PMRead;
					end
					2'b01 : begin
						next_state <= PMRead;
					end
					2'b10 : begin
						next_state <= PMRead;
					end
					2'b11 : begin
						next_state <= Initialize;
					end
					default : begin
						next_state <= DEFAULT;		//Fault
					end
				endcase
			end
			default : begin			//Fault
				next_state <= Initialize;
			end
		endcase
	end

	always @ * begin
		case (state)
			Initialize : begin
				C_Address = 2'b10;	//Load
				C_HWords = 2'b10;		//Load
				C_aTimer = 4'h8;		//Clear
				C_Step = 2'b10;		//Clear
				C_SA_A = 1'b0;			//x
				C_SA_D = 2'b00;		//x
				C_BusOut = 1'b0;		//False
				COUT_CRAM = 8'h7B;	//Standby
				COUT_OUTFIFO = 1'b0;	//False
				COUT_STATUS = 4'hA;	//Load SOUT_PM
				COUT_PM = 1'b0;		//False
				if (CIN_PM) begin
					C_Address = 2'b10;
					C_HWords = 2'b10;
					C_aTimer = 4'h8;
					C_Step = 2'b10;
					C_SA_A = 1'b0;
					C_SA_D = 2'b00;
					C_BusOut = 1'b0;
					COUT_CRAM = 8'h7B;
					COUT_OUTFIFO = 1'b0;
					COUT_STATUS = 4'hA;
					COUT_PM = 1'b0;
				end
			end
			Standby : begin
				C_Address = 2'b00;	//False
				C_HWords = 2'b00;		//False
				C_aTimer = 4'h0;		//False
				C_Step = 2'b00;		//False
				C_SA_A = 1'b0;			//x
				C_SA_D = 2'b00;		//x
				C_BusOut = 1'b0;		//False
				COUT_CRAM = 8'h7B;	//Standby
				COUT_OUTFIFO = 1'b0;	//False
				COUT_STATUS = 4'h0;	//False
				COUT_PM = 1'b0;		//False
				case (S_SOut)
					4'h0 : begin
						C_Address = 2'b00;
						C_HWords = 2'b00;
						C_aTimer = 4'h4;		//aRW
						C_Step = 2'b00;
						C_SA_A = 1'b0;
						C_SA_D = 2'b00;
						C_BusOut = 1'b0;
						COUT_CRAM = 8'h7B;
						COUT_OUTFIFO = 1'b0;
						COUT_STATUS = 4'h0;
						COUT_PM = 1'b0;
					end
					4'h1 : begin
						C_Address = 2'b00;
						C_HWords = 2'b00;
						C_aTimer = 4'h4;		//aRW
						C_Step = 2'b00;
						C_SA_A = 1'b0;
						C_SA_D = 2'b00;
						C_BusOut = 1'b0;
						COUT_CRAM = 8'h7B;
						COUT_OUTFIFO = 1'b0;
						COUT_STATUS = 4'h0;
						COUT_PM = 1'b0;
					end
					4'h2 : begin
						C_Address = 2'b00;
						C_HWords = 2'b00;
						C_aTimer = 4'h4;		//aRW
						C_Step = 2'b00;
						C_SA_A = 1'b0;
						C_SA_D = 2'b00;
						C_BusOut = 1'b0;
						COUT_CRAM = 8'h7B;
						COUT_OUTFIFO = 1'b0;
						COUT_STATUS = 4'h0;
						COUT_PM = 1'b0;
					end
					4'h3 : begin
						C_Address = 2'b00;
						C_HWords = 2'b00;
						C_aTimer = 4'h4;		//aRW
						C_Step = 2'b00;
						C_SA_A = 1'b0;
						C_SA_D = 2'b00;
						C_BusOut = 1'b0;
						COUT_CRAM = 8'h7B;
						COUT_OUTFIFO = 1'b0;
						COUT_STATUS = 4'h0;
						COUT_PM = 1'b0;
					end
					4'h4 : begin
						C_Address = 2'b00;
						C_HWords = 2'b00;
						C_aTimer = 4'h4;		//aRW
						C_Step = 2'b00;
						C_SA_A = 1'b0;
						C_SA_D = 2'b00;
						C_BusOut = 1'b0;
						COUT_CRAM = 8'h7B;
						COUT_OUTFIFO = 1'b0;
						COUT_STATUS = 4'h0;
						COUT_PM = 1'b0;
					end
					4'h5 : begin
						C_Address = 2'b00;
						C_HWords = 2'b00;
						C_aTimer = 4'h4;		//aRW
						C_Step = 2'b00;
						C_SA_A = 1'b0;
						C_SA_D = 2'b00;
						C_BusOut = 1'b0;
						COUT_CRAM = 8'h7B;
						COUT_OUTFIFO = 1'b0;
						COUT_STATUS = 4'h0;
						COUT_PM = 1'b0;
					end
					4'h6 : begin
						C_Address = 2'b00;
						C_HWords = 2'b00;
						C_aTimer = 4'h4;		//aRW
						C_Step = 2'b00;
						C_SA_A = 1'b0;
						C_SA_D = 2'b00;
						C_BusOut = 1'b0;
						COUT_CRAM = 8'h7B;
						COUT_OUTFIFO = 1'b0;
						COUT_STATUS = 4'h0;
						COUT_PM = 1'b0;
					end
					4'h7 : begin
						C_Address = 2'b00;
						C_HWords = 2'b00;
						C_aTimer = 4'h4;		//aRW
						C_Step = 2'b00;
						C_SA_A = 1'b0;
						C_SA_D = 2'b00;
						C_BusOut = 1'b0;
						COUT_CRAM = 8'h7B;
						COUT_OUTFIFO = 1'b0;
						COUT_STATUS = 4'h0;
						COUT_PM = 1'b0;
					end
					4'h8 : begin
						C_Address = 2'b00;
						C_HWords = 2'b00;
						C_aTimer = 4'h4;		//aRW
						C_Step = 2'b00;
						C_SA_A = 1'b0;
						C_SA_D = 2'b00;
						C_BusOut = 1'b0;
						COUT_CRAM = 8'h7B;
						COUT_OUTFIFO = 1'b0;
						COUT_STATUS = 4'h0;
						COUT_PM = 1'b0;
					end
					default : begin
						C_Address = 2'b00;	//False
						C_HWords = 2'b00;		//False
						C_aTimer = 4'h0;		//False
						C_Step = 2'b00;		//False
						C_SA_A = 1'b0;			//False
						C_SA_D = 2'b00;		//False
						C_BusOut = 1'b0;		//False
						COUT_CRAM = 8'h7B;	//Standby
						COUT_OUTFIFO = 1'b0;	//False
						COUT_STATUS = 4'hC;	//Load SOUT_FAULT
						COUT_PM = 1'b0;		//False
					end
				endcase
			end
			SA_R : begin
				C_Address = 2'b00;	//False
				C_HWords = 2'b00;		//False
				C_aTimer = 4'h1;		//Dec
				C_Step = 2'b00;		//False
				C_SA_A = 1'b1;			//True
				C_SA_D = 2'b00;		//x
				C_BusOut = 1'b0;		//False
				COUT_CRAM = 8'h08;	//Asynchronous Read
				COUT_OUTFIFO = 1'b0;	//False
				COUT_STATUS = 4'h0;	//False
				COUT_PM = 1'b0;		//False
				if (S_aTOne) begin
					C_Address = 2'b00;
					C_HWords = 2'b00;
					C_aTimer = 4'h1;
					C_Step = 2'b01;		//Inc
					C_SA_A = 1'b1;
					C_SA_D = 2'b00;
					C_BusOut = 1'b0;
					COUT_CRAM = 8'h08;
					COUT_OUTFIFO = 1'b0;
					COUT_STATUS = 4'h0;
					COUT_PM = 1'b0;
				end
			end
			SA_RCR_A : begin
				C_Address = 2'b00;	//False
				C_HWords = 2'b00;		//False
				C_aTimer = 4'h1;		//Dec
				C_Step = 2'b00;		//False
				C_SA_A = 1'b1;			//True
				C_SA_D = 2'b00;		//SA_RCR_A
				C_BusOut = 1'b1;		//True
				COUT_CRAM = 8'h10;	//Asynchronous Write
				COUT_OUTFIFO = 1'b0;	//False
				COUT_STATUS = 4'h0;	//False
				COUT_PM = 1'b0;		//False
				if (S_aTOne) begin
					C_Address = 2'b00;
					C_HWords = 2'b00;
					C_aTimer = 4'h1;
					C_Step = 2'b01;		//Inc
					C_SA_A = 1'b1;
					C_SA_D = 2'b00;
					C_BusOut = 1'b1;
					COUT_CRAM = 8'h10;
					COUT_OUTFIFO = 1'b0;
					COUT_STATUS = 4'h0;
					COUT_PM = 1'b0;
				end
			end
			SA_RCR_D : begin
				C_Address = 2'b00;	//False
				C_HWords = 2'b00;		//False
				C_aTimer = 4'h1;		//Dec
				C_Step = 2'b00;		//False
				C_SA_A = 1'b1;			//True
				C_SA_D = 2'b01;		//SA_RCR_D
				C_BusOut = 1'b1;		//True
				COUT_CRAM = 8'h10;	//Asynchronous Write
				COUT_OUTFIFO = 1'b0;	//False
				COUT_STATUS = 4'h0;	//False
				COUT_PM = 1'b0;		//False
				if (S_aTOne) begin
					C_Address = 2'b00;
					C_HWords = 2'b00;
					C_aTimer = 4'h1;
					C_Step = 2'b01;		//Inc
					C_SA_A = 1'b1;
					C_SA_D = 2'b01;
					C_BusOut = 1'b1;
					COUT_CRAM = 8'h10;
					COUT_OUTFIFO = 1'b0;
					COUT_STATUS = 4'h0;
					COUT_PM = 1'b0;
				end
			end
			SA_BCR_A : begin
				C_Address = 2'b00;	//False
				C_HWords = 2'b00;		//False
				C_aTimer = 4'h1;		//Dec
				C_Step = 2'b00;		//False
				C_SA_A = 1'b1;			//True
				C_SA_D = 2'b10;		//SA_BCR_A
				C_BusOut = 1'b1;		//True
				COUT_CRAM = 8'h10;	//Asynchronous Write
				COUT_OUTFIFO = 1'b0;	//False
				COUT_STATUS = 4'h0;	//False
				COUT_PM = 1'b0;		//False
				if (S_aTOne) begin
					C_Address = 2'b00;
					C_HWords = 2'b00;
					C_aTimer = 4'h1;
					C_Step = 2'b01;		//Inc
					C_SA_A = 1'b1;
					C_SA_D = 2'b10;
					C_BusOut = 1'b1;
					COUT_CRAM = 8'h10;
					COUT_OUTFIFO = 1'b0;
					COUT_STATUS = 4'h0;
					COUT_PM = 1'b0;
				end
			end
			SA_BCR_D : begin
				C_Address = 2'b00;	//False
				C_HWords = 2'b00;		//False
				C_aTimer = 4'h1;		//Dec
				C_Step = 2'b00;		//False
				C_SA_A = 1'b1;			//True
				C_SA_D = 2'b11;		//SA_BCR_D
				C_BusOut = 1'b1;		//True
				COUT_CRAM = 8'h10;	//Asynchronous Write
				COUT_OUTFIFO = 1'b0;	//False
				COUT_STATUS = 4'h0;	//False
				COUT_PM = 1'b0;		//False
				if (S_aTOne) begin
					C_Address = 2'b00;
					C_HWords = 2'b00;
					C_aTimer = 4'h1;
					C_Step = 2'b01;		//Inc
					C_SA_A = 1'b1;
					C_SA_D = 2'b11;
					C_BusOut = 1'b1;
					COUT_CRAM = 8'h10;
					COUT_OUTFIFO = 1'b0;
					COUT_STATUS = 4'h0;
					COUT_PM = 1'b0;
				end
			end
			aRead : begin
				C_Address = 2'b00;	//False
				C_HWords = 2'b00;		//False
				C_aTimer = 4'h1;		//Dec
				C_Step = 2'b00;		//False
				C_SA_A = 1'b0;			//x
				C_SA_D = 2'b00;		//x
				C_BusOut = 1'b0;		//False
				COUT_CRAM = 8'h08;	//Asynchronous Read
				COUT_OUTFIFO = 1'b0;	//False
				COUT_STATUS = 4'h0;	//False
				COUT_PM = 1'b0;		//False
				if (S_aTOne) begin
					C_Address = 2'b01;	//Inc
					C_HWords = 2'b01;		//Dec
					C_aTimer = 4'h2;		//aPage
					C_Step = 2'b00;
					C_SA_A = 1'b0;
					C_SA_D = 2'b00;
					C_BusOut = 1'b0;
					COUT_CRAM = 8'h08;
					COUT_OUTFIFO = 1'b1;	//Load
					COUT_STATUS = 4'h0;
					COUT_PM = 1'b0;
				end
			end
			PMRead : begin
				C_Address = 2'b00;	//False
				C_HWords = 2'b00;		//False
				C_aTimer = 4'h1;		//Dec
				C_Step = 2'b00;		//False
				C_SA_A = 1'b0;			//x
				C_SA_D = 2'b00;		//x
				C_BusOut = 1'b0;		//False
				COUT_CRAM = 8'h08;	//Asynchronous Read
				COUT_OUTFIFO = 1'b0;	//False
				COUT_STATUS = 4'h0;	//False
				COUT_PM = 1'b0;		//False
				case ({S_aTOne, S_HWOne})
					2'b00 : begin
						C_Address = 2'b00;
						C_HWords = 2'b00;
						C_aTimer = 4'h1;
						C_Step = 2'b00;
						C_SA_A = 1'b0;
						C_SA_D = 2'b00;
						C_BusOut = 1'b0;
						COUT_CRAM = 8'h08;
						COUT_OUTFIFO = 1'b0;
						COUT_STATUS = 4'h0;
						COUT_PM = 1'b0;
					end
					2'b01 : begin
						C_Address = 2'b00;
						C_HWords = 2'b00;
						C_aTimer = 4'h1;
						C_Step = 2'b00;
						C_SA_A = 1'b0;
						C_SA_D = 2'b00;
						C_BusOut = 1'b0;
						COUT_CRAM = 8'h08;
						COUT_OUTFIFO = 1'b0;
						COUT_STATUS = 4'h0;
						COUT_PM = 1'b0;
					end
					2'b10 : begin
						C_Address = 2'b01;	//Inc
						C_HWords = 2'b01;		//Dec
						C_aTimer = 4'h2;		//aPage
						C_Step = 2'b00;
						C_SA_A = 1'b0;
						C_SA_D = 2'b00;
						C_BusOut = 1'b0;
						COUT_CRAM = 8'h08;
						COUT_OUTFIFO = 1'b1;	//Load
						COUT_STATUS = 4'h0;
						COUT_PM = 1'b0;
					end
					2'b11 : begin
						C_Address = 2'b01;	//Inc
						C_HWords = 2'b01;		//Dec
						C_aTimer = 4'h1;
						C_Step = 2'b00;
						C_SA_A = 1'b0;
						C_SA_D = 2'b00;
						C_BusOut = 1'b0;
						COUT_CRAM = 8'h08;
						COUT_OUTFIFO = 1'b1;	//Load
						COUT_STATUS = 4'h9;	//Load SOUT_CPU
						COUT_PM = 1'b1;		//True
					end
					default : begin
						C_Address = 2'b00;	//False
						C_HWords = 2'b00;		//False
						C_aTimer = 4'h0;		//False
						C_Step = 2'b00;		//False
						C_SA_A = 1'b0;			//False
						C_SA_D = 2'b00;		//False
						C_BusOut = 1'b0;		//False
						COUT_CRAM = 8'h7B;	//Standby
						COUT_OUTFIFO = 1'b0;	//False
						COUT_STATUS = 4'hC;	//Load SOUT_FAULT
						COUT_PM = 1'b0;		//False
					end
				endcase
			end
			default : begin
				C_Address = 2'b00;	//False
				C_HWords = 2'b00;		//False
				C_aTimer = 4'h0;		//False
				C_Step = 2'b00;		//False
				C_SA_A = 1'b0;			//False
				C_SA_D = 2'b00;		//False
				C_BusOut = 1'b0;		//False
				COUT_CRAM = 8'h7B;	//Standby
				COUT_OUTFIFO = 1'b0;	//False
				COUT_STATUS = 4'hC;	//Load SOUT_FAULT
				COUT_PM = 1'b1;		//True
			end
		endcase
	end

endmodule
