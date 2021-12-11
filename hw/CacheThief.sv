module CacheThief 
#(

 ) (
    input wr_valid, rd_valid, en,
    input [1:0] cpu_addr_top,
    output logic data_cache_re, instr_cache_re, data_cache_we, stall
 );

    always_comb begin
        stall = 0;
        data_cache_re = 0;
        data_cache_we = 0;
        instr_cache_re = 0;

        if (en) begin
            case (cpu_addr_top)
                2'b00: begin    // Instruction section of memory

                    instr_cache_re = rd_valid;
                    stall = ~rd_valid;
                end
                2'b01: begin    // Data_in section of memory
                    data_cache_re = rd_valid;
                    stall = ~rd_valid;
                end
                2'b10: begin    // Data_out section of memory
                    data_cache_we = wr_valid;
                    stall = ~wr_valid;
                end
            endcase
        end
    end

endmodule

// SETUP STEPS
// rst_n -> 1
// host_init -> 1 for at least one cycle, anything past that is fine also (connect to rst_n)
// Wait until ready is set by mem_ctrl (next clk cycle)

// STEPS TO A SUCCESSFUL READ:
// clk 1
// set host_rd_ready - dma controlled
// op -> 1

// clk 2
// mem_ctrl sets host_rgo -> 1 for one cycle

// clk 3
// mem_ctrl sets host_re -> 1
// mem_ctrl sets rd_valid -> 1
