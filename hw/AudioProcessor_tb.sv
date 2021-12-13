module AudioProcessor_tb;

reg clk, rst_n;
reg start;
reg data_wr_en;
reg [5:0] input_index, output_index;
reg [511:0] data_in;
reg pitch_shift_wr_en;
reg [4:0] pitch_shift_semitones;
reg freq_coeff_wr_en;
reg [10:0] freq_coeff_index;
reg [7:0] freq_coeff_in;

wire [511:0] data_out;

reg [15:0] input_array [31:0];

longint cycle_cnt = 0;

AudioProcessor dj_disco(
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .data_wr_en(data_wr_en),
    .input_index(input_index),
    .data_in(data_in),
    .pitch_shift_wr_en(pitch_shift_wr_en),
    .pitch_shift_semitones(pitch_shift_semitones),
    .freq_coeff_wr_en(freq_coeff_wr_en),
    .freq_coeff_index(freq_coeff_index),
    .freq_coeff_in(freq_coeff_in),
    .output_index(output_index),
    .data_out(data_out)
);


initial begin
    
    clk = 0;
    rst_n = 1;
    start = 0;
    data_wr_en = 0;
    input_index = 0;
    output_index = 0;
    pitch_shift_wr_en = 0;
    freq_coeff_wr_en = 0;
    data_in = 512'h001f_001e_001d_001c_001b_001a_0019_0018_0017_0016_0015_0014_0013_0012_0011_0010_000f_000e_000d_000c_000b_000a_0009_0008_0007_0006_0005_0004_0003_0002_0001_0000;;


    @(posedge clk) rst_n = 0;
    @(posedge clk) rst_n = 1;

    data_wr_en = 1;

    for(int i = 0; i < 64; i++) begin

        input_index = i;

        fill_data(i);
    
        @(posedge clk);

    end

    data_wr_en = 0;

    pitch_shift_semitones = 0;

    @(posedge clk) pitch_shift_wr_en = 1;
    @(posedge clk) pitch_shift_wr_en = 0;

    @(posedge clk) start = 1;
    @(posedge clk) start = 0;

    repeat(13000) @(posedge clk);

    $stop();

end

always begin
    #5 clk = ~clk;
    if(clk) cycle_cnt++;
end


genvar i, j;
generate
for(i = 0; i < 2028; i++) begin

    for(j = 0; j < 16; j += 8) begin
        
        assign data_in[16*i+j+7 : 16*i+j] = input_array[i][j+7:j];

    end

end
endgenerate


task fill_data(int offset);

    for(int l = 0; l < 32; l++) begin

        input_array[l] = 500 * $sin(2*3.141592653/2048 * 50 * (l + 32 * offset));

    end

endtask

endmodule