module FFTInput_tb;

reg clk, rst_n, wr_en;

reg [511:0] data_in;
reg [5:0] input_index;
reg [10:0] output_index;
wire [15:0] data_out;

FFTInput in(
    .clk(clk),
    .rst_n(rst_n),
    .data_in(data_in), // 512 bits
    .input_index(input_index), // 6 bits
    .output_index(output_index), // 11 bits
    .wr_en(wr_en),
    .data_out(data_out) // 16 bits
);

int i;

initial begin

clk = 0;
rst_n = 1;
wr_en = 0;
data_in = 512'h001f_001e_001d_001c_001b_001a_0019_0018_0017_0016_0015_0014_0013_0012_0011_0010_000f_000e_000d_000c_000b_000a_0009_0008_0007_0006_0005_0004_0003_0002_0001_0000;

@(posedge clk) rst_n = 0;
@(posedge clk) rst_n = 1;

@(posedge clk) wr_en = 1;

for(i = 0; i < 64; i++) begin

    input_index = i;
    
    @(posedge clk);

end

@(posedge clk) wr_en = 0;

for(i = 0; i < 2048; i++) begin

    output_index = i;
    
    @(posedge clk);

end

$stop();


end

always #5 clk = ~clk;

endmodule