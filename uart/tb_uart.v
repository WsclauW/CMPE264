`timescale 1ns / 1ps

module tb_uart();

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
            
wire [7:0] uart_rx_data;
wire uart_rx_data_valid;
uart uart_rx_module(.clk(clk50MHz),
             .rx(uart_rx),
             .data_out(uart_rx_data),
             .data_out_valid(uart_rx_data_valid),
             .data_in_valid(0));
            
reg uart_counter;
reg [39:0] uart_tx_data;

reg [5:0] mips_opcode;
reg [4:0] mips_reg_s;
 
integer j;     
initial begin
    clk50MHz = 0;
    clk_uart = 0;
    reset = 1;
    uart_tx = 1;
    uart_counter = 0;
    
    mips_opcode = 6'b001000; // addi
    mips_reg_s = 5'b0;       // $0
    #100
    // Write an "addi" to each space in the reg file. Instr in imm[1] writes 1 to $r1, instr in imm[2] writes 2 to $r2, etc
    for (j = 0; j < 32; j = j+1) begin
        uart_tx_data = {1'b1,  // we
                        j[6:0], // addr
                        mips_opcode,
                        mips_reg_s, 
                        j[4:0], // destination reg
                        j[15:0] // imm value
                        };
         writeUARTFrame(uart_tx_data[39:32]);
         writeUARTFrame(uart_tx_data[7:0]);
         writeUARTFrame(uart_tx_data[15:8]);
         writeUARTFrame(uart_tx_data[23:16]);
         writeUARTFrame(uart_tx_data[31:24]);
    end
    
    reset = 0;
    #1000 // let instructions execute
    reset = 1;
    
    for (j = 0; j < 32; j = j+1) begin
        writeUARTFrame({1'b0, j[6:0]}); // read from address j
        @(posedge uart_rx_data_valid) begin
            if (uart_rx_data != j) begin
                $display("ERROR");
            end
        end
    end 
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
