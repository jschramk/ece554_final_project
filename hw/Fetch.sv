module Fetch 
 #(
    PCW=32
  ) (
    input clk, rst_n, halt, stall, branch,
    input [PCW-1:0] PC_branch, PC_out
  );



    ProgramCounter #(.PCW(PCW)) pc 
       (.rst_n(rst_n), .clk(clk), .halt(halt), .stall(stall),
        .branch(branch), .PC_branch(PC_branch), .PC_out(PC_out));


endmodule