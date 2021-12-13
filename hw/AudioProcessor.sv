module AudioProcessor #(
    parameter SIZE = 16,
    parameter INPUT_SIZE = 512,
    parameter SAMPLES = 2048,
    parameter COEFF_BITS = 8
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
    input [COEFF_BITS-1:0] freq_coeff_in,
    // output select
    input [$clog2(INPUTS_TO_FILL)-1:0] output_index,
    // output wave data (STE instruction)
    output [INPUT_SIZE-1:0] data_out

    // might have to add a done flag for when
    // the whole process is complete and the CPU can grab the data

);

// states for computation
typedef enum {
    IDLE, // waiting for start, FFTInput can be written to
    FEEDING_FFT, // waiting for all values to be passed into the fft
    FFT_COMPUTING, // fft had been fed all inputs but has not started to output
    FFT_OUTPUTTING, // fft is ouputting its values and passing them into pitch shift
    APPLYING_FILTERS, // pitch shift is outputting its values (equalizer too, since it arrives on the same clock)
    IFFT_COMPUTING,
    IFFT_OUTPUTTING
} state_t;

state_t state, next_state;

localparam INPUTS_TO_FILL = SAMPLES * SIZE / INPUT_SIZE; // 64
localparam SAMPLES_PER_INPUT = INPUT_SIZE / SIZE; // 32

// module connections
wire fft_sync, ifft_sync;
wire [15:0] fft_sample_in;
wire [31:0] fft_output_full; // 16 real bits, 16 complex bits
wire [31:0] ifft_output_full; // 16 real bits, 16 complex bits
wire [31:0] pitch_shift_output_full; // 16 real bits, 16 complex bits
wire [31:0] equalizer_output_full; // 16 real bits, 16 complex bits

// control signals from state machine
reg [$clog2(SAMPLES)-1:0] sample_counter; // counter for different stages
reg count_en, rst_count;
reg fft_enable, ifft_enable;
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
    ifft_enable = 0;
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
                next_state = APPLYING_FILTERS;
            end

        end

        APPLYING_FILTERS : begin

            count_en = 1;
            ifft_enable = 1; // feeding output as filters are computed

            if(&sample_counter) begin
                rst_count = 1;
                next_state = IFFT_COMPUTING;
            end

        end

        IFFT_COMPUTING : begin

            ifft_enable = 1;

            if(ifft_sync)begin
                rst_count = 1;
                next_state = IFFT_OUTPUTTING;
            end

        end

        IFFT_OUTPUTTING : begin

            count_en = 1;
            ifft_enable = 1;

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

PitchShift ps(
    .clk(clk),
    .rst_n(rst_n),
    .data_in(fft_output_full),
    .data_out(pitch_shift_output_full),
    .shift_semitones(pitch_shift_semitones),
    .shift_wr_en(pitch_shift_wr_en),
    .en(pitch_shift_enable),
    .input_index(sample_counter),
    .output_index(sample_counter)
);

Equalizer eq (
    .clk(clk),
    .rst_n(rst_n),
    .input_index(sample_counter),
    .data_in(pitch_shift_output_full),
    .coeff_wr_en(freq_coeff_wr_en),
    .coeff_index(freq_coeff_index),
    .coeff_in(freq_coeff_in),
    .data_out(equalizer_output_full)
);

ifftmain ifft(
    .i_clk(clk),
    .i_reset(~rst_n),
    .i_ce(ifft_enable),
	.i_sample(equalizer_output_full),
    .o_result(ifft_output_full),
    .o_sync(ifft_sync)
);

endmodule