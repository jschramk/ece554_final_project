module PitchShift_tb;

reg clk, rst_n, shift_wr_en, en;
reg [31:0] data_in;
reg [10:0] input_index, output_index;
reg [4:0] shift_semitones;
wire [31:0] data_out;

PitchShift ps(
    .clk(clk),
    .rst_n(rst_n),
    .data_in(data_in),
    .data_out(data_out),
    .shift_semitones(shift_semitones),
    .shift_wr_en(shift_wr_en),
    .en(en),
    .input_index(input_index),
    .output_index(output_index)
);

int i;

initial begin

    en = 0;
    clk = 0;
    rst_n = 1;
    shift_wr_en = 0;
    data_in = 0;
    shift_semitones = -12;

    @(posedge clk) rst_n = 0;
    @(posedge clk) rst_n = 1;

    @(posedge clk) shift_wr_en = 1;
    @(posedge clk) shift_wr_en = 0;

    en = 1;

    for(i = 0; i < 2048; i++) begin

        input_index = i;
        data_in = i << 16;

        @(posedge clk);

    end

    en = 0;

    for(i = 0; i < 2048; i++) begin

        output_index = i;

        @(posedge clk);

    end

    $stop();


end


always #5 clk = ~clk;

endmodule 


