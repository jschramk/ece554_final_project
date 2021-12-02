module Execute_tb #(DATAW=32, PCW=32) ();


    logic alu_op, branch_in, use_imm, branch_out, exp_branch_out;
    logic [1:0] shift_dist;
    logic [DATAW-1:0] a, b, ex_out, exp_ex_out;
    logic [PCW-1:0] PC_in, PC_out, exp_PC_out;
    logic [10:0] imm;

    integer errors;

    Execute #(DATAW, PCW) DUT ( .alu_op(alu_op), .branch_in(branch_in), .use_imm(use_imm),
        .branch_out(branch_out), .shift_dist(shift_dist), .a(a), .b(b),
        .ex_out(ex_out), .PC_in(PC_in), .PC_out(PC_out), .imm(imm));

    initial begin
        errors = 0;
        use_imm = 0;
        shift_dist = 0;
        
        for (int j = 0; j < 2; j++) begin
            use_imm = j;
            for (int i = 0; i < 100; i++) begin 
                a = $urandom();
                b = $urandom();
                alu_op = $urandom(); 
                branch_in = $urandom();

                PC_in = $urandom();
                imm = $urandom();
                shift_dist = $urandom();

                exp_ex_out = (use_imm) ? imm[7:0] << (shift_dist * (DATAW / 4)) : (alu_op) ? a + 1 : a + b;
                exp_branch_out = branch_in && ((alu_op) ? (a > b) : (a + b > 0));
                exp_PC_out = PC_in + imm;

                #2;
                if (exp_ex_out !== ex_out) begin
                    errors++;
                    $display("Instruction carried out incorrectly. Expected ex_out %d, recieved %d", exp_ex_out, ex_out);
                end
                if (exp_branch_out !== branch_out) begin
                    errors++;
                    $display("Instruction carried out incorrectly. Expected branch_out %d, recieved %d", exp_branch_out, branch_out);
                end
                if (exp_PC_out !== PC_out) begin
                    errors++;
                    $display("Instruction carried out incorrectly. Expected PC_out %d, recieved %d", exp_PC_out, PC_out);
                end
            end
        end

        $stop();
    end

endmodule