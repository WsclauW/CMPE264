module system_top(input clk50MHz,
                  input reset,
                  input rx,
                  output tx);

cpu_top cpu_module(.clk(clk50MHz),
                   .reset(reset),
                   .writedata(),
                   .dataadr(),
                   .memwrite(),
                   .uart_rx(rx),
                   .uart_tx(tx));
                   
endmodule
