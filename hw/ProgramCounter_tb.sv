// Register Testbench
module ProgramCounter_tb #(
    parameter DATAW=32
    );

    logic rst_n, clk, halt, stall, branch;
    logic [DATAW-1:0] PC_branch, PC_out, exp_PC;

    integer setupErrors, runErrors;

    always #5 clk = ~clk;

    ProgramCounter #(DATAW) DUT (
        .rst_n(rst_n), .clk(clk), .halt(halt), .stall(stall),
        .branch(branch), .PC_branch(PC_branch), .PC_out(PC_out)
    );

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        setupErrors = 0;
        runErrors = 0;
        exp_PC = 0;

        @(posedge clk);
        @(negedge clk);
        if (PC_out !== exp_PC) begin
            setupErrors++;
            $display("Error in setup: PC was not reset to 0");
        end

        if (setupErrors == 0) begin
            $display("No errors found in setup");
        end else begin
            $display("Found %d errors in setup", setupErrors);
        end

		rst_n = 1'b1;

        for (int j = 0; j < 100; j++) begin 
            stall = $urandom();
            halt = $urandom();
            branch = (j < 30) ? 0 : $urandom();
            PC_branch = $urandom();

            if (branch) begin
                exp_PC = PC_branch;
            end else begin
                if (!(stall || halt)) begin
                    exp_PC += 4;
                end
            end

            @(posedge clk);
            @(negedge clk);

            if (PC_out !== exp_PC) begin
                runErrors++;
                $display("Running error: expected PC %d, found PC %d", exp_PC, PC_out);
                exp_PC = PC_out;
            end
        end

        if (runErrors == 0) begin
            $display("No errors found in write tests");
        end else begin
            $display("Found %d errors in write tests", runErrors);
        end

        if (runErrors == 0 && setupErrors == 0) begin
            $display("All tests passed");
        end
        
        $stop();
    end

endmodule