module Synth #(
    parameter SIZE = 16
) (
    input rst_n, clk, wr_en, clr,
    input [SIZE-1:0] magnitude,
    input [10:0] frequency, // represents frequency bin
    input [SIZE-1:0] phase,
    input [10:0] x,
    output [SIZE-1:0] out
);

reg [BIN_COUNT-1:0] sum;

wire [23] mult; // wire for unsigned multiplication of frequency * x, one extra bit for sign
wire [23] phase_sign_ext;

wire [SIZE + 11:0] sine_in;
wire [SIZE-1:0] sine_out;

// out = mag * sin(f*x + p)
// x is [0, 2047]

assign mult = frequency * x;
assign phase_sign_ext = {{(7){phase[SIZE-1]}}, phase};
assign sine_in = mult;

SineLUT s(
    .in(sine_in[10:0]),
    .out(sine_out)
);

endmodule