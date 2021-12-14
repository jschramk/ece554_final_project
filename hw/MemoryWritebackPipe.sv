module MemoryWritebackPipe
#(
    INW=512,
    ADDRW=32,
    DATAW=32,
    IMMW=11,
    REGW=3
 ) (
    // Input
    input clk, flush, stall,
    input valid_in, fft_wr_en_in, reg_wr_en_in, syn_in,
            set_en_in, set_freq_in,
    input [REGW-1:0] wr_reg_in,
    input [IMMW-1:0] imm_in,
    input [ADDRW-1:0] addr_in,
    input [INW-1:0] data_in,

    // Outputs
    output logic valid_out, fft_wr_en_out, reg_wr_en_out, syn_out,
                set_en_out, set_freq_out,
    output logic [REGW-1:0] wr_reg_out,
    output logic [IMMW-1:0] imm_out,
    output logic [ADDRW-1:0] addr_out,
    output logic [INW-1:0] data_out
 );

    always_ff @(posedge clk) begin
        if (flush) begin
            valid_out = 0;
            fft_wr_en_out = 0;
            reg_wr_en_out = 0;
            syn_out = 0;
            set_en_out = 0;
            set_freq_out = 0;
            wr_reg_out = 0;
            addr_out = 0;
            data_out = 0;
        end else begin
            if (!stall) begin
                valid_out = (valid_out) ? 0 : valid_in;
                fft_wr_en_out = fft_wr_en_in;
                reg_wr_en_out = reg_wr_en_in;
                syn_out = syn_in;
                set_en_out = set_en_in;
                set_freq_out = set_freq_in;
                wr_reg_out = wr_reg_in;
                addr_out = addr_in;
                data_out = data_in;
            end else begin
                syn_out = 0;
            end
        end
    end

endmodule