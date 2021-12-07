module Overdrive (
    input clk,
    input rst_n,
    input prev_module_done,
    input next_module_ready,
    input [31:0] address_in,
    input en,
    input [3:0] magnitude,
    input set_magnitude,
    input [15:0] audio_in [31:0],
    output [31:0] address_out,
    output [15:0] audio_out [31:0],
    output ready_for_data,
    output done
);

	integer i;
	logic [15:0] max_amp;
	
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			address_out <= 32'h00000000;
			for (i=0; i<32; i=i+1) begin
				audio_out[i] <= 16'h0000;
			end
			max_amp <= 16'h0000;
			ready_for_data <= 1'b1;
			done = 1'b0;
		end else begin
			if (set_magnitude) begin
				case(magnitude)
					4'h0 : max_amp <= 16'h7FFF;
					4'h1 : max_amp <= 16'h7777;
					4'h2 : max_amp <= 16'h6EEF;
					4'h3 : max_amp <= 16'h6667;
					4'h4 : max_amp <= 16'h5DDF;
					4'h5 : max_amp <= 16'h5557;
					4'h6 : max_amp <= 16'h4CCF;
					4'h7 : max_amp <= 16'h4447;
					4'h8 : max_amp <= 16'h3BBF;
					4'h9 : max_amp <= 16'h3337;
					4'hA : max_amp <= 16'h2AAF;
					4'hB : max_amp <= 16'h2227;
					4'hC : max_amp <= 16'h199F;
					4'hD : max_amp <= 16'h1117;
					4'hE : max_amp <= 16'h088F;
					4'hF : max_amp <= 16'h0007;
					default: max_amp <= 16'h7FFF;
				endcase
			end
			if (en) begin
				if (
			end else begin
				audio_out <= audio_in;
			end
		end
	end

endmodule