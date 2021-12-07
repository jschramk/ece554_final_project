module Decoder 
 #(

 ) (
    input [15:0]instr,
    output halt, alu_op, reg_wr_en, mem_wr_en, branch, fft_wr_en, set_en, syn, use_imm, set_freq,
    output [1:0] shift_dist,
    output [2:0] reg1, reg2
 );

    assign halt = instr[15:11] == 5'b00000;
    assign alu_op = instr[15:11] == 5'b01010;
    assign reg_wr_en = instr[15:13] == 3'b001 || instr[15:11] == 5'b01010;
    assign mem_wr_en = instr[15:11] == 5'b01001;
    assign branch = instr[15:11] == 5'b01011;
    assign fft_wr_en = instr[15:11] == 5'b01000;
    assign set_en = instr[15:11] == 5'b01110;
    assign syn = instr[15:11] == 5'b01111;
    assign use_imm = instr[15:13] == 3'b001;
    assign set_freq = instr[15:13] == 5'b01100;
    assign shift_dist = instr[12:11];
    assign reg1 = instr[10:8];
    assign reg2 = instr[7:5];
endmodule;