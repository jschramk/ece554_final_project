module Decoder 
 #(

 ) (
    input [15:0]instr,
    output halt, alu_op, reg_wr_en, mem_wr_en, branch, fft_wr_en, set_en, syn, use_imm, set_freq
    output [1:0] shift_dist,
    output [2:0] reg1, reg2
 );

    always_comb begin
        halt = 0;
        alu_op = 0;
        reg_wr_en = 0;
        mem_wr_en = 0;
        branch = 0;
        fft_wr_en = 0;
        set_en = 0;
        syn = 0;
        use_imm = 0;
        set_freq = 0;
        shift_dist = 0;
        reg1 = 0;
        reg2 = 0;

        casex (instr[15:11])
            5'b00000 : halt = 1;    // HALT
            5'b001xx : begin        // SR0 - SR3
                reg_wr_en = 1;
                shift_dist = instr[12:11];
                use_imm = 1;
                reg1 = instr[10:8];
            end
            5'b0100x : begin        // LDE (0) and STE (1)
                fft_wr_en = ~instr[11];
                mem_wr_en = instr[11];
                reg1 = instr[10:8];
                reg2 = instr[7:5];
            end
            5'b01010 : begin        // INCC
                alu_op = 1;
                reg_wr_en = 1;
                reg1 = instr[10:8];
                reg2 = instr[7:5];
            end
            5'b01011 : begin        // BP
                branch = 1;
            end
            5'b01100 : begin        // SFC
                set_freq = 1;
                reg1 = instr[10:8];
                reg2 = instr[7:5];
            end
            5'b01101 : begin        // SPM
                reg1 = instr[10:8];
            end
            5'b01110 : begin        // SME
                set_en = 1;
            end
            5'b01111 : begin        // SYN
                syn = 1;
            end
        endcase
    end
    


endmodule;