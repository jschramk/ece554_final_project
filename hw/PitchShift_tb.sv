module PitchShift_tb;

reg clk, rst_n, shift_wr_en;
reg [43:0] data_in;
reg [10:0] input_index;
reg [4:0] shift_semitones;
wire [43:0] data_out;
wire [10:0] output_index;

PitchShift ps(
    .clk(clk),
    .rst_n(rst_n),
    .data_in(data_in), // input value from fft
    .data_out(data_out), // output value from fft, pretty much a passthru for convenience
    .shift_semitones(shift_semitones), // -12 to 12
    .shift_wr_en(shift_wr_en), // write enable for shift_semitones
    .input_index(input_index), // index of source frequency bucket from pitch shift
    .output_index(output_index) // index of destination frequency bucket from pitch shift
);

int i;

initial begin

    clk = 0;
    rst_n = 1;
    shift_wr_en = 0;
    data_in = 44'h7FFF;
    shift_semitones = 6;

    @(posedge clk) rst_n = 0;
    @(posedge clk) rst_n = 1;

    @(posedge clk) shift_wr_en = 1;
    @(posedge clk) shift_wr_en = 0;

    for(i = 0; i < 2048; i++) begin

        input_index = i;

        @(posedge clk);

    end

    shift_semitones = -6;

    @(posedge clk) shift_wr_en = 1;
    @(posedge clk) shift_wr_en = 0;

    for(i = 0; i < 2048; i++) begin

        input_index = i;

        @(posedge clk);

    end

    $stop();


end


always #5 clk = ~clk;

endmodule 


