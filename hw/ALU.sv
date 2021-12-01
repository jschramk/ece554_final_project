module ALU
    #(
        DATAW=32
    ) (
        input alu_op,
        input [DATAW-1:0] a, b,
        output [DATAW-1:0] alu_out,
        output p_flag
    );

    assign alu_out = (alu_op) ? a + 1 : a + b;
    assign p_flag = (alu_op) ? (a > b) : alu_out > 0;

endmodule