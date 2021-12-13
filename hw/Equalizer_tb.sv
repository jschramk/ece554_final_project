module Equalizer_tb;

reg clk, rst_n;

reg [10:0] input_index, coeff_index;
wire [31:0] data_in;
reg coeff_wr_en;
reg [7:0] coeff_in;

wire [31:0] data_out;

reg [15:0] data_in_real, data_in_complex, data_out_real, data_out_complex;

Equalizer e(
    .clk(clk),
    .rst_n(rst_n),
    .input_index(input_index),
    .data_in(data_in),
    .coeff_wr_en(coeff_wr_en),
    .coeff_index(coeff_index),
    .coeff_in(coeff_in),
    .data_out(data_out)
);

assign data_out_real = data_out[31:16];
assign data_out_complex = data_out[15:0];
assign data_in = {data_in_real, data_in_complex};

initial begin
    
    clk = 0;
    rst_n = 1;
    coeff_in = 0;
    coeff_wr_en = 0;
    data_in_real = 0;
    data_in_complex = 0;

    @(posedge clk) rst_n = 0;
    @(posedge clk) rst_n = 1;

    coeff_wr_en = 1;

    for(int i = 0; i < 2048; i++) begin

        coeff_index = i;
        coeff_in = 8'b111_11111;

        @(posedge clk);

    end

    coeff_wr_en = 0;

    for(int i = 0; i < 2048; i++) begin

        input_index = i;

        data_in_real = i << 5;
        data_in_complex = i << 5;

        @(posedge clk);

    end

    $stop();

end

always #5 clk = ~clk;

endmodule