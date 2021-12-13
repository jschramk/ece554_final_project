module InstructionCache_tb 
#(
    parameter DATAW=16,
    parameter INW=512,
    parameter ADDRW=32,
    parameter NUMINSTRUCTIONS=INW/DATAW
 ) ();

    logic clk, rst_n, write, valid_out, exp_valid;
    logic [INW-1:0] data_in;
    logic [ADDRW-1:0] addr_in, base_addr_in;
    logic [DATAW-1:0] data_out, exp_data_out;

    always #2 assign clk = ~clk;

    InstructionCache DUT (.*);

    integer errors, index;

    logic [DATAW-1:0] data [NUMINSTRUCTIONS-1:0];

    generate
        for (genvar i = 0; i < NUMINSTRUCTIONS; i++) begin
            assign data_in[((i+1) * DATAW) - 1: i * DATAW] = data[i];
        end
    endgenerate

    assign index = NUMINSTRUCTIONS - ((addr_in - base_addr_in) >> 1);

    initial begin
        rst_n = 0;
        clk = 0;
        write = 0;
        errors = 0;
        addr_in = 0;
        exp_valid = 0;

        for (int i = 0; i < NUMINSTRUCTIONS; i++) begin
            data[i] = $urandom();
        end

        @(posedge clk);
        @(negedge clk);
        rst_n = 1;
        @(posedge clk);
        @(negedge clk);

        if (exp_valid !== valid_out) begin
            errors++;
            $display("Error during setup, Expected valid %d, got %d", exp_valid, valid_out);
        end

        write = 1;
        base_addr_in = 0;
        exp_valid = 1;
        @(posedge clk);
        @(negedge clk);
        write = 0;


        for (int i = 0; i <=  NUMINSTRUCTIONS; i++) begin
            exp_data_out = data[NUMINSTRUCTIONS - i - 1];
            if (i >= NUMINSTRUCTIONS) begin
                exp_valid = 0;
            end


            if (exp_valid !== valid_out) begin
                errors++;
                $display("Error during reading, Expected valid %d, got %d", exp_valid, valid_out);
            end

            if (exp_valid && exp_data_out !== data_out) begin
                errors++;
                $display("Error during reading, Expected data_out %d, got %d", exp_data_out, data_out);
            end

            addr_in += 2;
            @(posedge clk);
            @(negedge clk);

        end

        write = 1;
        base_addr_in = 50;
        addr_in = 48;
        exp_valid = 1;
        @(posedge clk);
        @(negedge clk);
        write = 0;

        for (int i = 0; i <=  NUMINSTRUCTIONS; i++) begin
            exp_data_out = data[NUMINSTRUCTIONS - i];
            if (i >= NUMINSTRUCTIONS) begin
                exp_valid = 0;
            end


            if (exp_valid !== valid_out) begin
                errors++;
                $display("Error during reading, Expected valid %d, got %d", exp_valid, valid_out);
            end

            if (exp_valid && exp_data_out !== data_out) begin
                errors++;
                $display("Error during reading, Expected data_out %d, got %d", exp_data_out, data_out);
            end

            addr_in += 2;
            @(posedge clk);
            @(negedge clk);

        end

        if (errors == 0) begin
            $display("All tests passed!");
        end

        $stop();
    end

endmodule