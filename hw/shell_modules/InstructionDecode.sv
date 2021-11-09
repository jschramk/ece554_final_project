module InstructionDecode (
    input clk,
    input rst,
    input instruction,
    input [7:0]pc_in,
    input wr_en,
    input [2:0]wr_reg,
    input [31:0]wr_data,
    output [7:0]pc_out,
    output [31:0]R1_data,
    output [31:0]R2_data,
    output et_en,
    output halt,
    output [10:0]imm,
    output yn
);


endmodule