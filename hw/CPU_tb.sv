module CPU_tb
#(
    INW=512,
    ADDRW=32,
    DATAW=32,
    IMMW=11,
    INSTRW=16,
    NUMINSTRUCTIONS=INW/INSTRW
) ();


    logic clk, rst_n, tx_done, rd_valid, 
            dma_ready, instr_write_en, cache_stall,
            mem_write_en, syn, set_en, set_freq;
    logic [INW-1:0] common_data_bus_in;
    logic audio_valid;
    logic [IMMW-1:0] imm;
    logic [INW-1:0] audio_out;
    logic [ADDRW-1:0] mem_address;
    logic [1:0] op;

    logic [INSTRW-1:0] data_flipped [NUMINSTRUCTIONS-1:0];
    logic [INSTRW-1:0] data [NUMINSTRUCTIONS-1:0];

    generate
        for (genvar i = 0; i < NUMINSTRUCTIONS; i++) begin
            assign common_data_bus_in[((i+1) * INSTRW) - 1: i * INSTRW] = data[i];
        end

        for (genvar i = 0; i < NUMINSTRUCTIONS; i++) begin
            assign data[i] = {data_flipped[NUMINSTRUCTIONS-i-1][7:0], data_flipped[NUMINSTRUCTIONS-i-1][15:8]} ;
        end
    endgenerate

    CPU #() DUT (.*);

    always #2 assign clk = ~clk;

    integer file, status;

    initial begin
        clk = 0;
        rst_n = 0;

        file = $fopen("E:/ECE 554/final/hw/instructions.data", "rb");
        
        if (!file) begin
            $display("Could not open file");
            $stop();
        end
        
        //for (int i = NUMINSTRUCTIONS; i >= 0; i--) begin
            status = $fread(data_flipped, file);
            //$display("Read data: %h from file", data);
        //end
        


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

        mem_write_en = 1;

        @(posedge clk);
        @(negedge clk);

        mem_write_en = 0;
        
        repeat (20) begin
            @(posedge clk);
            @(negedge clk);
        end

        $stop();
    end


endmodule