module PitchShift #(
    parameter SIZE = 32,
    parameter SAMPLES = 2048
) (
    input clk, rst_n,
    input [SIZE-1:0] data_in, // input value from fft
    output [SIZE-1:0] data_out, // output value from fft, pretty much a passthru for convenience
    input [4:0] shift_semitones, // -12 to 12
    input shift_wr_en, // write enable for shift_semitones
    input en, // enable for actually computing pitch shift
    input [$clog2(SAMPLES)-1:0] input_index, // index of source frequency bucket from pitch shift
    input [$clog2(SAMPLES)-1:0] output_index // index of frequency bucket to read back out
);

reg [4:0] semitones;
wire [15:0] semi_lut_out;
wire [3:0] mult_overflow;

wire [$clog2(SAMPLES)-1:0] write_index; // index of destination frequency bucket from pitch shift

// store values so they can be read out later
reg [SIZE-1:0] values [SAMPLES-1:0];

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
assign write_index = index_mult[$clog2(SAMPLES)-1 + 16 - 4:12];

assign mult_overflow = index_mult[$clog2(SAMPLES)-1 + 16:$clog2(SAMPLES)-1 + 16 - 3];

assign data_out = values[output_index];

always @(posedge clk, negedge rst_n) begin

    if(~rst_n) begin

        semitones <= 0;

        for(int i = 0; i < SAMPLES; i++) values[i] <= 0;

    end else begin
    
        if(shift_wr_en) semitones <= shift_semitones;

        // add real and complex components separately
        if(en & ~|mult_overflow) values[write_index] <= {
            $signed(values[write_index][SIZE-1:SIZE/2]) + $signed(data_in[SIZE-1:SIZE/2]),
            $signed(values[write_index][SIZE/2-1:0]) + $signed(data_in[SIZE/2-1:0])
        };

    end

end



endmodule