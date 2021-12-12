module AudioProcessor #(
    parameter SIZE = 16,
    parameter INPUT_SIZE = 512,
    parameter SAMPLES = 2048
)(
    // control inputs
    input clk, rst_n,
    // start processing (SYN instruction)
    input start,
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

wire fft_sync;
wire [$clog2(SAMPLES)-1:0] fft_count;
reg fft_enable;
wire [15:0] fft_sample_in;
wire [31:0] fft_output_full; // 16 real bits, 16 complex bits
wire [31:0] pitch_shift_output_full; // 16 real bits, 16 complex bits
wire [$clog2(SAMPLES)-1:0] pitch_shift_output_index;

reg [$clog2(SAMPLES)-1:0] feed_index; // counter for FFTInput's output select
reg feeding;

// control logic
always @(posedge clk, negedge rst_n) begin

    if(~rst_n) begin

        feeding <= 0;
        feed_index <= 0;
        fft_enable <= 0;

    end else if(feeding) begin // continue processing

        feed_index <= feed_index + 1;

    end else if(start) begin // start processing

        feeding <= 1;
        fft_enable <= 1;

    end

end

FFTInput in(
    .clk(clk),
    .rst_n(rst_n),
    .data_in(data_in),
    .input_index(input_index),
    .output_index(feed_index),
    .wr_en(data_wr_en),
    .data_out(fft_sample_in)
);

fftmain fft(
    .i_clk(clk),
    .i_reset(~rst_n),
    .i_ce(fft_enable),
	.i_sample({fft_sample_in, 16'b0}), // feed samples with zeroed complex bits
    .o_result(fft_output_full),
    .o_sync(fft_sync)
);

FFTCounter counter(
    .clk(clk),
    .rst_n(rst_n),
    .fft_sync(fft_sync),
    .clr_cnt(),
    .count(fft_count)
);

PitchShift ps(
    .clk(clk),
    .rst_n(rst_n),
    .data_in(fft_output_full),
    .data_out(pitch_shift_output_full),
    .shift_semitones(pitch_shift_semitones),
    .shift_wr_en(pitch_shift_wr_en),
    .input_index(fft_count),
    .output_index()
);

endmodule