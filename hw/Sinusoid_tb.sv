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

        in = {i[0], 10'b0};

        $display("sin(%f) = %b", in * 0.0245436926, out);

    end

    $stop();

end

always #5 clk = ~clk;

endmodule