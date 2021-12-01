// Register Testbench
module Register_tb #(
    parameter NUMREGISTERS=8,
    parameter DATAW=32
    );

	logic clk;
	logic rst_n;
    logic wr_reg_en;

    logic [DATAW-1:0] data1, data2, wr_data;
    logic [$clog2(NUMREGISTERS)-1:0] reg1, reg2, wr_reg;

    logic [DATAW-1:0] exp_data1, exp_data2;
    integer setupErrors, writingErrors;

    always #5 clk = ~clk;

    Register #(NUMREGISTERS, DATAW) DUT ( .clk(clk), .rd_reg1(reg1),
        .rd_reg2(reg2), .wr_reg(wr_reg), .wr_reg_en(wr_reg_en),
        .rst_n(rst_n), .wr_reg_data(wr_data),
        .reg1_data(data1), .reg2_data(data2));

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        wr_reg_en = 1'b0;
        setupErrors = 0;
        writingErrors = 0;

        reg1 = 0;
        reg2 = 1;

        exp_data1 = 0;
        exp_data2 = 0;

        @(posedge clk);
		rst_n = 1'b1;
        wr_reg = 0;
        wr_data = $urandom();

        for (int i = 0; i < NUMREGISTERS; i += 2) begin
            @(posedge clk);
            @(negedge clk);
            if (data1 !== exp_data1) begin
                setupErrors++;
                $display("Error in setup: data1 %d does not match expected %d", data1, exp_data1);
            end
            if (data2 !== exp_data2) begin
                setupErrors++;
                $display("Error in setup: data2 %d does not match expected %d", data2, exp_data2);
            end
            reg1 += 2;
            reg2 += 2;
        end

        if (setupErrors == 0) begin
            $display("No errors found in setup");
        end else begin
            $display("Found %d errors in setup", setupErrors);
        end

        wr_reg_en = 1'b1;
        for (int j = 0; j < 20; j++) begin 
            for (int i = 0; i < NUMREGISTERS; i += 2) begin
                reg1 = i;
                reg2 = i+1;
                
                wr_data = $urandom();
                exp_data1 = wr_data;
                wr_reg = i;
                @(posedge clk);
                @(negedge clk);

                wr_data = $urandom();
                exp_data2 = wr_data;
                wr_reg = i+1;
                @(posedge clk);
                @(negedge clk);
                
                if (data1 !== exp_data1) begin
                    writingErrors++;
                    $display("Error in write tests: data1 %d does not match expected %d", data1, exp_data1);
                end
                if (data2 !== exp_data2) begin
                    writingErrors++;
                    $display("Error in write tests: data2 %d does not match expected %d", data2, exp_data2);
                end
            end
        end

        if (writingErrors == 0) begin
            $display("No errors found in write tests");
        end else begin
            $display("Found %d errors in write tests", writingErrors);
        end

        if (writingErrors == 0 && setupErrors == 0) begin
            $display("All tests passed");
        end
        
        $stop();
    end

endmodule