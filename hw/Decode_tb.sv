module Decode_tb
 #(
    NUMREGISTERS=8,
    DATAW=32
  ) ();

  logic [DATAW-1:0] wr_data, a, b, exp_a, exp_b;
  logic [15:0] instr;
  logic [10:0] imm, exp_imm;
  logic [2:0] wr_reg, a_reg, b_reg, exp_a_reg, exp_b_reg;
  logic [1:0] shift_dist, exp_shift_dist;
  logic reg_wr_en_in, rst_n, clk, halt, alu_op, reg_wr_en_out,
      mem_wr_en, branch, fft_wr_en, set_en, syn, use_imm, set_freq,
      exp_halt, exp_alu_op,
      exp_reg_wr_en_out, exp_mem_wr_en, exp_branch, exp_fft_wr_en,
      exp_set_en, exp_syn, exp_use_imm, exp_set_freq;


  logic [DATAW-1:0] data [7:0];

  Decode #(.NUMREGISTERS(NUMREGISTERS), .DATAW(DATAW)) DUT (
  .instr(instr), .reg_wr_en_in(reg_wr_en_in), .rst_n(rst_n), .clk(clk),
  .wr_reg(wr_reg), .wr_data(wr_data), .a(a), .b(b), .imm(imm),
  .shift_dist(shift_dist), .halt(halt), .alu_op(alu_op), .reg_wr_en_out(reg_wr_en_out),
  .mem_wr_en(mem_wr_en), .branch(branch), .fft_wr_en(fft_wr_en),
  .set_en(set_en), .syn(syn), .use_imm(use_imm), .set_freq(set_freq)
  );

  integer errors;

  assign a_reg = instr[10:8];
  assign b_reg = instr[7:5];

  always #5 clk = ~clk;

  initial begin
    clk = 0;
    rst_n = 0;
    instr = 0;
    errors = 0;

    // Setup data to be inserted into register
    for (int i = 0; i < 8; i++) begin
      data[i] = $urandom();
    end

    @(posedge clk);
    rst_n = 1;
    @(negedge clk);

    // Check that reset has been run correctly
    instr[15:11] = 5'b01000;
    exp_a = 0;
    exp_b = 0;
    for (int i = 0; i < 8; i+=2) begin
      instr[10:8] = i;
      instr[7:5] = i+1;

      @(posedge clk);
      @(negedge clk);
      if (a !== exp_a) begin
        errors++;
        $display("Decode did not reset register correctly. Expected a %d, got %d", exp_a, a);
      end
      if (b !== exp_b) begin
        errors++;
        $display("Decode did not reset register correctly. Expected b %d, got %d", exp_b, b);
      end
    end


    // Check that writing data to the registers is working correctly
    reg_wr_en_in = 1;
    for (int i = 0; i < 8; i++) begin
      wr_reg = i;
      wr_data = data[i];
      @(posedge clk);
      @(negedge clk);
    end
    reg_wr_en_in = 0;

    for (int i = 0; i < 8; i += 2) begin
      instr[10:8] = i;
      instr[7:5] = i+1;

      exp_a = data[i];
      exp_b = data[i+1];

      @(posedge clk);
      @(negedge clk);
      if (a !== exp_a) begin
        errors++;
        $display("Decode did not fill register correctly. Expected a %d, got %d", exp_a, a);
      end
      if (b !== exp_b) begin
        errors++;
        $display("Decode did not fill register correctly. Expected b %d, got %d", exp_b, b);
      end
    end

    // Check that signals are being set + passed correctly
    for (int i = 0; i < 500; i++) begin
      instr = $urandom();
      exp_halt = instr[15:11] == 5'b00000;
      exp_alu_op = instr[15:11] == 5'b01010;
      exp_reg_wr_en_out = instr[15:13] == 3'b001 || instr[15:11] == 5'b01010;
      exp_mem_wr_en = instr[15:11] == 5'b01001;
      exp_branch = instr[15:11] == 5'b01011;
      exp_fft_wr_en = instr[15:11] == 5'b01000;
      exp_set_en = instr[15:11] == 5'b01110;
      exp_syn = instr[15:11] == 5'b01111;
      exp_use_imm = instr[15:13] == 3'b001;
      exp_set_freq = instr[15:13] == 5'b01100;
      exp_shift_dist = instr[12:11];
      
      @(posedge clk);
      @(negedge clk);

      if (exp_halt !== halt) begin
          errors++;
          $display("Error decoding instruction. Expected halt %d, got %d", exp_halt, halt);
      end
      if (exp_alu_op !== alu_op) begin
          errors++;
          $display("Error decoding instruction. Expected alu_op %d, got %d", exp_alu_op, alu_op);
      end
      if (exp_reg_wr_en_out !== reg_wr_en_out) begin
          errors++;
          $display("Error decoding instruction. Expected reg_wr_en %d, got %d", exp_reg_wr_en_out, reg_wr_en_out);
      end
      if (exp_mem_wr_en !== mem_wr_en) begin
          errors++;
          $display("Error decoding instruction. Expected mem_wr_en %d, got %d", exp_mem_wr_en, mem_wr_en);
      end
      if (exp_branch !== branch) begin
          errors++;
          $display("Error decoding instruction. Expected branch %d, got %d", exp_branch, branch);
      end
      if (exp_fft_wr_en !== fft_wr_en) begin
          errors++;
          $display("Error decoding instruction. Expected fft_wr_en %d, got %d", exp_fft_wr_en, fft_wr_en);
      end
      if (exp_set_en !== set_en) begin
          errors++;
          $display("Error decoding instruction. Expected set_en %d, got %d", exp_set_en, set_en);
      end
      if (exp_syn !== syn) begin
          errors++;
          $display("Error decoding instruction. Expected syn %d, got %d", exp_syn, syn);
      end
      if (exp_use_imm !== use_imm) begin
          errors++;
          $display("Error decoding instruction. Expected use_imm %d, got %d", exp_use_imm, use_imm);
      end
      if (exp_set_freq !== set_freq) begin
          errors++;
          $display("Error decoding instruction. Expected set_freq %d, got %d", exp_set_freq, set_freq);
      end
      if (exp_shift_dist !== shift_dist) begin
          errors++;
          $display("Error decoding instruction. Expected shift_dist %d, got %d", exp_shift_dist, shift_dist);
      end
    end

    if (errors == 0) begin
        $display("No errors found!");
    end

    $stop();
  end

endmodule