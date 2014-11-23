//------------------------------------------------
// top.v
// David_Harris@hmc.edu 9 November 2005
// Top level system including MIPS and memories
//------------------------------------------------

module cpu_top(input         clk, reset, 
           output [31:0] writedata, dataadr, 
           output        memwrite,
           input uart_rx,
           output uart_tx);

  wire [31:0] pc, instr, readdata;
  
  // Connections between the UART interface and CPU
  wire [31:0] if_data_out;
  wire [31:0] if_addr_out;
  wire if_we;
  
  wire [31:0] regfile_out;
  
  // instantiate processor and memories
  wire [31:0] imem_out;
  wire [7:0] imem_addr;
  mips mips(.clk(clk),
            .reset(reset),
            .pc(pc),
            .instr(imem_out),
            .memwrite(memwrite),
            .aluout(dataadr),
            .writedata(writedata),
            .readdata(readdata),
            .uart_ra(if_addr_out),
            .uart_rd(regfile_out));
           
  // Mux between the address from PC or from the UART interface           
  mux2 imem_addr_mux(.d0(pc[7:2]),
                     .d1(if_addr_out),
                     .s(reset),
                     .y(imem_addr));
 
  imem imem(.clk(clk),
            .a(imem_addr),
            .we(if_we),
            .wd(if_data_out),
            .rd(imem_out));
  
  uartInterface uart_if(.clk50MHz(clk),
                        .rx(uart_rx),
                        .tx(uart_tx),
                        .if_data_in(regfile_out),
                        .if_data_out(if_data_out),
                        .if_addr_out(if_addr_out),
                        .if_out_valid(if_we));
  
  // Move dmem to the onboard Micron CellularRAM
  //dmem dmem(clk, memwrite, dataadr, writedata, readdata);

endmodule
