module ProgramCounter
  #(
    PCW=32
   )
   (
    input rst_n, clk, halt, stall, branch,
    input [PCW-1:0] PC_branch,
    output [PCW-1:0] PC_out
   );

    reg [PCW-1:0] PC;

    assign PC_out = PC;

    always_ff @(posedge clk) begin
        if (~rst_n) begin
            PC = 0;
        end else begin
            if (branch) begin
                PC = PC_branch;
            end else begin
                PC = (stall | halt) ? PC : PC + 4;
            end
        end
    end

endmodule;