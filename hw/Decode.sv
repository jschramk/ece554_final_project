module Decode 
 #(
    DATAW=32,
    INSTRW=16,
    IMMW=11,
    NUMREGISTERS=8,
    REGW=3
  ) (
    input clk, rst_n, reg_wr_en_in,
    input [REGW-1:0] wr_reg,
    input [INSTRW-1:0] instr,
    input [DATAW-1:0] wr_data,
    output halt, alu_op, reg_wr_en_out, mem_wr_en, 
            branch, fft_wr_en, set_en, syn, use_imm, set_freq,
    output [1:0] shift_dist,
    output [REGW-1:0] wr_reg_out,
    output [IMMW-1:0] imm,
    output [DATAW-1:0] a, b
  );

  logic [REGW-1:0] reg1, reg2;

  assign wr_reg_out = reg1;

    Decoder #() controller
        (
          .instr(instr), .halt(halt), .alu_op(alu_op), 
          .reg_wr_en(reg_wr_en_out), .mem_wr_en(mem_wr_en),
          .branch(branch), .fft_wr_en(fft_wr_en), .set_en(set_en),
          .syn(syn), .use_imm(use_imm), .set_freq(set_freq),
          .shift_dist(shift_dist),
          .reg1(reg1), .reg2(reg2), .imm(imm)
        );

    Register #(.NUMREGISTERS(NUMREGISTERS), .DATAW(DATAW)) register
        (
          .rd_reg1(reg1), .rd_reg2(reg2), .wr_reg(wr_reg),
          .wr_reg_en(reg_wr_en_in), .rst_n(rst_n), .clk(clk),
          .wr_reg_data(wr_data), .reg1_data(a), .reg2_data(b)
        );

endmodule