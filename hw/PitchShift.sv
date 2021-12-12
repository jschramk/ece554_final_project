module PitchShift #(
    parameter SIZE = 32,
    parameter SAMPLES = 2048
) (
    input clk, rst_n,
    input [SIZE-1:0] data_in, // input value from fft
    output [SIZE-1:0] data_out, // output value from fft, pretty much a passthru for convenience
    input [4:0] shift_semitones, // -12 to 12
    input shift_wr_en, // write enable for shift_semitones
    input [$clog2(SAMPLES)-1:0] input_index, // index of source frequency bucket from pitch shift
    output [$clog2(SAMPLES)-1:0] output_index // index of destination frequency bucket from pitch shift
);

reg [4:0] semitones;
wire [15:0] semi_lut_out;
wire [3:0] mult_overflow;

// lookup table: semitones (5 bits, -12 to 12) -> frequency coefficient (16 bits, 12 fraction bits)
SemitoneLUT semi_lut(
    .in(semitones),
    .out(semi_lut_out)
);

wire [$clog2(SAMPLES)-1 + 16:0] index_mult; // multiplication bus from SemitoneLUT and input_index, 27 bits, 12 fraction bits

assign index_mult = input_index * semi_lut_out;

/*
 27'bxxxx_xxxxxxxxxxx_xxxxxxxxxxxx
     ^    ^           ^
     |    index bits  frac bits
     |
     overflow bits (if any of these are high, the output bucket is out of range)
*/
assign output_index = index_mult[$clog2(SAMPLES)-1 + 16 - 4:12];

assign mult_overflow = index_mult[$clog2(SAMPLES)-1 + 16:$clog2(SAMPLES)-1 + 16 - 3];

assign data_out = |mult_overflow ? 0 : data_in; // pass data through (make this a dff if pipelining), if frequency bin overflowed, output 0

always @(posedge clk, negedge rst_n) begin

    if(~rst_n) begin

        semitones <= 0;

    end

    if(shift_wr_en) semitones <= shift_semitones;

end


endmodule