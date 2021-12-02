module Execute
 #(
    DATAW=32,
    PCW=32
 )
 (
    input alu_op, branch_in, use_imm,
    input [1:0] shift_dist,
    input [DATAW-1:0] a, b,
    input [PCW-1:0] PC_in,
    input [10:0] imm,
    output [DATAW-1:0] ex_out,
    output [PCW-1:0] PC_out,
    output branch_out
 );

   logic p_flag;
   logic [DATAW-1:0] alu_out, shifted_imm;

   assign branch_out = branch_in && p_flag;
   assign PC_out = PC_in + imm;
   assign shifted_imm = imm[7:0] << (shift_dist * (DATAW / 4));
   assign ex_out = (use_imm) ? shifted_imm : alu_out;

   ALU #(DATAW) alu (.alu_op(alu_op), .a(a), .b(b), .alu_out(alu_out), .p_flag(p_flag));
endmodule