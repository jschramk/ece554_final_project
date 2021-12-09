module CPU 
 #(
    NUMREGISTERS=8,
    DATAW=32
  ) (
      input clk, rst_n, 
  );

    mem_ctrl memory(
       .clk(clk),
       .rst_n(~rst),
       .host_init(go),
       .host_rd_ready(~dma.empty),
       .host_wr_ready(~dma.full & ~dma.host_wr_completed),
       .op(mem_op), // CPU Defined
       .common_data_bus_read_in(cpu_out), // CPU data word bus, input
       .common_data_bus_write_out(cpu_in),
       .host_data_bus_read_in(dma.rd_data),
       .host_data_bus_write_out(dma.wr_data),
       .ready(ready), // Usable for the host CPU
       .tx_done(tx_done), // Again, notifies CPU when ever a read or write is complete
       .rd_valid(rd_valid), // Notifies CPU whenever the data on the databus is valid
       .host_re(local_dma_re),
       .host_we(local_dma_we),
       .host_rgo(rd_go),
       .host_wgo(wr_go)
   );











    Fetch #() fetch ();

    FetchDecodePipe #() fetchDecodePipe ();

    Decode #(.NUMREGISTERS(NUMREGISTERS), .DATAW(DATAW)) decode 
       (.instr(instr_decode), .reg_wr_en_in(reg_wr_en_in), .rst_n(rst_n), .clk(clk),
        .wr_reg(wr_reg), .wr_data(wr_data), .a(a_decode), .b(b_decode), .imm(imm_decode),
        .shift_dist(shift_dist_decode), .halt(halt), .alu_op(alu_op_decode), .reg_wr_en_out(reg_wr_en_out_decode),
        .mem_wr_en(mem_wr_en_decode), .branch(branch_decode), .fft_wr_en(fft_wr_en_decode),
        .set_en(set_en), .syn(syn), .use_imm(use_imm_decode), .set_freq(set_freq));

    DecodeExecutePipe #() decodeExecutePipe(
        .clk(clk), .flush(), .stall(stall), .alu_op_in(alu_op_decode), 
        .reg_wr_en_in(reg_wr_en_out_decode),  .mem_wr_en_in(mem_wr_en_decode), 
        .shift_dist_in(shift_dist_decode),  .branch_in(branch_decode), 
        .fft_wr_en_in(fft_wr_en_decode), 
        .a_in(a_decode),  .b_in(b_decode), 
        .PC_in(PC_decode), .use_imm_in(use_imm_decode),
        .imm_in(imm_decode), 
        .alu_op_out(alu_op_execute),
        .reg_wr_en_out(reg_wr_en_execute),  .mem_wr_en_out(mem_wr_en_execute),
        .shift_dist_out(shift_dist_execute),  .branch_out(branch_in_execute),
        .fft_wr_en_out(fft_wr_en_execute),
        .a_out(a_execute),  .b_out(b_execute),
        .PC_out(PC_in_execute), .use_imm_out(use_imm_execute),
        .imm_out(imm_execute));

    Execute #(.NUMREGISTERS(NUMREGISTERS), .DATAW(DATAW)) execute 
       (.alu_op(alu_op_execute), .branch_in(branch_in_execute), .use_imm(use_imm_execute),
        .branch_out(branch_out_execute), .shift_dist(shift_dist_execute), .a(a_execute), .b(b_execute), .p_flag_in(p_flag_in),
        .ex_out(ex_out), .PC_in(PC_in_execute), .PC_out(PC_out_execute), .imm(imm_execute), .p_flag_out(p_flag_out));

    ExecuteMemoryPipe #() executeMemoryPipe();

    Memory #() memory();

    MemoryWritebackPipe #() memoryWritebackPipe();



endmodule