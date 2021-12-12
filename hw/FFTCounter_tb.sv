module FFTCounter_tb;

reg clk, rst_n, fft_sync, clr_cnt;
wire [10:0] count;

FFTCounter c(
    .clk(clk),
    .rst_n(rst_n),
    .fft_sync(fft_sync),
    .clr_cnt(clr_cnt),
    .count(count)
);

int i;

initial begin
    
    clk = 0;
    rst_n = 1;

    @(posedge clk) rst_n = 0;
    @(posedge clk) rst_n = 1;

    @(posedge clk) fft_sync = 1;
    @(posedge clk) fft_sync = 0;

    repeat(2047 * 3) @(posedge clk);

    $stop();

end


always #5 clk = ~clk;


endmodule