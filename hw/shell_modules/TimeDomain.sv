module TimeDomain (
    input clk,
    input rst,
    input [2:0]en,
    input [15:0] audio_in [2047:0],
    output [15:0] audio_out [2047:0],
    output ready_for_data,
    output done
);


endmodule