module Execute_tb #(DATAW=32, PCW=32) ();


    logic alu_op, branch_in, use_imm, branch_out, exp_branch_out, p_flag_in, p_flag_out, exp_p_flag_out;
    logic [1:0] shift_dist;
    logic [DATAW-1:0] a, b, ex_out, exp_ex_out;
    logic [PCW-1:0] PC_in, PC_out, exp_PC_out;
    logic [10:0] imm;

    integer errors;

    Execute #(DATAW, PCW) DUT ( .alu_op(alu_op), .branch_in(branch_in), .use_imm(use_imm),
        .branch_out(branch_out), .shift_dist(shift_dist), .a(a), .b(b), .p_flag_in(p_flag_in),
        .ex_out(ex_out), .PC_in(PC_in), .PC_out(PC_out), .imm(imm), .p_flag_out(p_flag_out));

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
                p_flag_in = $urandom();

                PC_in = $urandom();
                imm = $urandom();
                shift_dist = $urandom();

                exp_ex_out = (use_imm) ? (
                    (shift_dist == 2'b00) ? {a[DATAW-1:DATAW / 4], imm[DATAW / 4 - 1:0]} :
                    (shift_dist == 2'b01) ? {a[DATAW-1:DATAW / 2], imm[DATAW / 4 - 1:0], a[DATAW/4 - 1:0]} :
                    (shift_dist == 2'b10) ? {a[DATAW-1: 3 * (DATAW / 4)], imm[DATAW / 4 - 1:0], a[DATAW/2 - 1:0]} :
                    {imm[DATAW / 4 - 1:0], a[3 * (DATAW / 4) - 1:0]}
                ) : (alu_op) ? a + 1 : a + b;
                exp_branch_out = branch_in && p_flag_in;
                exp_PC_out = PC_in + imm;
                exp_p_flag_out = (alu_op) ? (a > b) : (a + b > 0);

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
                if (exp_p_flag_out !== p_flag_out) begin
                    errors++;
                    $display("Instruction carried out incorrectly. Expected p_flag_out %d, recieved %d", exp_p_flag_out, p_flag_out);
                end
            end
        end

        if (errors == 0) begin
            $display("All tests passed!");
        end

        $stop();
    end

endmodule