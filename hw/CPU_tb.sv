module CPU_tb
#(
    INW=512,
    ADDRW=32,
    DATAW=16,
    NUMINSTRUCTIONS=INW/DATAW
) ();


    logic clk, rst_n, tx_done, rd_valid, 
            dma_ready, instr_write_en, cache_stall,
            mem_write_en;
    logic [INW-1:0] common_data_bus_in;
    logic audio_valid;
    logic [INW-1:0] audio_out;
    logic [ADDRW-1:0] mem_address;
    logic [1:0] op;

    logic [DATAW-1:0] data [NUMINSTRUCTIONS-1:0];

    generate
        for (genvar i = 0; i < NUMINSTRUCTIONS; i++) begin
            assign common_data_bus_in[((i+1) * DATAW) - 1: i * DATAW] = data[i];
        end
    endgenerate

    CPU #() DUT (.*);

    always #2 assign clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;

        for (int i = 0; i < NUMINSTRUCTIONS; i++) begin
            data[i] = $urandom();
        end


        @(posedge clk);
        @(negedge clk);
        rst_n = 1;

        @(posedge clk);
        @(negedge clk);
        instr_write_en = 1;

        @(posedge clk);
        @(negedge clk);
        instr_write_en = 0;

        repeat (20) begin
            @(posedge clk);
            @(negedge clk);
        end

        $stop();
    end


endmodule