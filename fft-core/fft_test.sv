module fft_test();

	logic clk;
	logic reset;
	logic ce;
	logic [31:0] sample;
	logic [31:0] result;
	logic sync;
	
	shortint signed wave [2047:0];
	int cycle;
	longint amp;
	int outfreq;
	int signed outreal;
	int signed outimag;

	fftmain iDUT(.i_clk(clk), .i_reset(reset), .i_ce(ce), .i_sample(sample), .o_result(result), .o_sync(sync)); 

	always #5 clk = ~clk;

	always @(result) begin
		outreal = {{16{result[31]}}, result[31:16]};
		outimag = {{16{result[15]}}, result[15:0]};
		amp = $sqrt((outreal*outreal) + (outimag*outimag));
	end
	
	always @(posedge clk) begin
		cycle = cycle+1;
		if (cycle > 6500) begin
			$stop;
		end
		if (outfreq > -1) begin
			outfreq = outfreq+1;
		end
	end

	initial begin
		clk = 1'b0;
		reset = 1'b0;
		ce = 1'b0;
		sample = 32'h00000000;
		cycle = 0;
		outfreq = -1;
		
		for (int i = 0; i < 2048; i++) begin
			wave[i] = 300 * $sin(2*3.14159/2048*25*i);
		end
		
		for (int j = 0; j < 2048; j++) begin
			sample = {wave[j], 16'h0000};
			ce = 1'b1;
			@(posedge clk) begin end
			@(negedge clk) begin end
			//ce = 1'b0;
		end
		
		@(result) begin end
		outfreq = 0;
	end
endmodule