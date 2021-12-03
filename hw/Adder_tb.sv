module Adder_tb;

reg clk;
reg [15:0] a, b;
wire [15:0] out;

Adder m(
    .a(a),
    .b(b),
    .sum(out)
);

initial begin

    clk = 0;

    for(int i = 0; i < 2**16; i++) begin

        for(int j = 0; j < 2**16; j++) begin
            
            a = i << 8;
            b = j << 8;

            @(posedge clk);

        end

    end

    $stop();

end

always #5 clk = ~clk;


endmodule



