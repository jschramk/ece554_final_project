module Tremolo (
    input clk,
    input rst_n,
    input prev_module_done,
    input next_module_ready,
    input [31:0] address_in,
    input en,
    input signed [15:0] audio_in [31:0],
    output reg [31:0] address_out,
    output reg signed [15:0] audio_out [31:0],
    output reg ready_for_data,
    output reg done
);

	integer i, j;
	logic [1:0] state, nxt_state;
	logic unsigned [7:0] count;
	logic unsigned [7:0] counter;
	
	parameter IDLE = 2'b00;
	parameter BEGIN = 2'b01;
	parameter OUTPUT = 2'b10;
	
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			state <= IDLE;
			counter <= 8'h00;
		end else begin
			state <= nxt_state;
			counter <= count;
		end
	end
	
	always_comb begin
		address_out = address_in;
		case(state)
			IDLE: begin
				for (i=0; i<32; i=i+1) begin
					audio_out[i] <= 16'h0000;
				end
				ready_for_data = 1'b1;
				done = 1'b0;
				if (prev_module_done) begin
					nxt_state = BEGIN;
				end else begin
					nxt_state = IDLE;
				end
				count = counter;
			end
			BEGIN: begin
				if (en) begin
					if (counter[6] == 1'b1) begin
						for (j = 0; j<32; j=j+1) begin
							audio_out[j] = audio_in[j] >> 2;
						end
					end else begin
						audio_out = audio_in;
					end
				end else begin
					audio_out = audio_in;
					count = 8'h00;
				end
				ready_for_data = 1'b0;
				done = 1'b1;
				count = counter + 1'b1;
				nxt_state = OUTPUT;
			end
			OUTPUT: begin
				if (en) begin
					if (counter[6] == 1'b1) begin
						for (j = 0; j<32; j=j+1) begin
							audio_out[j] = audio_in[j] >>> 2;
						end
					end else begin
						audio_out = audio_in;
						count = 8'h00;
					end
				end else begin
					audio_out = audio_in;
				end
				ready_for_data = 1'b0;
				done = 1'b1;
				if (next_module_ready) begin
					nxt_state= IDLE;
				end else begin
					nxt_state = OUTPUT;
				end
				count = counter;
			end
			default: begin
				for (i=0; i<32; i=i+1) begin
					audio_out[i] <= 16'h0000;
				end
				ready_for_data = 1'b0;
				done = 1'b0;
				nxt_state = IDLE;
				count = counter;
			end
		endcase
	end
	
	/*
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
			address_out <= address_in;
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
	end*/

endmodule