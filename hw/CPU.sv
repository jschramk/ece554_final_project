module CPU #(
    NUMREGISTERS=8,
    DATAW=32,
    ADDRW=32,
    INW=512
) (
    input clk, rst_n, tx_done, rd_valid, dma_ready, instr_write_en, cache_stall,
    input [DATAW-1:0] common_data_bus_in(cpu_in),
    output [DATAW-1:0] common_data_bus_out(cpu_out),
    output [ADDRW-1:0] io_address(cpu_addr),
    output [1:0] op
);

wire stall;

Fetch #(

) fetch (
    .clk(clk), .rst_n(rst_n), .halt(halt), .stall(stall), .branch(branch_out_execute),
    .instr_write_en(instr_write_en), .PC_branch(PC_out_execute), .instr_in(),
    .valid_out(), .instr_out(), .PC_out()
);

FetchDecodePipe #(

) fetchDecodePipe (

);

Decode #(
    .NUMREGISTERS(NUMREGISTERS),
    .DATAW(DATAW)
) decode (
    .instr(instr_decode),
    .reg_wr_en_in(reg_wr_en_in),
    .rst_n(rst_n),
    .clk(clk),
    .wr_reg(wr_reg),
    .wr_data(wr_data),
    .a(a_decode),
    .b(b_decode),
    .imm(imm_decode),
    .shift_dist(shift_dist_decode),
    .halt(halt),
    .alu_op(alu_op_decode),
    .reg_wr_en_out(reg_wr_en_out_decode),
    .mem_wr_en(mem_wr_en_decode),
    .branch(branch_decode),
    .fft_wr_en(fft_wr_en_decode),
    .set_en(set_en),
    .syn(syn),
    .use_imm(use_imm_decode),
    .set_freq(set_freq)
);

DecodeExecutePipe #(

) decodeExecutePipe (
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
    .alu_op_out(alu_op_execute),
    .reg_wr_en_out(reg_wr_en_execute),
    .mem_wr_en_out(mem_wr_en_execute),
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

) executeMemoryPipe(

);

Memory #(

) memory (

);

MemoryWritebackPipe #(

) memoryWritebackPipe(

);



endmodule