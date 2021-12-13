module ExecuteMemoryPipe 
#(
    DATAW=32
 ) (
    // Inputs
    input clk, flush, stall,
    input fft_wr_en_in,
    input reg_wr_en_in,
    input [DATAW-1:0] ex_data_in,

    // Outputs
    output logic fft_wr_en_out,
    output logic reg_wr_en_out,
    output logic [DATAW-1:0] ex_data_out
 );


    always_ff @(posedge clk) begin
        if (flush) begin
            fft_wr_en_out = 0;
            reg_wr_en_out = 0;
            ex_data_out = 0;
        end else begin
            if (!stall) begin
                fft_wr_en_out = fft_wr_en_in;
                reg_wr_en_out = reg_wr_en_in;
                ex_data_out = ex_data_in;
            end
        end
    end
endmodule