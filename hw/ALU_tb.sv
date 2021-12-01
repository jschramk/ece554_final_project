module ALU_tb #(DATAW) ()

    logic [DATAW-1:0] a, b, alu_out, exp_alu_out;
    logic alu_op, p_flag, exp_p_flag;

    integer errors;

    ALU #(DATAW) DUT (.a(a), .b(b), .alu_out(alu_out), .alu_op(alu_op), .p_flag(p_flag));

    initial begin
        errors = 0;

        for (int i = 0; i < 20; i++) begin 
            a = $urandom();
            b = $urandom();
            alu_op = $urandom();

            exp_alu_out = (alu_op) ? a + 1 : a + b;
            exp_p_flag = (alu_op) ? a > b : exp_alu_out > 0;

            #1;
            if (exp_alu_out !== alu_out) begin
                errors++;
                $display("Instruction carried out incorrectly. Expected alu_out %d, recieved %d", exp_alu_out, alu_out);
            end
            if (exp_p_flag !== p_flag) begin
                errors++;
                $display("Instruction carried out incorrectly. Expected p_flag %d, recieved %d", exp_p_flag, p_flag);
            end
        end

    end

endmodule