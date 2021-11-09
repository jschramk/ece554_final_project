module Sinusoid_tb;

reg clk;
reg [15:0] in;
wire [15:0] out;

Sinusoid SIN(
    .clk(clk),
    .mode(0), // 0: sine
    .x(in),
    .y(out)
);

initial begin

    clk = 0;

    for (int i = 0; i < 65535; i++) begin
        
        @(posedge clk);

        in = i;

        $display("sin(%f) = %b", in/256, out);

    end

    $stop();

end

always #5 clk = ~clk;

endmodule