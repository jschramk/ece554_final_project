module Fetch 
 #(
    PCW=32,
    INSTRW=16,
    INW=512
  ) (
    input clk, rst_n, halt, stall, branch, instr_write_en,
    input [PCW-1:0] PC_branch,
    input [INW-1:0] instr_in,
    output valid_out,
    output [INSTRW-1:0] instr_out,
    output [PCW-1:0] PC_out
  );

  ProgramCounter #(.PCW(PCW)) pc 
       (.rst_n(rst_n), .clk(clk), .halt(instr_out[15:11] == 5'b00000), .stall(stall),
        .branch(branch), .PC_branch(PC_branch), .PC_out(PC_out));

  InstructionCache #() instr_cache 
       (.clk(clk), .rst_n(rst_n), .write(instr_write_en),
        .data_in(instr_in), .addr_in(PC_out), .base_addr_in(PC_out),
        .valid_out(valid_out), .data_out(instr_out));

endmodule