module Equalizer #(
    parameter SIZE = 44,
    parameter SAMPLES = 2048,
    parameter COEFF_BITS = 8,
    parameter COEFF_FRACTION_BITS = 5
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

wire signed [COEFF_BITS:0] signed_coeff;
wire signed [SIZE/2-1:0] in_real, in_complex;
wire signed [SIZE/2+COEFF_BITS : 0] mult_real;
wire signed [SIZE/2+COEFF_BITS : 0] mult_complex;
wire [SIZE/2-1:0] real_out, complex_out;

assign in_real = data_in[SIZE-1:SIZE/2];
assign in_complex = data_in[SIZE/2-1:0];

assign signed_coeff = {1'b0, coeffs[input_index]};

assign mult_real = in_real * signed_coeff;
assign mult_complex = in_complex * signed_coeff;


// saturating fixed point signed multiply
/*
25'bxxxx_xxxxxxxxxxxxxxxx_xxxxx
    ^    ^                ^
    |    output bits      fraction bits (cut off)
    |
    overflow bits
*/
assign real_out = mult_real[SIZE/2+COEFF_BITS-1] ? // is negative?
    (~&mult_real[SIZE/2+COEFF_BITS : SIZE/2+COEFF_FRACTION_BITS - 1] ? {1'b1, {(SIZE/2-1){1'b0}}} : mult_real[SIZE/2+COEFF_FRACTION_BITS-1 : COEFF_FRACTION_BITS]) : // negative case
    (|mult_real[SIZE/2+COEFF_BITS : SIZE/2+COEFF_FRACTION_BITS - 1] ? {1'b0, {(SIZE/2-1){1'b1}}} : mult_real[SIZE/2+COEFF_FRACTION_BITS-1 : COEFF_FRACTION_BITS]); // positive case

assign complex_out = mult_complex[SIZE/2+COEFF_BITS-1] ? // is negative?
    (~&mult_complex[SIZE/2+COEFF_BITS : SIZE/2+COEFF_FRACTION_BITS - 1] ? {1'b1, {(SIZE/2-1){1'b0}}} : mult_complex[SIZE/2+COEFF_FRACTION_BITS-1 : COEFF_FRACTION_BITS]) : // negative case
    (|mult_complex[SIZE/2+COEFF_BITS : SIZE/2+COEFF_FRACTION_BITS - 1] ? {1'b0, {(SIZE/2-1){1'b1}}} : mult_complex[SIZE/2+COEFF_FRACTION_BITS-1 : COEFF_FRACTION_BITS]); // positive case


always @(posedge clk, negedge rst_n) begin

    if(~rst_n) begin

        // reset all values to 1
        for(int i = 0; i < SAMPLES; i++) coeffs[i] <= 1 << COEFF_FRACTION_BITS;

    end else if (coeff_wr_en) begin
        
        coeffs[coeff_index] <= coeff_in;

    end

end

assign data_out = {real_out, complex_out};

endmodule