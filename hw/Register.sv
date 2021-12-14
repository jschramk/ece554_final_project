module Register
  #(
    parameter NUMREGISTERS=8,
    parameter DATAW=32
   )
   (
    input [$clog2(NUMREGISTERS)-1:0] rd_reg1, rd_reg2, wr_reg,
    input wr_reg_en, rst_n, clk,
    input [DATAW-1:0] wr_reg_data,
    output [DATAW-1:0] reg1_data, reg2_data
   );

   reg [DATAW-1:0] regs [NUMREGISTERS-1:0];

    assign reg1_data = (wr_reg == rd_reg1 && wr_reg_en) ? wr_reg_data : regs[rd_reg1];
    assign reg2_data = (wr_reg == rd_reg2 && wr_reg_en) ? wr_reg_data : regs[rd_reg2];

    int i;

    always_ff @(posedge clk) begin
        if (~rst_n) begin
            for (i = 0; i < NUMREGISTERS; i++) begin
                regs[i] <= 0;
            end
        end else begin
            if (wr_reg_en) begin
                regs[wr_reg] <= wr_reg_data;
            end
        end
    end
    

endmodule