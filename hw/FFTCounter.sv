module FFTCounter #(
    parameter SIZE = 32,
    parameter SAMPLES = 2048
) (
    input clk, rst_n,
    input fft_sync, clr_cnt,
    output reg [$clog2(SAMPLES)-1:0] count
);

reg counting;
    
always @(posedge clk, negedge rst_n) begin

    if(~rst_n | clr_cnt) begin

        counting <= 0;
        count <= 0;

    end else if(counting) begin
        
        count <= count + 1;

    end else if(fft_sync) begin
        
        counting <= 1;

    end

end

endmodule