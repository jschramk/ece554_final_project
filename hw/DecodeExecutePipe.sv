module DecodeExecutePipe 
 #(
    DATAW=32,
    PCW=32
  ) (
    input clk, flush, stall, alu_op_in, 
        reg_wr_en_in,  mem_wr_en_in, 
        shift_dist_in,  branch_in, 
        fft_wr_en_in, use_imm_in,
    input [DATAW-1:0] a_in,  b_in, 
    input [PCW-1:0] PC_in, 
    input [10:0] imm_in, 
    output alu_op_out, use_imm_out,
         reg_wr_en_out,  mem_wr_en_out,
         shift_dist_out,  branch_out,
         fft_wr_en_out,
    output [DATAW-1:0]  a_out,  b_out,
    output [PCW-1:0]  PC_out,
    output [10:0]  imm_out
  );

    always_ff @(posedge clk) begin
        if (flush) begin
            alu_op_out = 0;
            reg_wr_en_out = 0;
            mem_wr_en_out = 0;
            shift_dist_out = 0;
            branch_out = 0;
            fft_wr_en_out = 0;
            a_out = 0;
            b_out = 0;
            PC_out = 0;
            imm_out = 0;
            use_imm_out = 0;
        end else begin
            if (!stall) begin
                alu_op_out = alu_op_in;
                reg_wr_en_out = reg_wr_en_in;
                mem_wr_en_out = mem_wr_en_in;
                shift_dist_out = shift_dist_in;
                branch_out = branch_in;
                fft_wr_en_out = fft_wr_en_in;
                a_out = a_in;
                b_out = b_in;
                PC_out = PC_in;
                imm_out = imm_in;
                use_imm_out = use_imm_in;
            end
        end
    end
endmodule