module InstructionFetch (
    input clk,
    input rst,
    input [7:0]pc_in,
    input branch,
    input [15:0] instructions [31:0],
    input halt,
    output instruction,
    output [7:0]pc_out,
    output [31:0]search_addr
);


endmodule