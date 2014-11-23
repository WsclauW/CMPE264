`timescale 1ns / 1ps

module tb_cpu();

reg clk50MHz;
reg clk_uart;
reg reset;
wire [31:0] writedata;
wire [31:0] dataaddr;
wire memwrite;
reg uart_tx;
wire uart_rx;

cpu_top cpu(.clk(clk50MHz),
            .reset(reset), 
            .writedata(writedata),
            .dataadr(dataddr), 
            .memwrite(memwrite),
            .uart_rx(uart_tx),
            .uart_tx(uart_rx));
            
reg uart_counter;
reg [39:0] uart_tx_data;
            
initial begin
    clk50MHz = 0;
    clk_uart = 0;
    reset = 1;
    uart_tx = 1;
    uart_counter = 0;
    uart_tx_data = 40'h00FAFA1313;
    #100
    writeUARTFrame(uart_tx_data[39:32]);
    writeUARTFrame(uart_tx_data[7:0]);
    writeUARTFrame(uart_tx_data[15:8]);
    writeUARTFrame(uart_tx_data[23:16]);
    writeUARTFrame(uart_tx_data[31:24]);
end

always begin
    #10 clk50MHz = ~clk50MHz;
end

parameter UART_BAUD = 9600;
parameter INPUT_CLOCK_HZ = 50000000;
parameter INPUT_CLOCK_PERIOD = 20;

parameter CLOCKS_BETWEEN_BITS = INPUT_CLOCK_HZ / (UART_BAUD);
parameter CLOCKS_BETWEEN_BITS_HALF = CLOCKS_BETWEEN_BITS / 2;
parameter NS_BETWEEN_BITS_HALF = CLOCKS_BETWEEN_BITS_HALF * INPUT_CLOCK_PERIOD;

always begin
    #NS_BETWEEN_BITS_HALF clk_uart = ~clk_uart;
end

integer i;
task writeUARTFrame;
input[7:0] frame;
begin
    @(posedge clk_uart) begin // start bit
        uart_tx = 0;
    end
	for (i = 0; i < 8; i = i + 1) begin
		@(posedge clk_uart)
			uart_tx = frame[i];
	end
	@(posedge clk_uart) begin // stop bit
        uart_tx = 1;
    end
    @(posedge clk_uart) begin // stop bit 2
        uart_tx = 1;
    end
end
endtask

endmodule
