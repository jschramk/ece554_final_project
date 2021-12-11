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

reg [15:0] i;

initial begin

clk = 0;
rst_n = 1;
wr_en = 0;
data_in = 512'b0;

@(posedge clk) rst_n = 0;
@(posedge clk) rst_n = 1;

for(i = 0; i < 32; i++) begin
    data_in[16:i+7:16*i] = i[7:0];
    data_in[16:i+15:16*i+8] = i[15:8];
end

for(input_index = 0; input_index < 64; input_index++) begin
    
    @(posedge clk) wr_en = 1;
    @(posedge clk) wr_en = 0;

end

for(output_index = 0; output_index < 2048; output_index++) begin
    
    @(posedge clk);

end


end

always #5 clk = ~clk;

endmodule