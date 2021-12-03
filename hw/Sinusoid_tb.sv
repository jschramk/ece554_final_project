module Sinusoid_tb;

reg clk;
reg [11:0] in;
wire [11:0] out;

SineLUT SIN(
    .in(in),
    .out(out)
);

initial begin

    clk = 0;

    for (int i = 0; i < 2**11; i++) begin
        
        @(posedge clk);

        in = i[10:0];

        $display("sin(%f) = %b", in, out);

    end

    $stop();

end

always #5 clk = ~clk;

endmodule