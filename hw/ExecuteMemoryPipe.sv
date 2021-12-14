module ExecuteMemoryPipe 
#(
    DATAW=32,
    IMMW=11,
    REGW=3
 ) (
    // Inputs
    input clk, flush, stall,
    input fft_wr_en_in, reg_wr_en_in,
            p_flag_in, syn_in,
            set_en_in, set_freq_in,
    input [REGW-1:0] wr_reg_in,
    input [IMMW-1:0] imm_in,
    input [DATAW-1:0] ex_data_in,

    // Outputs
    output logic fft_wr_en_out, reg_wr_en_out,
                p_flag_out, syn_out, set_en_out,
                set_freq_out,
    output logic [REGW-1:0] wr_reg_out,
    output logic [IMMW-1:0] imm_out,
    output logic [DATAW-1:0] ex_data_out
 );


    always_ff @(posedge clk) begin
        if (flush) begin
            fft_wr_en_out = 0;
            reg_wr_en_out = 0;
            p_flag_out = 0;
            syn_out = 0;
            set_en_out = 0;
            set_freq_out = 0;
            wr_reg_out = 0;
            imm_out = 0;
            ex_data_out = 0;
        end else begin
            if (!stall) begin
                fft_wr_en_out = fft_wr_en_in;
                reg_wr_en_out = reg_wr_en_in;
                p_flag_out = p_flag_in;
                syn_out = syn_in;
                set_en_out = set_en_in;
                set_freq_out = set_freq_in;
                wr_reg_out = wr_reg_in;
                imm_out = imm_in;
                ex_data_out = ex_data_in;
            end
        end
    end
endmodule