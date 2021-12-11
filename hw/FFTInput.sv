module FFTInput #(
    parameter SIZE = 16,
    parameter SAMPLES = 2048,
    parameter INPUT_SIZE = 512
) (
    input clk, rst_n,
    input [INPUT_SIZE-1:0] data_in, // 512 bits of data from DMA
    input [$clog2(INPUTS_TO_FILL)-1:0] input_index, // index (0 to 63) of location to write new data (multiply by 32 to get start index from 0 to 2047)
    input [$clog2(SAMPLES)-1:0] output_index, // index (0 to 2047) of value to output
    input wr_en,
    output [SIZE-1:0] data_out
);

localparam INPUTS_TO_FILL = SAMPLES * SIZE / INPUT_SIZE;
localparam SAMPLES_PER_INPUT = INPUT_SIZE / SIZE;

reg [SIZE-1:0] values [$clog2(SAMPLES)-1:0];

wire [SIZE-1:0] input_array [$clog2(SAMPLES_PER_INPUT)-1:0]; // wire converting 512 bits of input to 32 16 bit values

int i, j, k;

/*
connect 512-bit data dump to 32 16 bit values
values from dump should be arranged in bytes, lower bytes at lower addresses

ex:

input_array[0][7:0] = data_in[7:0]
input_array[0][15:8] = data_in[15:8]
...
input_array[31][7:0] = data_in[503:496]
input_array[31][15:8] = data_in[511:504]

*/
for(i = 0; i < SAMPLES_PER_INPUT; i++) begin

    for(j = 0; j < SIZE; j += 8) begin
        
        assign input_array[i][j+7:j] = data_in[SIZE*i+j+7:SIZE*i+j];

    end

    //assign input_array[i][7:0] = data_in[16*i+7 : 16*i];
    //assign input_array[i][15:8] = data_in[16*i+15 : 16*i+8];
end

always @(posedge clk, negedge rst_n) begin
    
    if(!rst_n) begin
        
        for(k = 0; k < SAMPLES; k++) begin
            values[k] <= 0;
        end

    end else if(wr_en) begin

        for(k = 0; k < SAMPLES_PER_INPUT; k++) {
            values[INPUTS_TO_FILL*input_index + k] <= input_array[k];
        }

    end

end

assign data_out = values[output_index];

endmodule