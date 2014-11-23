`timescale 1ns / 1ps

module uartInterface #(parameter D_WIDTH = 32,
                       parameter A_WIDTH = 7)
                      (input clk50MHz,
                       input rx,
                       output tx,
                       input [D_WIDTH-1:0] if_data_in,
                       output [D_WIDTH-1:0] if_data_out,
                       output [A_WIDTH-1:0] if_addr_out,
                       output reg if_out_valid);
                                     
reg byte_count_en;
reg byte_count_rst;
wire[2:0] byteCount;            
count_reg #(.D_WIDTH(3)) byteCounter   (.en(byte_count_en),
                                        .rst(byte_count_rst),
                                        .clk(clk50MHz),
                                        .count(byteCount));
                               
wire [D_WIDTH-1:0] tx_parallel; 
reg tx_parallel_we;
reg tx_parallel_rst;                              
d_reg #(.WIDTH(D_WIDTH)) tx_parallel_reg (.clk(clk50MHz),
                                         .en(tx_parallel_we),
                                         .reset(tx_parallel_rst),
                                         .d(if_data_in),
                                         .q(tx_parallel));

wire data_rx_valid;
wire [7:0] data_rx;   
wire busy;    
reg data_tx_valid;
wire [7:0] data_tx;
uart uartModule(.clk(clk50MHz),
                .rx(rx),
                .tx(tx),
                .data_out_valid(data_rx_valid),
                .data_in_valid(data_tx_valid),
                .data_out(data_rx),
                .data_in(data_tx),
                .busy(busy));
                
mux_4to1 #(.width(8)) tx_mux (.in_A(tx_parallel[7:0]),
                       .in_B(tx_parallel[15:8]),
                       .in_C(tx_parallel[23:16]),
                       .in_D(tx_parallel[31:24]),
                       .mux_sel(byteCount[1:0]-1), //hack to fix broken TX state machine
                       .out(data_tx));
                       
// Address register
wire [7:0] addr;
reg addr_we;
reg addr_rst;
wire we;
assign we = addr[7];
d_reg #(.WIDTH(8)) addr_0(.clk(clk50MHz),
                          .en(addr_we),
                          .reset(addr_rst),
                          .d(data_rx),
                          .q(addr[7:0]));
                          
assign if_addr_out = addr[6:0];
                          
// Data registers
reg[3:0] data_we;
reg data_rst;
d_reg #(.WIDTH(8)) data_0(.clk(clk50MHz),
                          .en(data_we[0]),
                          .reset(data_rst),
                          .d(data_rx),
                          .q(if_data_out[7:0]));

d_reg #(.WIDTH(8)) data_1(.clk(clk50MHz),
                          .en(data_we[1]),
                          .reset(data_rst),
                          .d(data_rx),
                          .q(if_data_out[15:8]));
                          
d_reg #(.WIDTH(8)) data_2(.clk(clk50MHz),
                          .en(data_we[2]),
                          .reset(data_rst),
                          .d(data_rx),
                          .q(if_data_out[23:16]));
                          
d_reg #(.WIDTH(8)) data_3(.clk(clk50MHz),
                          .en(data_we[3]),
                          .reset(data_rst),
                          .d(data_rx),
                          .q(if_data_out[31:24]));
     
reg [3:0] currentState;
reg [3:0] nextState;

parameter STATE_RESET = 0;
parameter STATE_IDLE = 1;
parameter STATE_UART_RX_DATA = 3;
parameter STATE_UART_TX_DATA = 4;

initial begin
    currentState <= STATE_RESET;
    nextState <= STATE_RESET;
end

always@(posedge clk50MHz) begin
    currentState <= nextState;
end
    
always@(*) begin
    case (currentState)
        STATE_RESET: begin
            nextState <= STATE_IDLE;
        end
        STATE_IDLE: begin
            if (data_rx_valid) begin
                if (we) begin
                    nextState <= STATE_UART_RX_DATA;
                end
                else begin
                    nextState <= STATE_UART_TX_DATA;
                end
            end
            else begin
                nextState <= STATE_IDLE;
            end
        end
        STATE_UART_RX_DATA: begin
            if (byteCount == 4) begin
                nextState <= STATE_IDLE;
            end
            else begin
                nextState <= STATE_UART_RX_DATA;
            end
        end
        STATE_UART_TX_DATA: begin
            if (byteCount == 5) begin //hack, this only sends 4 bytes >.>
                nextState <= STATE_IDLE;
            end
            else begin
                nextState <= STATE_UART_TX_DATA;
            end
        end
        default: begin
            nextState <= STATE_IDLE;
        end
    endcase
end         

always@(*) begin
    case (currentState) 
        STATE_RESET: begin
            data_we <= 4'b0;
            data_rst <= 1;
            addr_we <= 0;
            addr_rst <= 1;
            byte_count_en <= 0;
            byte_count_rst <= 1;
            data_tx_valid <= 0;
            tx_parallel_rst <= 1;
            tx_parallel_we <= 0;
            if_out_valid <= 0;
        end
        STATE_IDLE: begin
            data_we <= 4'b0;
            data_rst <= 1;
            addr_we <= 1;
            addr_rst <= 0;
            byte_count_en <= 0;
            byte_count_rst <= 1;
            data_tx_valid <= 0;
            tx_parallel_rst <= 0;
            tx_parallel_we <= 1;
            if_out_valid <= 0;
        end
        STATE_UART_RX_DATA: begin
            if (data_rx_valid) begin
                byte_count_en <= 1;
                case (byteCount) 
                    3'b000: data_we <= 4'b0001;
                    3'b001: data_we <= 4'b0010;
                    3'b010: data_we <= 4'b0100;
                    3'b011: data_we <= 4'b1000;
                    default: data_we <= 4'b0000;
                endcase
            end
            else begin
                byte_count_en <= 0;
                data_we <= 4'b0;
            end
            data_rst <= 0;
            addr_we <= 0;
            addr_rst <= 0;
            if (byteCount == 4) begin
                byte_count_rst <= 1;
                if_out_valid <= 1;
            end
            else begin
                byte_count_rst <= 0;
                if_out_valid <= 0;
            end
            data_tx_valid <= 0;
            tx_parallel_we <= 0;
            tx_parallel_rst <= 0;
        end
        STATE_UART_TX_DATA: begin
            data_we <= 4'b0;
            data_rst <= 0;
            addr_we <= 0;
            addr_rst <= 0;
            byte_count_rst <= 0;
            if (!busy) begin
                byte_count_en <= 1;
                data_tx_valid <= 1;
            end
            else begin
                byte_count_en <= 0;
                data_tx_valid <= 0;
            end
            tx_parallel_we <= 0;
            tx_parallel_rst <= 0;
            if_out_valid <= 0;
        end
        default: begin
            data_we <= 4'b0;
            data_rst <= 0;
            addr_we <= 0;
            addr_rst <= 0;
            byte_count_en <= 0;
            byte_count_rst <= 0;
            data_tx_valid <= 0;
            tx_parallel_we <= 0;
            tx_parallel_rst <= 0;
            if_out_valid <= 0;
        end
    endcase
end       
endmodule
