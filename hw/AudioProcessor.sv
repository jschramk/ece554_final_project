module AudioProcessor #(
    parameter SIZE = 16,
    parameter INPUT_SIZE = 512,
    parameter SAMPLES = 2048,
    parameter COEFF_BITS = 8,
    parameter FFT_BUS_SIZE = 44,
    parameter IFFT_BUS_SIZE = 56
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
    // overdrive
    input overdrive_enable_wr_en, // write enable for OD enable bus
    input overdrive_enable_in,
    input overdrive_magnitude_wr_en,
    input [3:0] overdrive_magnitude,
    // tremolo
    input tremolo_enable_wr_en,
    input tremolo_enable_in,
    // output select
    input [$clog2(INPUTS_TO_FILL)-1:0] output_index,
    // output wave data (STE instruction)
    output [INPUT_SIZE-1:0] data_out,
    // flag for when data is ready to be read back out
    output done
);

// states for computation
typedef enum {
    IDLE, // waiting for start, FFTInput can be written to
    FEEDING_FFT, // waiting for all values to be passed into the fft
    FFT_COMPUTING, // fft has been fed all inputs but has not started to output
    FFT_OUTPUTTING, // fft is ouputting its values and passing them into pitch shift
    APPLYING_FILTERS, // pitch shift is outputting its values (equalizer too, since it arrives on the same clock)
    IFFT_COMPUTING, // ifft has been fed all inputs but has not started to ouput
    IFFT_OUTPUTTING // ifft is outputting and time domain modules are applying their effects, result saved to fftoutput
} state_t;

state_t state, next_state;

localparam INPUTS_TO_FILL = SAMPLES * SIZE / INPUT_SIZE; // 64
localparam SAMPLES_PER_INPUT = INPUT_SIZE / SIZE; // 32

// module connections
wire fft_sync, ifft_sync;
wire [15:0] fft_sample_in;
wire [FFT_BUS_SIZE-1:0] fft_output_full; // 16 real bits, 16 complex bits
wire [IFFT_BUS_SIZE-1:0] ifft_output_full; // 16 real bits, 16 complex bits
wire [FFT_BUS_SIZE-1:0] pitch_shift_output_full; // 16 real bits, 16 complex bits
wire [FFT_BUS_SIZE-1:0] equalizer_output_full; // 16 real bits, 16 complex bits
wire [IFFT_BUS_SIZE/2-1:0] ifft_output_real;
wire [IFFT_BUS_SIZE/2-1:0] ifft_output_imag;

wire [15:0] tremolo_out, overdrive_out;

// control signals from state machine
reg [$clog2(SAMPLES)-1:0] sample_counter; // counter for different stages
reg count_en, rst_count;
reg fft_enable, ifft_enable;
reg pitch_shift_enable;
reg tremolo_enable, overdrive_enable;
reg fft_out_wr_en;
reg fft_rst, ifft_rst;
reg clr_buckets;

assign ifft_output_real = ifft_output_full[IFFT_BUS_SIZE-1:IFFT_BUS_SIZE/2];
assign ifft_output_imag = ifft_output_full[IFFT_BUS_SIZE/2:0];

// dff for tremolo enable
always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        tremolo_enable <= 0;
    end else if(tremolo_enable_wr_en) begin
        tremolo_enable <= tremolo_enable_in;
    end
end

// dff for overdrive enable
always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        overdrive_enable <= 0;
    end else if(overdrive_enable_wr_en) begin
        overdrive_enable <= overdrive_enable_in;
    end
end

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

assign done = (state == IDLE);

// control logic state machine
always_comb begin
    
    next_state = state;
    fft_enable = 0;
    ifft_enable = 0;
    pitch_shift_enable = 0;
    count_en = 0;
    rst_count = 0;
    fft_out_wr_en = 0;
    fft_rst = 0;
    ifft_rst = 0;
    clr_buckets = 0;
    //done = 0;


    case (state)

        IDLE : begin

            //done = 1;

            fft_rst = 1;
            ifft_rst = 1;
            clr_buckets = 1;

            if(start) begin
                next_state = FEEDING_FFT;
                //done = 0;
            end

        end

        FEEDING_FFT : begin

            count_en = 1;
            fft_enable = 1;

            if(sample_counter == SAMPLES-1) begin
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

            if(sample_counter == SAMPLES/2-1) begin
                rst_count = 1;
                next_state = APPLYING_FILTERS;
            end

        end

        APPLYING_FILTERS : begin

            count_en = 1;
            ifft_enable = 1; // feeding output as filters are computed

            if(sample_counter == SAMPLES/2-1) begin
                rst_count = 1;
                next_state = IFFT_COMPUTING;
            end

        end

        IFFT_COMPUTING : begin

            ifft_enable = 1;

            if(ifft_sync)begin
                rst_count = 1;
                fft_out_wr_en = 1;
                next_state = IFFT_OUTPUTTING;
            end

        end

        IFFT_OUTPUTTING : begin

            count_en = 1;
            ifft_enable = 1;
            fft_out_wr_en = 1;

            if(sample_counter == SAMPLES-1) begin
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
    .i_reset(~rst_n | fft_rst),
    .i_ce(fft_enable),
	.i_sample({fft_sample_in, 16'b0}), // feed samples with zeroed complex bits
    .o_result(fft_output_full),
    .o_sync(fft_sync)
);

PitchShift ps(
    .clk(clk),
    .rst_n(rst_n),
    .clr_buckets(clr_buckets),
    .data_in(fft_output_full),
    .data_out(pitch_shift_output_full),
    .shift_semitones(pitch_shift_semitones),
    .shift_wr_en(pitch_shift_wr_en),
    .en(pitch_shift_enable),
    .input_index(sample_counter),
    .output_index(sample_counter)
);

Equalizer eq(
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
    .i_reset(~rst_n | ifft_rst),
    .i_ce(ifft_enable),
	.i_sample(equalizer_output_full),
    .o_result(ifft_output_full),
    .o_sync(ifft_sync)
);

Overdrive od(
    .clk(clk),
    .rst_n(rst_n),
    .en(overdrive_enable),
    .magnitude(overdrive_magnitude), // 4 bits
    .set_magnitude(overdrive_magnitude_wr_en),
    .audio_in(ifft_output_real[15:0]), // <-------------- check this clipped output in case of issues
    .audio_out(overdrive_out)
);

Tremolo trem(
    .clk(clk),
    .rst_n(rst_n),
    .en(tremolo_enable),
    .audio_in(overdrive_out),
    .audio_out(tremolo_out)
);

FFTOutput out(
    .clk(clk),
    .rst_n(rst_n),
    .data_out(data_out),
    .output_index(output_index),
    .input_index(sample_counter), // 11 bits
    .wr_en(fft_out_wr_en),
    .data_in(tremolo_out) // 16 bits
);

endmodule