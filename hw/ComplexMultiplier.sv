// (a + bi)(c + di) = (ac - bd) + (ad + bc)i
module ComplexMultipler #(
    parameter SIZE = 16,
    parameter FRAC_BITS = 8
) (
    input [SIZE-1:0] a_real, b_real, a_complex, b_complex,
    output [SIZE-1:0] out_real, out_complex
);

wire [SIZE-1:0] m1_out, m2_out, m3_out, m4_out;

wire [SIZE-1:0] m2_neg;

assign m2_neg = (m2_out == {1'b1, {(SIZE-1){1'b0}}}) ? // m2 output is max negative value
    {1'b0, {(SIZE-1){1'b1}}} : // max positive value
    ~m2_out + 1'b1;

Multiplier #(
    .SIZE(SIZE),
    .FRAC_BITS(FRAC_BITS)
) m1 (
    .a(a_real),
    .b(b_real),
    .out(m1_out)
);

Multiplier #(
    .SIZE(SIZE),
    .FRAC_BITS(FRAC_BITS)
) m2 (
    .a(a_complex),
    .b(b_complex),
    .out(m2_out)
);

Multiplier #(
    .SIZE(SIZE),
    .FRAC_BITS(FRAC_BITS)
) m3 (
    .a(a_real),
    .b(b_complex),
    .out(m3_out)
);

Multiplier #(
    .SIZE(SIZE),
    .FRAC_BITS(FRAC_BITS)
) m4 (
    .a(a_complex),
    .b(b_real),
    .out(m4_out)
);



Adder #(
    .SIZE(SIZE)
) a1 (
    .a(m1_out),
    .b(m2_neg),
    .sum(out_real)
);

Adder #(
    .SIZE(SIZE)
) a2 (
    .a(m3_out),
    .b(m4_out),
    .sum(out_complex)
);

endmodule;