module Equalizer #(
    parameter SIZE = 32,
    parameter SAMPLES = 2048,
    parameter COEFF_BITS = 8,
    parameter COEFF_FRACTION_BITS = 5;
) (
    input clk, rst_n,
    input [$clog2(SAMPLES)-1:0] input_index,
    input [SIZE-1:0] data_in,
    input coeff_wr_en,
    input [$clog2(SAMPLES)-1:0] coeff_index,
    input [COEFF_BITS-1:0] coeff_in, // 8 bits unsigned
    output [SIZE-1:0] data_out
);

reg [COEFF_BITS-1:0] coeffs [SAMPLES-1:0];

always @(posedge clk, negedge rst_n) begin

    if(~rst_n) begin

        // reset all values to 1
        for(int i = 0; i < SAMPLES; i++) coeffs[i] <= 1 << COEFF_FRACTION_BITS;

    end else if (coeff_wr_en) begin
        
        coeffs[coeff_index] <= coeff_in;

    end

end


endmodule