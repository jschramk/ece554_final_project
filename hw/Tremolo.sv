module Tremolo (
    input clk,
    input rst_n,
    input en,
    input signed [15:0] audio_in,
    output reg signed [15:0] audio_out
);

logic unsigned [11:0] count;

always @(posedge clk or negedge rst_n) begin

	if(!rst_n) begin

		count <= 12'h000;

	end else begin

		if (en) begin

			if (count[10] == 1'b1) begin

				audio_out <= audio_in >>> 2;

			end else begin

				audio_out <= audio_in;

			end

			count <= count + 1'b1;

		end else begin

			count <= 12'h000;

			audio_out <= audio_in;

		end
		
	end

end

endmodule