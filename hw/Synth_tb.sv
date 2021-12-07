module Synth_tb;

reg clk, rst_n, wr_en, clr;

reg [15:0] mag, phase;

reg [10:0] x, freq;

wire [15:0] out;

Synth sy(
    .rst_n(rst_n),
    .clk(clk),
    .wr_en(wr_en),
    .clr(clr),
    .magnitude(mag),
    .frequency(freq),
    .phase(phase),
    .x(x),
    .out(out)
);

initial begin
    
    clk = 0;
    rst_n = 1;
    clr = 0;
    wr_en = 1;

    @(posedge clk) rst_n = 0;
    @(posedge clk) rst_n = 1;

    mag = 16'b00000001_00000000;
    freq = 11'b00000000001;
    x = 11'b00000000000;





end

always #5 clk = ~clk;

endmodule