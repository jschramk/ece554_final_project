module AudioStorage_tb;

reg clk, rst_n;
reg [11:0] read_index, write_index;
reg wr_en;
wire [511:0] data_out;

AudioStorage store(
    .clk(clk),
    .rst_n(rst_n),
    .data_out(data_out),
    .output_index(read_index) // 0 to 4095
);

AudioReader read(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(wr_en),
    .data_in(data_out),
    .input_index(write_index) // 0 to 4095
);

initial begin

    clk = 0;
    rst_n = 1;
    wr_en = 0;

    @(posedge clk) rst_n = 0;
    @(posedge clk) rst_n = 1;

    wr_en = 1;

    for(int i = 0; i < 4096; i++) begin

        read_index = i;
        write_index = i;
        
        @(posedge clk);

    end

    wr_en = 0;

    $writememb("audio_store_tb_out.txt", read.values);

    $stop();

end


always #5 clk = ~clk;

endmodule