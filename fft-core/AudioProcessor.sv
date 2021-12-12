module AudioProcessor #(
    parameter INPUT_SIZE = 512,
    parameter SAMPLES = 2048
)(
    // control inputs
    input clk, rst_n,
    // input wave data (LDE instruction)
    input data_wr_en,
    input [$clog2(INPUTS_TO_FILL)-1:0] input_index,
    input [INPUT_SIZE-1:0] data_in,
    // pitch shift (SPM instruction)
    input pitch_shift_wr_en,
    input [4:0] pitch_shift_semitones,
    // frequency coefficients (SFC instruction)
    input freq_coeff_wr_en,
    input [$clog2(SAMPLES)-1:0] freq_coeff_index,
    input [15:0] freq_coeff_in,
    // output select
    input [$clog2(INPUTS_TO_FILL)-1:0] output_index,
    // output wave data (STE instruction)
    output [INPUT_SIZE-1:0] data_out

);

localparam INPUTS_TO_FILL = SAMPLES * SIZE / INPUT_SIZE; // 64
localparam SAMPLES_PER_INPUT = INPUT_SIZE / SIZE; // 32



endmodule