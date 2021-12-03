module Decode_tb
 #(
    NUMREGISTERS=8,
    DATAW=32
  ) ();

    logic [DATAW-1:0] wr_data, a, b, exp_a, exp_b;
    logic [15:0] instr;
    logic [10:0] imm, exp_imm;
    logic [2:0] wr_reg;
    logic [1:0] shift_dist, exp_shift_dist;
    logic reg_wr_en_in, rst_n, clk, halt, alu_op, reg_wr_en_out,
        mem_wr_en, branch, fft_wr_en, set_en, syn, use_imm, set_freq,
        exp_reg_wr_en_in, exp_rst_n, exp_clk, exp_halt, exp_alu_op,
        exp_reg_wr_en_out, exp_mem_wr_en, exp_branch, exp_fft_wr_en,
        exp_set_en, exp_syn, exp_use_imm, exp_set_freq;

    Decode #(NUMREGISTERS=8,DATAW=32) DUT (
    .instr(instr), .reg_wr_en_in(reg_wr_en_in), .rst_n(rst_n), .clk(clk),
    .wr_reg(wr_reg), .wr_data(wr_data), .a(a), .b(b), .imm(imm),
    .shift_dist(shift_dist), .halt(halt), .alu_op(alu_op), .reg_wr_en_out(reg_wr_en_out),
    .mem_wr_en(mem_wr_en), .branch(branch), .fft_wr_en(fft_wr_en),
    .set_en(set_en), .syn(syn), .use_imm(use_imm), .set_freq(set_freq)
    );

    initial begin
        
    end

endmodule