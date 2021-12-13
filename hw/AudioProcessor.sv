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

// states for computation
typedef enum {
    IDLE, // waiting for start, FFTInput can be written to
    FEEDING_FFT, // waiting for all values to be passed into the fft
    FFT_COMPUTING, // fft had been fed all inputs but has not started to output
    FFT_OUTPUTTING, // fft is ouputting its values and passing them into pitch shift
    PITCH_SHIFT_OUTPUTTING // pitch shift is outputting its values
} state_t;

state_t state, next_state;

localparam INPUTS_TO_FILL = SAMPLES * SIZE / INPUT_SIZE; // 64
localparam SAMPLES_PER_INPUT = INPUT_SIZE / SIZE; // 32

// module connections
wire fft_sync;
wire [15:0] fft_sample_in;
wire [31:0] fft_output_full; // 16 real bits, 16 complex bits
wire [31:0] pitch_shift_output_full; // 16 real bits, 16 complex bits
wire [$clog2(SAMPLES)-1:0] pitch_shift_output_index;

// control signals from state machine
reg [$clog2(SAMPLES)-1:0] sample_counter; // counter for different stages
reg count_en, rst_count;
reg fft_enable;
reg pitch_shift_enable;


// reset and state progression
always @(posedge clk, negedge rst_n) begin

    if(~rst_n) begin
        state <= IDLE;
        sample_counter <= 0;
    end else begin 
        state <= next_state;
        if(rst_count) sample_counter <= 0;
        else if(count_en) sample_counter <= sample_counter + 1;
    end

end

// control logic state machine
always_comb begin
    
    next_state = state;
    fft_enable = 0;
    pitch_shift_enable = 0;
    count_en = 0;
    rst_count = 0;

    case (state)

        IDLE : begin

            if(start) begin
                next_state = FEEDING_FFT;
            end

        end

        FEEDING_FFT : begin

            count_en = 1;
            fft_enable = 1;

            if(&sample_counter) begin
                rst_count = 1;
                next_state = FFT_COMPUTING;
            end

        end

        FFT_COMPUTING : begin

            fft_enable = 1;

            if(fft_sync)begin
                rst_count = 1;
                pitch_shift_enable = 1;
                next_state = FFT_OUTPUTTING;
            end

        end

        FFT_OUTPUTTING : begin

            count_en = 1;
            fft_enable = 1;
            pitch_shift_enable = 1;

            if(&sample_counter) begin
                rst_count = 1;
                next_state = PITCH_SHIFT_OUTPUTTING;
            end

        end

        PITCH_SHIFT_OUTPUTTING : begin

            count_en = 1;

            if(&sample_counter) begin
                rst_count = 1;
                next_state = IDLE;
            end

        end

    endcase

end

FFTInput in(
    .clk(clk),
    .rst_n(rst_n),
    .data_in(data_in),
    .input_index(input_index),
    .output_index(sample_counter),
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

/*
FFTCounter counter(
    .clk(clk),
    .rst_n(rst_n),
    .fft_sync(fft_sync),
    .clr_cnt(),
    .count(fft_count)
);
*/

PitchShift ps(
    .clk(clk),
    .rst_n(rst_n),
    .data_in(fft_output_full),
    .data_out(pitch_shift_output_full),
    .shift_semitones(pitch_shift_semitones),
    .shift_wr_en(pitch_shift_wr_en),
    .en(pitch_shift_enable),
    .input_index(sample_counter),
    .output_index()
);

endmodule