module Decoder_tb #() ();


    logic [15:0]instr;
	logic halt, alu_op, reg_wr_en, mem_wr_en, branch, fft_wr_en, set_en, syn, use_imm, set_freq, shift_dist;
	logic [2:0] reg1, reg2;

	logic exp_halt, exp_alu_op, exp_reg_wr_en,
        exp_mem_wr_en, exp_branch, exp_fft_wr_en, exp_set_en,
        exp_syn, exp_use_imm, exp_set_freq, exp_shift_dist;
	logic [2:0] exp_reg1, exp_reg2;

    integer errors;

    Decoder #() DUT (.instr(instr), .halt(halt), .alu_op(alu_op),
    .reg_wr_en(reg_wr_en), .mem_wr_en(mem_wr_en), .branch(branch),
    .fft_wr_en(fft_wr_en), .set_en(set_en), .syn(syn), .use_imm(use_imm),
    .set_freq(set_freq), .shift_dist(shift_dist), .reg1(reg1), .reg2(reg2));

    initial begin
        errors = 0;

        for (int i = 0; i < 500; i++) begin
            instr = $urandom();
            exp_halt = instr[15:11] == 5'b00000;
            exp_alu_op = instr[15:11] == 5'b01010;
            exp_reg_wr_en = instr[15:13] == 3'b001 || instr[15:11] == 5'b01010;
            exp_mem_wr_en = instr[15:11] == 5'b01001;
            exp_branch = instr[15:11] == 5'b01011;
            exp_fft_wr_en = instr[15:11] == 5'b01000;
            exp_set_en = instr[15:11] == 5'b01110;
            exp_syn = instr[15:11] == 5'b01111;
            exp_use_imm = instr[15:13] == 3'b001;
            exp_set_freq = instr[15:13] == 5'b01100;
            exp_shift_dist = instr[12:11];
            exp_reg1 = instr[10:8];
            exp_reg2 = instr[7:5];
            
            #2;
            if (exp_halt !== halt) begin
                errors++;
                $display("Error decoding instruction. Expected halt %d, got %d", exp_halt, halt);
            end
            if (exp_alu_op !== alu_op) begin
                errors++;
                $display("Error decoding instruction. Expected alu_op %d, got %d", exp_alu_op, alu_op);
            end
            if (exp_reg_wr_en !== reg_wr_en) begin
                errors++;
                $display("Error decoding instruction. Expected reg_wr_en %d, got %d", exp_reg_wr_en, reg_wr_en);
            end
            if (exp_mem_wr_en !== mem_wr_en) begin
                errors++;
                $display("Error decoding instruction. Expected mem_wr_en %d, got %d", exp_mem_wr_en, mem_wr_en);
            end
            if (exp_branch !== branch) begin
                errors++;
                $display("Error decoding instruction. Expected branch %d, got %d", exp_branch, branch);
            end
            if (exp_fft_wr_en !== fft_wr_en) begin
                errors++;
                $display("Error decoding instruction. Expected fft_wr_en %d, got %d", exp_fft_wr_en, fft_wr_en);
            end
            if (exp_set_en !== set_en) begin
                errors++;
                $display("Error decoding instruction. Expected set_en %d, got %d", exp_set_en, set_en);
            end
            if (exp_syn !== syn) begin
                errors++;
                $display("Error decoding instruction. Expected syn %d, got %d", exp_syn, syn);
            end
            if (exp_use_imm !== use_imm) begin
                errors++;
                $display("Error decoding instruction. Expected use_imm %d, got %d", exp_use_imm, use_imm);
            end
            if (exp_set_freq !== set_freq) begin
                errors++;
                $display("Error decoding instruction. Expected set_freq %d, got %d", exp_set_freq, set_freq);
            end
            if (exp_shift_dist !== shift_dist) begin
                errors++;
                $display("Error decoding instruction. Expected shift_dist %d, got %d", exp_shift_dist, shift_dist);
            end
            if (exp_reg1 !== reg1) begin
                errors++;
                $display("Error decoding instruction. Expected reg1 %d, got %d", exp_reg1, reg1);
            end
            if (exp_reg2 !== reg2) begin
                errors++;
                $display("Error decoding instruction. Expected reg2 %d, got %d", exp_reg2, reg2);
            end
        end

        if (errors == 0) begin
            $display("All tests passed!");
        end

        $stop();
    end

endmodule