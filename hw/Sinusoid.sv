module Sinusoid (
    input clk,
    input mode, // 0: sine, 1: cosine
    input signed [15:0] x,
    output signed [49:0] y
);

localparam signed PI =  16'sb00000011_00100100;
localparam signed _4 =  16'sb00000100_00000000;
localparam signed _5 =  16'sb00000101_00000000;
localparam signed _16 = 16'sb00010000_00000000;

wire signed [48:0] numerator;
wire signed [47:0] denom1;
wire signed [48:0] denom2;
wire signed [49:0] denominator;

assign numerator = _16 * x * (PI - x);  // 16 + 16 + 17 bits; 24 fractional bits
assign denom1 = _5 * PI * PI;           // 16 + 16 + 16 bits; 24 fractional bits
assign denom2 = _4 * x * (PI - x);      // 16 + 16 + 17 bits; 24 fractional bits
assign denominator = {denom1[47], denom1} - denom2;
assign y = numerator / denominator;

endmodule


