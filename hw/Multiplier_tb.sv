module Multiplier_tb;

reg clk;
reg [15:0] a, b;
wire [15:0] out;

Multiplier m(
    .a(a),
    .b(b),
    .out(out)
);

reg [31:0] prod;
reg [15:0] exp;

initial begin

    clk = 0;

    for(int i = 0; i < 256; i++) begin

        for(int j = 0; j < 256; j++) begin
            
            a = i << 8;
            b = j << 8;

            prod = a * b;

            if(prod <= 32'sb11111111_10000000_00000000_00000000)
                exp = 16'sb10000000_00000000;
            else if(prod >= 32'sb00000000_01111111_11111111_11111111)
                exp = 16'sb01111111_11111111;
            else
                exp = prod[23:8];

            //if(out != exp) $display("Error (%f * %f): expected %b, got %b", a >> 8, b >> 8, exp, out);
            


            @(posedge clk);

        end
        



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



