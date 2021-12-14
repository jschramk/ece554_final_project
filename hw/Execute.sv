module Execute
 #(
    DATAW=32,
    PCW=32,
    IMMW=11
 )
 (
    input alu_op, branch_in, use_imm, p_flag_in,
    input [1:0] shift_dist,
    input [IMMW-1:0] imm,
    input [PCW-1:0] PC_in,
    input [DATAW-1:0] a, b,
    output branch_out, p_flag_out,
    output [PCW-1:0] PC_out,
    output [DATAW-1:0] ex_out
 );

   logic [DATAW-1:0] alu_out, a_imm, a_temp;

   assign branch_out = branch_in && p_flag_in;
   assign PC_out = PC_in + imm;
   assign a_temp = a & ~(8'hFF << (shift_dist * (DATAW / 4)));
   assign a_imm = a_temp | imm[7:0] << (shift_dist * (DATAW / 4));
   assign ex_out = (use_imm) ? a_imm : alu_out;

   ALU #(DATAW) alu (.alu_op(alu_op), .a(a), .b(b), .alu_out(alu_out), .p_flag(p_flag_out));
endmodule