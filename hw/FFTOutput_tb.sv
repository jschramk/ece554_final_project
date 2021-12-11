module FFTInput_tb;

reg clk, rst_n, wr_en;

wire [511:0] data_out;
reg [5:0] output_index;
reg [10:0] input_index;
wire [15:0] data_out;

FFTOutput out(
    .clk(clk),
    .rst_n(rst_n),
    .data_out(data_out) // 512 bits
    .output_index(output_index), // 6 bits
    .input_index(input_index), // 11 bits
    .wr_en(wr_en),
    .data_in(data_in), // 16 bits
);

int i;

initial begin

clk = 0;
rst_n = 1;
wr_en = 0;
data_in = 16'b0;

@(posedge clk) rst_n = 0;
@(posedge clk) rst_n = 1;

@(posedge clk) wr_en = 1;

for(i = 0; i < 2048; i++) begin

    input_index = i;
    data_in = i;
    
    @(posedge clk);

end

@(posedge clk) wr_en = 0;

for(i = 0; i < 64; i++) begin

    output_index = i;
    
    @(posedge clk);

end

$stop();


end

always #5 clk = ~clk;

endmodule