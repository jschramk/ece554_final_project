// saturating 16-bit multiplier
module Multiplier (
    input signed [15:0] a,
    input signed [15:0] b,
    output signed [15:0] out
);

wire signed [31:0] prod;

assign prod = a * b; // 16 fractional bits

assign out = prod[31] ? 
    (&prod[31:23] ? prod[23:8] : {8'b10000000, prod[15:8]}) : // negative case
    (|prod[30:23] ? {8'b01111111, prod[15:8]} : prod[23:8]); // positive case

endmodule