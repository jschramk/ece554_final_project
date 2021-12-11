module FFTOutput #(
    parameter SIZE = 16,
    parameter SAMPLES = 2048,
    parameter INPUT_SIZE = 512
) (
    input clk, rst_n,
    output [INPUT_SIZE-1:0] data_out,
    input [$clog2(INPUTS_TO_FILL)-1:0] output_index, // 0 to 63
    input [$clog2(SAMPLES)-1:0] input_index, // 0 to 2047
    input wr_en,
    input [SIZE-1:0] data_in
);

localparam INPUTS_TO_FILL = SAMPLES * SIZE / INPUT_SIZE; // 64
localparam SAMPLES_PER_INPUT = INPUT_SIZE / SIZE; // 32

reg [SIZE-1:0] values [SAMPLES-1:0];

wire [SIZE-1:0] output_array [SAMPLES_PER_INPUT-1:0]; // [4:0], wire converting 512 bits of input to 32 16 bit values

genvar i, j, k;
int l;

// this is the same as the FFTInput, just backwards
generate
for(i = 0; i < SAMPLES_PER_INPUT; i++) begin

    for(j = 0; j < SIZE; j += 8) begin
        
        assign data_out[SIZE*i+j+7 : SIZE*i+j] = output_array[i][j+7:j];

    end

end
endgenerate

always @(posedge clk, negedge rst_n) begin
    
    if(!rst_n) begin
        
        for(l = 0; l < SAMPLES; l++) begin
            values[l] <= 0;
        end

    end else if(wr_en) begin

        values[input_index] <= data_in;

    end

end

generate
for(k = 0; k < SAMPLES_PER_INPUT; k++) begin
    assign  output_array[k] = values[SAMPLES_PER_INPUT*output_index + k]; 
end
endgenerate

endmodule