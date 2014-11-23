//------------------------------------------------
// mipsmemsingle.v
// David_Harris@hmc.edu 23 October 2005
// External memories used by MIPS single-cycle
// processor
//------------------------------------------------

module dmem(input         clk, we,
            input  [31:0] a, wd,
            output [31:0] rd);

  reg  [31:0] RAM[63:0];

  assign rd = RAM[a[31:2]]; // word aligned

  always @(posedge clk)
    if (we)
      RAM[a[31:2]] <= wd;
endmodule

module imem(input  [5:0] a,
            input [31:0] wd,
            input        we,
            input        clk,
            output [31:0] rd);

  reg  [31:0] RAM[31:0];

  always@(posedge clk) begin
    if (we) begin
        RAM[a] = wd;
    end
  end

  assign rd = RAM[a]; // word aligned
endmodule

// imem must currently be created with CoreGen for Xilinx synthesis
// or loaded from imem.v for simulation