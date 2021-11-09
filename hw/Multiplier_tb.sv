module Multiplier_tb;

reg clk;
reg [15:0] a, b, exp_out;
wire out;

Multiplier m(
    .a(a),
    .b(b),
    .out(out)
);

initial begin

    clk = 0;

    for(int i = 0; i < 65536; i++) begin
        
        a = i;// << 8;
        b = i;// << 8;

        @(posedge clk);

    end

        for(int i = 0; i < 256; i++) begin
        
        a = i << 8;
        b = -(i << 8);

        @(posedge clk);

    end

    $stop();

end

always #5 clk = ~clk;


endmodule



