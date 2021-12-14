module AudioProcessor_audio_tb;

localparam FFT_BUS_SIZE = 44;

reg clk, rst_n;
reg start;
reg data_wr_en;
reg [5:0] input_index, output_index;
reg [511:0] data_in;
reg pitch_shift_wr_en;
reg [4:0] pitch_shift_semitones;
reg freq_coeff_wr_en;
reg [10:0] freq_coeff_index;
reg [7:0] freq_coeff_in;
reg tremolo_enable_wr_en;
reg tremolo_enable_in;
reg overdrive_enable_wr_en;
reg overdrive_enable_in;
reg overdrive_magnitude_wr_en;
reg [3:0] overdrive_magnitude;

wire [511:0] data_out;

reg [7:0] input_array [0:185663];
reg [15:0] output_array [0:92831];

wire [FFT_BUS_SIZE/2-1:0] fft_real, fft_imag;

wire done;

assign fft_real = dj_disco.fft_output_full[FFT_BUS_SIZE-1:FFT_BUS_SIZE/2];
assign fft_imag = dj_disco.fft_output_full[FFT_BUS_SIZE/2-1:0];

longint cycle_cnt = 0;

int idx, out_idx;

AudioProcessor dj_disco(
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .data_wr_en(data_wr_en),
    .input_index(input_index),
    .data_in(data_in),
    .pitch_shift_wr_en(pitch_shift_wr_en),
    .pitch_shift_semitones(pitch_shift_semitones),
    .freq_coeff_wr_en(freq_coeff_wr_en),
    .freq_coeff_index(freq_coeff_index),
    .freq_coeff_in(freq_coeff_in),
    .overdrive_enable_wr_en(overdrive_enable_wr_en), 
    .overdrive_enable_in(overdrive_enable_in),
    .overdrive_magnitude_wr_en(overdrive_magnitude_wr_en),
    .overdrive_magnitude(overdrive_magnitude),
    .tremolo_enable_wr_en(tremolo_enable_wr_en),
    .tremolo_enable_in(tremolo_enable_in),
    .output_index(output_index),
    .data_out(data_out),
    .done(done)
);


initial begin
    
    init();

    reset();
		
		/*set_pitch_shift(-2);
		set_overdrive_enable(1'b1);
		set_overdrive_magnitude(4'h5);
		set_tremolo_enable(1'b1);
		for (int y = 0; y < 256; y++) begin
			set_freq_coeff(y, 3);
			set_freq_coeff(1023-y, 3);
		end*/

		repeat (22) begin
			fill_input_data(idx);

			start_process();
			
			@(posedge done);
			
			for (int x = 0; x < 64; x++) begin
				output_index = x;
				for (int y = 0; y < 32; y++) begin
					output_array[out_idx+x+y*64] = data_out[16*y+:16];
				end
				@(posedge clk);
			end
		
			out_idx += 2048;
		end
		
		$writememh("processed.txt", output_array);

    $stop();

end

always begin
    #3 clk = ~clk;
    if(clk) cycle_cnt++;
end


/*genvar i, j;
generate
for(i = 0; i < 14880; i++) begin

    for(j = 0; j < 16; j += 8) begin
        
        assign data_in[16*i+j+7 : 16*i+j] = input_array[i][j+7:j];

    end

end
endgenerate*/

/*genvar q,r;
generate
	for (q = 0; q < 64; q++) begin
		assign data_in[7+(q*8):q*8] = input_array[idx+q];
	end
endgenerate*/

/*always @(posedge done) begin
	for (int r = 0; r < 32; r++) begin
		output_array[idx+r] = data_out[r*16+15-:15];
	end
end*/



// BEGIN TASKS ---------------------------------------------------------------------------------------------

task init();
		idx = 0;
		out_idx = 0;
    clk = 0;
    rst_n = 1;
    start = 0;
    data_wr_en = 0;
    input_index = 0;
    output_index = 0;
    pitch_shift_wr_en = 0;
    freq_coeff_wr_en = 0;
		overdrive_enable_in = 0;
		overdrive_enable_wr_en = 0;
		overdrive_magnitude = 0;
		overdrive_magnitude_wr_en = 0;
    tremolo_enable_in = 0;
    tremolo_enable_wr_en = 0;
    //data_in = 512'h0;
		$readmemb("out.txt", input_array);
endtask

task reset();
    @(posedge clk) rst_n = 0;
    @(posedge clk) rst_n = 1;
endtask

// starts the processor
task start_process();
    @(posedge clk) start = 1;
    @(posedge clk) start = 0;
endtask

// fill the input data into the 512 bit bus
task populate_bus(int index);
    /*for(int l = 0; l < 32; l++) begin
        input_array[l] = 
            20000 * $cos(2*3.141592653/2048 * 50 * (l + 32 * index));// + 
            //10000 * $cos(2*3.141592653/2048 * 3 * (l + 32 * index));
    end*/
		for (int q = 0; q < 64; q++) begin
			data_in[q*8+:8] = input_array[index*64+idx+q];
			$display("%b", data_in[q*8+:8]);
		end
endtask

// fill the module's input with a test wave defined in populate_bus()
task fill_input_data(reg index);
    data_wr_en = 1;
    for(int i = 0; i < 64; i++) begin
        input_index = i;
        populate_bus(i);
        @(posedge clk);
    end
		idx += 4096;
    data_wr_en = 0;
endtask

// turn tremolo on or off
task set_tremolo_enable(reg en);
    tremolo_enable_in = en;
    @(posedge clk) tremolo_enable_wr_en = 1;
    @(posedge clk) tremolo_enable_wr_en = 0;
endtask

// turn overdrive on or off
task set_overdrive_enable(reg en);
    overdrive_enable_in = en;
    @(posedge clk) overdrive_enable_wr_en = 1;
    @(posedge clk) overdrive_enable_wr_en = 0;
endtask

// set the magnitude of the overdrive
task set_overdrive_magnitude(reg [3:0] magnitude);
    overdrive_magnitude = magnitude;
    @(posedge clk) overdrive_magnitude_wr_en = 1;
    @(posedge clk) overdrive_magnitude_wr_en = 0;
endtask

// set the amount of pitch shift
task set_pitch_shift(reg[4:0] semitones);
    pitch_shift_semitones = semitones;
    @(posedge clk) pitch_shift_wr_en = 1;
    @(posedge clk) pitch_shift_wr_en = 0;
endtask

// set a frequency coefficient for the equalizer
task set_freq_coeff(reg [10:0] bucket, reg [7:0] coeff);
    freq_coeff_index = bucket;
    freq_coeff_in = coeff;
    @(posedge clk) freq_coeff_wr_en = 1;
    @(posedge clk) freq_coeff_wr_en = 0;
endtask

endmodule