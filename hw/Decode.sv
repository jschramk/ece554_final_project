module Decode 
 #(
    NUMREGISTERS=8,
    DATAW=32
  ) (
    input [15:0] instr,
    input reg_wr_en_in, rst_n, clk
    input [2:0] wr_reg,
    input [DATAW-1:0] wr_data,
    output [DATAW-1:0] a, b,
    output [10:0] imm,
    output [1:0] shift_dist,
    output halt, alu_op, reg_wr_en_out, mem_wr_en, branch, fft_wr_en, set_en, syn, use_imm, set_freq,
  );

    Decoder #() controller
        (
            .instr(instr),
            .halt(halt), .alu_op(alu_op), .reg_wr_en(reg_wr_en_out), .mem_wr_en(mem_wr_en),
            .branch(branch), .fft_wr_en(fft_wr_en), .set_en(set_en), .syn(syn), .use_imm(use_imm), .set_freq(set_freq),
            .shift_dist(shift_dist),
            .reg1(reg1), .reg2(reg2)
        );

    Register #(.NUMREGISTERS(NUMREGISTERS), .DATAW(DATAW)) register
        (
            .rd_reg1(reg1), .rd_reg2(reg2), .wr_reg(wr_reg), .wr_reg_en(wr_reg_en_in), .rst_n(rst_n), .clk(clk), .wr_reg_data(wr_reg_data_in), .reg1_data(a), .reg2_data(b)
        );

endmodule