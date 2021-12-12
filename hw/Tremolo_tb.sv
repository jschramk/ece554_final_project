module Tremolo_tb();

	logic clk;
	logic rst_n;
	//logic prev_module_done;
	//logic next_module_ready;
	logic [31:0] address_in;
	logic en;
	logic signed [15:0] audio_in;
	logic [31:0] address_out;
	logic signed [15:0] audio_out;
	//logic ready_for_data;
	//logic done;
	
	//logic [15:0] inplot;
	//logic [15:0] outplot;
	
	Tremolo iDUT(.clk(clk), .rst_n(rst_n), /*.prev_module_done(prev_module_done),
			.next_module_ready(next_module_ready),*/ .address_in(address_in),
			.en(en), .audio_in(audio_in), .address_out(address_out), 
			.audio_out(audio_out)/*, .ready_for_data(ready_for_data), .done(done)*/);
			
	always #4 clk = ~clk;
	
	initial begin
		clk = 1'b0;
		rst_n = 1'b0;
		@(posedge clk) begin end
		rst_n = 1'b1;
		address_in = 32'h00000000;
		en = 1'b1;
		for (int i = 0; i < 2048; i++) begin
			audio_in = 16'h7FFF * $sin(2*3.14159*i/45056*1188);
			@(posedge clk) begin end
		end
		for (int i = 0; i <2048; i++) begin
			audio_in = 16'h7FFF * $sin(2*3.14159*i/45056*2376);
			@(posedge clk) begin end
		end
		$stop;
		
		/*clk = 1'b0;
		rst_n = 1'b0;
		prev_module_done = 1'b0;
		next_module_ready = 1'b0;
		address_in = 32'h00000000;
		en = 1'b0;
		
		for (int j = 0; j < 512; j=j+1) begin
			for (int i = 0; i < 32; i=i+1) begin
				inplot = 16'h7FFF * $sin(2*3.14159*(i+32*j)/45056*1188);
				audio_in[i] = inplot;
				@(posedge clk) begin end
			end
			@(posedge clk) begin end
			rst_n = 1'b1;
			@(posedge clk) begin end
			prev_module_done = 1'b1;
			@(posedge clk) begin end
			en = 1'b1;
			@(posedge clk) begin end
			prev_module_done = 1'b0;
			@(posedge clk) begin end
			for (int j = 0; j < 32; j=j+1) begin
				outplot = audio_out[j];
				@(posedge clk) begin end
			end
			next_module_ready = 1'b1;
			@(posedge clk) begin end
			next_module_ready = 1'b0;
		end
		
		/*@(posedge clk) begin end
		for (int i = 0; i < 32; i=i+1) begin
			inplot = 16'h7FFF * $sin(2*3.14159*(32+i)/45056*1188);
			audio_in[i] = inplot;
			@(posedge clk) begin end
		end
		@(posedge clk) begin end
		rst_n = 1'b1;
		@(posedge clk) begin end
		next_module_ready = 1'b0;
		magnitude = 4'h3;
		set_magnitude = 1'b1;
		@(posedge clk) begin end
		set_magnitude = 1'b0;
		prev_module_done = 1'b1;
		@(posedge clk) begin end
		en = 1'b1;
		@(posedge clk) begin end
		prev_module_done = 1'b0;
		@(posedge clk) begin end
		for (int j = 0; j < 32; j=j+1) begin
			outplot = audio_out[j];
			@(posedge clk) begin end
		end
		
		next_module_ready = 1'b1;
		@(posedge clk) begin end
		for (int i = 0; i < 32; i=i+1) begin
			inplot = 16'h7FFF * $sin(2*3.14159*(64+i)/45056*1188);
			audio_in[i] = inplot;
			@(posedge clk) begin end
		end
		@(posedge clk) begin end
		rst_n = 1'b1;
		@(posedge clk) begin end
		next_module_ready = 1'b0;
		magnitude = 4'h3;
		set_magnitude = 1'b1;
		@(posedge clk) begin end
		set_magnitude = 1'b0;
		prev_module_done = 1'b1;
		@(posedge clk) begin end
		en = 1'b1;
		@(posedge clk) begin end
		prev_module_done = 1'b0;
		@(posedge clk) begin end
		for (int j = 0; j < 32; j=j+1) begin
			outplot = audio_out[j];
			@(posedge clk) begin end
		end*/
		//$stop;
	end
endmodule