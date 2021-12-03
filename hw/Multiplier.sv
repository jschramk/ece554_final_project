// saturating fixed-point multiplier
module Multiplier #(
    parameter SIZE = 16,
    parameter FRAC_BITS = 8
)(
    input [SIZE-1:0] a,
    input [SIZE-1:0] b,
    output [SIZE-1:0] out
);

wire signed [2*SIZE-1:0] prod;

assign prod = a * b; // 16 fractional bits

assign out = prod[2*SIZE-1] ? // result negative?
    (&prod[2*SIZE-1 : 2*SIZE-1 - (SIZE - FRAC_BITS)] ? prod[2*SIZE-1 -  FRAC_BITS : FRAC_BITS] : {1'b1, {(SIZE-1){1'b0}}}) : // negative case
    (|prod[2*SIZE-1 : 2*SIZE-1 - (SIZE - FRAC_BITS)] ? {1'b0, {(SIZE-1){1'b1}}} : prod[2*SIZE - 1 - FRAC_BITS :  FRAC_BITS]); // positive case

endmodule