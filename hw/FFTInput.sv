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

localparam INPUTS_TO_FILL = SAMPLES * SIZE / INPUT_SIZE; // 64
localparam SAMPLES_PER_INPUT = INPUT_SIZE / SIZE; // 32

reg [SIZE-1:0] values [SAMPLES-1:0];

wire [SIZE-1:0] input_array [SAMPLES_PER_INPUT-1:0]; // [4:0], wire converting 512 bits of input to 32 16 bit values

genvar i, j;
int k;

/*
connect 512-bit data dump to 32 16 bit values
values from dump should be arranged in bytes, lower bytes at lower addresses

ex:

input_array[0][7:0] = data_in[7:0]
input_array[0][15:8] = data_in[15:8]
input_array[1][7:0] = data_in[23:16]
input_array[1][15:8] = data_in[31:24]
...
input_array[31][7:0] = data_in[503:496]
input_array[31][15:8] = data_in[511:504]

*/
generate
for(i = 0; i < SAMPLES_PER_INPUT; i++) begin

    for(j = 0; j < SIZE; j += 8) begin
        
        assign input_array[i][j+7:j] = data_in[SIZE*i+j+7 : SIZE*i+j];

    end

end
endgenerate

// assign input_array[0][7:0] = data_in[7:0];
// assign input_array[0][15:8] = data_in[15:8];
// assign input_array[1][7:0] = data_in[23:16];
// assign input_array[1][15:8] = data_in[31:24];
// assign input_array[2][7:0] = data_in[39:32];
// assign input_array[2][15:8] = data_in[47:40];
// assign input_array[3][7:0] = data_in[55:48];
// assign input_array[3][15:8] = data_in[63:56];
// assign input_array[4][7:0] = data_in[71:64];
// assign input_array[4][15:8] = data_in[79:72];
// assign input_array[5][7:0] = data_in[87:80];
// assign input_array[5][15:8] = data_in[95:88];
// assign input_array[6][7:0] = data_in[103:96];
// assign input_array[6][15:8] = data_in[111:104];
// assign input_array[7][7:0] = data_in[119:112];
// assign input_array[7][15:8] = data_in[127:120];
// assign input_array[8][7:0] = data_in[135:128];
// assign input_array[8][15:8] = data_in[143:136];
// assign input_array[9][7:0] = data_in[151:144];
// assign input_array[9][15:8] = data_in[159:152];
// assign input_array[10][7:0] = data_in[167:160];
// assign input_array[10][15:8] = data_in[175:168];
// assign input_array[11][7:0] = data_in[183:176];
// assign input_array[11][15:8] = data_in[191:184];
// assign input_array[12][7:0] = data_in[199:192];
// assign input_array[12][15:8] = data_in[207:200];
// assign input_array[13][7:0] = data_in[215:208];
// assign input_array[13][15:8] = data_in[223:216];
// assign input_array[14][7:0] = data_in[231:224];
// assign input_array[14][15:8] = data_in[239:232];
// assign input_array[15][7:0] = data_in[247:240];
// assign input_array[15][15:8] = data_in[255:248];
// assign input_array[16][7:0] = data_in[263:256];
// assign input_array[16][15:8] = data_in[271:264];
// assign input_array[17][7:0] = data_in[279:272];
// assign input_array[17][15:8] = data_in[287:280];
// assign input_array[18][7:0] = data_in[295:288];
// assign input_array[18][15:8] = data_in[303:296];
// assign input_array[19][7:0] = data_in[311:304];
// assign input_array[19][15:8] = data_in[319:312];
// assign input_array[20][7:0] = data_in[327:320];
// assign input_array[20][15:8] = data_in[335:328];
// assign input_array[21][7:0] = data_in[343:336];
// assign input_array[21][15:8] = data_in[351:344];
// assign input_array[22][7:0] = data_in[359:352];
// assign input_array[22][15:8] = data_in[367:360];
// assign input_array[23][7:0] = data_in[375:368];
// assign input_array[23][15:8] = data_in[383:376];
// assign input_array[24][7:0] = data_in[391:384];
// assign input_array[24][15:8] = data_in[399:392];
// assign input_array[25][7:0] = data_in[407:400];
// assign input_array[25][15:8] = data_in[415:408];
// assign input_array[26][7:0] = data_in[423:416];
// assign input_array[26][15:8] = data_in[431:424];
// assign input_array[27][7:0] = data_in[439:432];
// assign input_array[27][15:8] = data_in[447:440];
// assign input_array[28][7:0] = data_in[455:448];
// assign input_array[28][15:8] = data_in[463:456];
// assign input_array[29][7:0] = data_in[471:464];
// assign input_array[29][15:8] = data_in[479:472];
// assign input_array[30][7:0] = data_in[487:480];
// assign input_array[30][15:8] = data_in[495:488];
// assign input_array[31][7:0] = data_in[503:496];
// assign input_array[31][15:8] = data_in[511:504];


always @(posedge clk, negedge rst_n) begin
    
    if(!rst_n) begin
        
        for(k = 0; k < SAMPLES; k++) begin
            values[k] <= 0;
        end

    end else if(wr_en) begin

        for(k = 0; k < SAMPLES_PER_INPUT; k++) begin
           values[SAMPLES_PER_INPUT*input_index + k] <= input_array[k]; 
        end

    end

end

assign data_out = values[output_index];

endmodule