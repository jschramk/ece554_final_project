module FetchDecodePipe 
#(
    PCW=32,
    INSTRW=16
 ) (
    // Inputs
    input clk, flush, stall,
    input [PCW-1:0] PC_in, 
    input [INSTRW-1:0] instr_in,

    // Outputs
    output logic [PCW-1:0] PC_out, 
    output logic [INSTRW-1:0] instr_out
 );

    always_ff @(posedge clk) begin
        if (flush) begin
            PC_out = 0;
            instr_out = 0;
        end else begin
            if (!stall) begin
                PC_out = PC_in;
                instr_out = instr_in;
            end
        end
    end
endmodule