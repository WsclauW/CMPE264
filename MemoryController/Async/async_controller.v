`timescale 1ns / 100ps
module async_controller( input         clk,
                                       WE, EN,
                         input  [2:0]  addr,
                         input  [2:0]  data_write,
                         inout  [15:0] MemDB,
                         output        RamCLK,
													RamCS,
                                       MemOE,
                                       MemWR,
                                       RamLB,
                                       RamUB,
                         output [3:0]  an,
                         output [7:0]  seg,
//                       output [15:0] data_read,
                         output [22:0] MemAdr );

   wire systemClock;
   assign systemClock = clk;

   assign MemAdr = { { 20{1'b0} }, addr };

   reg        WR, CS;
   reg [15:0] data_read;

   assign MemDB = ( WR ) ? { { 13{1'b0} }, data_write } : 16'bZ;	
   always @( posedge systemClock ) begin
      data_read = MemDB;
      WR <= WE;
      CS <= EN;		
   end

   async_fsm async( systemClock,
                    WR,
                    CS,
						  RamCLK,
                    RamCS,
                    MemOE,
                    MemWR,
                    RamLB,
                    RamUB );

   disp_hex_mux hex_display( systemClock,
                             1'b0,
                             data_read[15:12],
                             data_read[11:8],
                             data_read[7:4],
                             data_read[3:0],
                             4'hf,
                             an,
                             seg );
endmodule

module async_fsm( input  clk,
                         WR,
                         CS,
                  output RamCLK,
								 RamCS,
                         MemOE,
                         MemWR,
                         RamLB,
                         RamUB );
   localparam
      READY = 2'b00,
      READ  = 2'b01,
      WRITE = 2'b10,

      INACTIVE = 6'b111111,

      CYCLES_TO_WAIT = 3'd6;

   reg [1:0] current, next;
   reg [2:0] cycle_count;

   reg [5:0] controls;
   assign { RamCLK, RamCS, MemOE, MemWR, RamLB, RamUB } = controls;

   initial begin
      current     <= READY;
      next        <= READY;
      cycle_count <= 3'd0;
      controls    <= INACTIVE;
   end

   always @( posedge clk ) begin
      current     <= next;
      cycle_count <= ( READY == current ) ? 3'd0 :
      cycle_count + 1'b1;
   end

   always @( * ) begin
      case( current )
         READY:   begin
            next     <= ( CS ) ? 
                        ( ( WR ) ? WRITE : READ ) :
                        READY;
            controls <= INACTIVE;
         end
         READ:    begin
            next     <= ( CYCLES_TO_WAIT == cycle_count ) ? READY : READ;
            controls <= 5'b000100;
         end
         WRITE:   begin
            next     <= ( CYCLES_TO_WAIT == cycle_count ) ? READY : WRITE;
            controls <= 5'b001000;
         end
         default: begin
            next     <= READY;
            controls <= INACTIVE;
         end
      endcase
   end		
endmodule 
