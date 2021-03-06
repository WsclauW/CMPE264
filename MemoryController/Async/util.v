module clk_gen(input      clk50MHz,
               output reg clk_5KHz);

   integer count;

   always@(posedge clk50MHz) begin
      if(count == 25000000) begin
         clk_5KHz = ~clk_5KHz;
         count = 0;
      end
      count = count + 1;
   end
endmodule

module bcd_lookup(input      [15:0] num,
                  output reg [15:0] BCD);

   always @(num)
      case(num)
         16'd1:      BCD = 16'h1;
         16'd2:      BCD = 16'h2;
         16'd6:      BCD = 16'h6;
         16'd24:     BCD = 16'h24;
         16'd120:    BCD = 16'h120;
         16'd720:    BCD = 16'h720;
         16'd5040:   BCD = 16'h5040;
         default:    BCD = 16'h0;
      endcase

endmodule

module led(	input      [3:0] number,
            output reg [7:0] s);

   always @(number) begin // BCD to 7-segment decoding
      case (number)
         4'h0: s = 8'h88;	// 0
         4'h1: s = 8'hed;	// 1
         4'h2: s = 8'ha2;	// 2
         4'h3: s = 8'ha4;	// 3
         4'h4: s = 8'hc5;	// ...
         4'h5: s = 8'h94;
         4'h6: s = 8'h90;
         4'h7: s = 8'had;
         4'h8: s = 8'h80;
         4'h9: s = 8'h84;
         default: s = 8'hff;	// LED segs off
      endcase
   end
endmodule

   module LED_MUX (input            clk, rst,
                   input      [7:0] LED0, LED1, LED2, LED3,
                   output reg [3:0] LEDSEL,
                   output reg [7:0] LEDOUT);

   reg [1:0] index;

   always @(posedge clk)
      if(rst)
         index = 0;
      else
         index = index + 2'b1;

   always @(index or LED0 or LED1 or LED2 or LED3)
      case(index)
         0: begin
            LEDSEL = 4'b1110;
            LEDOUT = LED0;
         end
         1: begin
            LEDSEL = 4'b1101;
            LEDOUT = LED1;
         end
         2: begin
            LEDSEL = 4'b1011;
            LEDOUT = LED2;
         end
         3: begin
            LEDSEL = 4'b0111;
            LEDOUT = LED3;
         end
         default: begin
            LEDSEL = 0;
            LEDOUT = 0;
         end
      endcase
endmodule

module debounce(input      pb,
                input      clk,
                output reg pb_debounced);

   reg [7:0] shift; 
   always @ (posedge clk) begin 
      shift[6:0] <= shift[7:1]; 
      shift[7] <= pb; 
      if (shift==8'b11111111) 
         pb_debounced <= 1'b1; 
      else 
         pb_debounced <= 1'b0; 
   end 
endmodule
