module Complex_tb;

reg clk;
reg [15:0] a_real, b_real, a_complex, b_complex;
wire [15:0] out_real, out_complex;

ComplexAdder a (
    .a_real(a_real),
    .b_real(b_real),
    .a_complex(a_complex),
    .b_complex(b_complex),
    .sum_real(out_real),
    .sum_complex(out_complex)
);

ComplexMultipler m (
    .a_real(a_real),
    .b_real(b_real),
    .a_complex(a_complex),
    .b_complex(b_complex),
    .out_real(out_real),
    .out_complex(out_complex)
);

initial begin

    clk = 0;
    
    for(int i = 0; i < 100; i++) begin
        
        a_real = $random();
        b_real = $random();
        a_complex = $random();
        b_complex = $random();


        @(posedge clk);

    end

    $stop();

end

always #5 clk = ~clk;

endmodule

