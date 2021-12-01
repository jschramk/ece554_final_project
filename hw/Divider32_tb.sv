module Divider32_tb;

reg clk, reset, start;
reg [31:0] A, B;
wire [31:0] D, R;
wire ok, err;

Divider32 d(
    .clk(clk),
    .reset(reset),
    .start(start),
    .A(A),
    .B(B),
    .D(D),
    .R(R),
    .ok(ok),
    .err(err)
);

initial begin
    
    clk = 0;
    reset = 0;
    start = 0;

    A = 32'b00000000_00000011_00000000_00000000;
    B = 32'b00000000_00000100_00000000_00000000;

    @(negedge clk) reset = 1;
    @(negedge clk) reset = 0;

    @(negedge clk) start = 1;
    //@(negedge clk) start = 0;

    repeat(256) @(posedge clk);


    $stop();

end

always #5 clk = ~clk;



endmodule