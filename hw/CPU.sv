module CPU #(
    NUMREGISTERS=8,
    DATAW=32,
    ADDRW=32,
    PCW=32,
    INW=512,
    INSTRW=16,
    REGW=3,
    IMMW=11
) (
    input clk, rst_n, tx_done, rd_valid, 
            dma_ready, instr_write_en, cache_stall,
            mem_write_en,
    input [INW-1:0] common_data_bus_in,
    output audio_valid,
    output [INW-1:0] audio_out,
    output [ADDRW-1:0] mem_address,
    output [1:0] op
);


// TODO: Track down missing write register 
//      (we have input to Decode written, but no output passed through)

// TODO: Continue writing all bus wires - stopped around decode area

wire stall, instr_valid, fft_wr_en_memory, mem_valid;

wire [1:0]          shift_dist_decode

wire [REGW-1:0]     wr_reg_writeback

wire [IMMW-1:0]     imm_decode

wire [INSTRW-1:0]   instr_fetch, instr_decode

wire [PCW-1:0]      PC_out_execute, PC_out_fetch, PC_decode

wire [DATAW-1:0]    wr_data, a_decode, b_decode


assign mem_address  =   (!instr_valid) ? PC_out_fetch :
                        (fft_wr_en_memory && !mem_valid) ? ex_out_memory:
                        32'b0;
assign op           =   (!instr_valid) ? 2'b01 : 
                        (fft_wr_en_memory && !mem_valid) ? 2'b01 :
                        2'b00;

Fetch #(
    .PCW(PCW),
    .INSTRW(INSTRW),
    .INW(INW)
) fetch (
    .clk(clk), .rst_n(rst_n), .halt(halt), .stall(stall), .branch(branch_out_execute),
    .instr_write_en(instr_write_en), .PC_branch(PC_out_execute), .instr_data_in(common_data_bus_in),
    .valid_out(instr_valid), .instr_out(instr_fetch), .PC_out(PC_out_fetch)
);

FetchDecodePipe #(
    .PCW(PCW),
    .INSTRW(INSTRW),
) fetchDecodePipe (
    // Inputs
    .clk(clk), .flush(), .stall(stall),
    .PC_in(PC_out_fetch), 
    .instr_in(instr_fetch),

    // Outputs
    .PC_out(PC_decode), 
    .instr_out(instr_decode)
);

Decode #(
    .NUMREGISTERS(NUMREGISTERS),
    .DATAW(DATAW)
) decode (
    // Inputs
    .clk(clk),
    .rst_n(rst_n),
    .reg_wr_en_in(reg_wr_en_writeback),
    .wr_reg(wr_reg_writeback),
    .instr(instr_decode),
    .wr_data(wr_data),

    // Outputs
    .halt(halt),
    .alu_op(alu_op_decode),
    .reg_wr_en_out(reg_wr_en_out_decode),
    .mem_wr_en(mem_wr_en_decode),
    .branch(branch_decode),
    .fft_wr_en(fft_wr_en_decode),
    .set_en(set_en),
    .syn(syn),
    .use_imm(use_imm_decode),
    .set_freq(set_freq),
    .shift_dist(shift_dist_decode),
    .imm(imm_decode),
    .a(a_decode),
    .b(b_decode)
);

DecodeExecutePipe #(
    DATAW(DATAW),
    PCW(PCW)
) decodeExecutePipe (
    //Inputs
    .clk(clk),
    .flush(),
    .stall(stall),
    .alu_op_in(alu_op_decode), 
    .reg_wr_en_in(reg_wr_en_out_decode),
    .mem_wr_en_in(mem_wr_en_decode), 
    .shift_dist_in(shift_dist_decode),
    .branch_in(branch_decode), 
    .fft_wr_en_in(fft_wr_en_decode), 
    .a_in(a_decode),
    .b_in(b_decode), 
    .PC_in(PC_decode),
    .use_imm_in(use_imm_decode),
    .imm_in(imm_decode),

    //Outputs
    .alu_op_out(alu_op_execute),
    .reg_wr_en_out(reg_wr_en_execute),
    .mem_wr_en_out(mem_wr_en_execute),  // might be unused at this point
    .shift_dist_out(shift_dist_execute),
    .branch_out(branch_in_execute),
    .fft_wr_en_out(fft_wr_en_execute),
    .a_out(a_execute),
    .b_out(b_execute),
    .PC_out(PC_in_execute),
    .use_imm_out(use_imm_execute),
    .imm_out(imm_execute)
);

Execute #(
    .NUMREGISTERS(NUMREGISTERS),
    .DATAW(DATAW)
) execute (
    .alu_op(alu_op_execute),
    .branch_in(branch_in_execute),
    .use_imm(use_imm_execute),
    .branch_out(branch_out_execute),
    .shift_dist(shift_dist_execute),
    .a(a_execute),
    .b(b_execute),
    .p_flag_in(p_flag_in),
    .ex_out(ex_out),
    .PC_in(PC_in_execute),
    .PC_out(PC_out_execute),
    .imm(imm_execute),
    .p_flag_out(p_flag_out)
);

ExecuteMemoryPipe #(
    .DATAW(DATAW)
) executeMemoryPipe(
    // Inputs
    .clk(clk), .flush(), .stall(stall),
    .fft_wr_en_in(fft_wr_en_execute), 
    .reg_wr_en_in(reg_wr_en_execute),
    .ex_data_in(ex_out),

    // Outputs
    .fft_wr_en_out(fft_wr_en_memory),
    .reg_wr_en_out(reg_wr_en_memory),
    .ex_data_out(ex_out_memory)
);

Memory #(
    .DATAW(DATAW),
    .INW(INW),
    .ADDRW(ADDRW),
) memory (
    .clk(clk), .rst_n(rst_n), .write(mem_write_en),
    .data_in(common_data_bus_in),
    .addr_in(ex_out_memory),
    .valid_out(cache_valid_memory),
    .data_out(data_out_memory)
);

MemoryWritebackPipe #(
    .DATAW(DATAW),
    .ADDRW(ADDRW)
) memoryWritebackPipe(
    // Inputs
    .clk(clk), .flush(rst_n), .stall(stall),
    .valid_in(cache_valid_memory),
    .addr_in(ex_out_memory),
    .data_in(data_out_memory),
    .fft_wr_en_in(fft_wr_en_memory),
    .reg_wr_en_in(reg_wr_en_memory),

    // Outputs
    .valid_out(audio_valid),
    .addr_out(ex_out_writeback),
    .data_out(audio_out),
    .fft_wr_en_out(fft_wr_en_writeback),
    .reg_wr_en_out(reg_wr_en_writeback)
);

endmodule