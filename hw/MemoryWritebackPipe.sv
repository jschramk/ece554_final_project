module MemoryWritebackPipe
#(
    DATAW=16,
    ADDRW=32
 ) (
    // Input
    input clk, flush, stall,
    input valid_in, fft_wr_en_in, reg_wr_en_in,
    input [ADDRW-1:0] addr_in,
    input [DATAW-1:0] data_in,

    // Outputs
    output logic valid_out, fft_wr_en_out, reg_wr_en_out,
    output logic [ADDRW-1:0] addr_out,
    output logic [DATAW-1:0] data_out
 );

    always_ff @(posedge clk) begin
        if (flush) begin
            valid_out = 0;
            fft_wr_en_out = 0;
            reg_wr_en_out = 0;
            addr_out = 0;
            data_out = 0;
        end else begin
            if (!stall) begin
                valid_out = valid_in;
                fft_wr_en_out = fft_wr_en_in;
                reg_wr_en_out = reg_wr_en_in;
                addr_out = addr_in;
                data_out = data_in;
            end
        end
    end

endmodule