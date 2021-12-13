module DataCache_tb 
#(
    parameter DATAW=16,
    parameter INW=512,
    parameter ADDRW=32,
    parameter NUMINSTRUCTIONS=INW/DATAW
) ();

    logic clk, rst_n, write;
    logic [INW-1:0] data_in;
    logic [ADDRW-1:0] addr_in;
    logic valid_out, exp_valid;
    logic [INW-1:0] data_out, exp_data_out;

    DataCache DUT (.*);

    always #2 assign clk = ~clk;

    logic [DATAW-1:0] data [NUMINSTRUCTIONS-1:0];

    generate
        for (genvar i = 0; i < NUMINSTRUCTIONS; i++) begin
            assign data_in[((i+1) * DATAW) - 1: i * DATAW] = data[i];
        end
    endgenerate

    integer errors;

    initial begin
        clk = 0;
        rst_n = 0;
        write = 0;
        exp_valid = 0;
        errors = 0;

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
        addr_in = 50;
        exp_valid = 1;

        @(posedge clk);
        @(negedge clk);

        if (exp_valid !== valid_out) begin
            errors++;
            $display("Error during running, Expected valid %d, got %d", exp_valid, valid_out);
        end

        if (data_out !== data_in) begin
            errors++;
            $display("Error during running, Expected data_out %d, got %d", exp_data_out, data_out);
        end

        $stop();

    end


endmodule