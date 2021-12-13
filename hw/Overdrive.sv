module Overdrive (
    input clk,
    input rst_n,
    input en,
    input [3:0] magnitude,
    input set_magnitude,
    input signed [15:0] audio_in,
    output reg signed [15:0] audio_out
);

logic signed [15:0] max_amp;

always @(posedge clk or negedge rst_n) begin

	if(!rst_n) begin

		max_amp <= 16'h7FFF;

	end else begin

		if (set_magnitude) begin

			case(magnitude)
				4'h0 : max_amp <= 16'h7FFF;
				4'h1 : max_amp <= 16'h7777;
				4'h2 : max_amp <= 16'h6EEF;
				4'h3 : max_amp <= 16'h6667;
				4'h5 : max_amp <= 16'h5557;
				4'h6 : max_amp <= 16'h4CCF;
				4'h4 : max_amp <= 16'h5DDF;
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

			if(audio_in > max_amp) begin

				audio_out = max_amp;

			end else if(audio_in < (max_amp * -1)) begin

				audio_out = max_amp * -1;

			end else begin

				audio_out = audio_in;

			end

		end else begin

			audio_out = audio_in;

		end

	end
	
end

endmodule