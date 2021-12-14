module AudioStorage_tb;

reg clk, rst_n;
reg [11:0] output_index;
wire [511:0] data_out;

AudioStorage store(
    .clk(clk),
    .rst_n(rst_n),
    .data_out(data_out),
    .output_index(output_index) // 0 to 4095
);

initial begin

    clk = 0;
    rst_n = 1;

    @(posedge clk) rst_n = 0;
    @(posedge clk) rst_n = 1;

    for(int i = 0; i < 4096; i++) begin

        output_index = i;
        
        @(posedge clk);

    end

    $stop();

end


always #5 clk = ~clk;

endmodule