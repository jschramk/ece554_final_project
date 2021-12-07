module ComplexAdder #(
    parameter SIZE = 16,
    parameter FRAC_BITS = 8
) (
    input [SIZE-1:0] a_real, b_real, a_complex, b_complex,
    output [SIZE-1:0] sum_real, sum_complex
);

/*assign a_real = a[2*SIZE-1:2*SIZE-1 - SIZE];
assign a_complex = a[SIZE-1:0];
assign b_real = b[2*SIZE-1:2*SIZE-1 - SIZE];
assign b_complex = b[SIZE-1:0];*/

Adder #(
    .SIZE(SIZE)
) realAdder (
    .a(a_real),
    .b(b_real),
    .sum(sum_real)
);

Adder #(
    .SIZE(SIZE)
) complexAdder (
    .a(a_complex),
    .b(b_complex),
    .sum(sum_complex)
);

endmodule