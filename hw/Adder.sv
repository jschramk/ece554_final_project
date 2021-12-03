module Adder #(
    parameter SIZE = 16
) (
    input [SIZE-1:0] a, b,
    output [SIZE-1:0] sum
);

wire [SIZE-1:0] sum_full;

assign sum_full = a + b;

assign sum = sum_full[SIZE-1] ?
    ((~a[SIZE-1] & ~b[SIZE-1]) /* both inputs positive? */ ? {1'b0, {(SIZE-1){1'b1}}} /* largest positive output */ : sum_full) : // result negative
    (( a[SIZE-1] &  b[SIZE-1]) /* both inputs negative? */ ? {1'b1, {(SIZE-1){1'b0}}} /* largest negative output */ : sum_full);  // result positive
    
endmodule