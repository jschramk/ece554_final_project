module AudioReader #(
    parameter SIZE = 8,
    parameter SAMPLES = 1048576,
    parameter INPUT_SIZE = 512
) (
    input clk, rst_n,
    input wr_en,
    input [INPUT_SIZE-1:0] data_in,
    input [$clog2(INPUTS_TO_FILL)-1:0] input_index // 0 to 4095
);

localparam INPUTS_TO_FILL = SAMPLES * SIZE / INPUT_SIZE; // 64
localparam SAMPLES_PER_INPUT = INPUT_SIZE / SIZE; // 32

reg [SIZE-1:0] values [SAMPLES-1:0];

wire [SIZE-1:0] input_array [SAMPLES_PER_INPUT-1:0]; // [4:0], wire converting 512 bits of input to 32 16 bit values

genvar i, j;

// this is the same as the FFTInput, just backwards
generate
for(i = 0; i < SAMPLES_PER_INPUT; i++) begin
    for(j = 0; j < SIZE; j += 8) begin
        assign input_array[i][j+7:j] = data_in[SIZE*i+j+7 : SIZE*i+j];
    end
end
endgenerate

always @(posedge clk, negedge rst_n) begin
    
    if(!rst_n) begin
        
        for(int l = 0; l < SAMPLES; l++) begin
            values[l] <= 0;
        end

    end else if(wr_en) begin

        for(int k = 0; k < SAMPLES_PER_INPUT; k++) begin
            values[SAMPLES_PER_INPUT*input_index + k] <= input_array[k];
        end

    end

end

endmodule