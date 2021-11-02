module cache
  #(
    parameter INDW=16,
    parameter DATAW=16,
    parameter TAGW=6
   )
   (
    input clk, rst_n, write, en, // r_w=0 read, =1 write
    output valid, hit, dirty, err
    input [DATAW-1:0] dataIn, [TAGW-1:0] tagIn,
    output [DATAW-1:0] dataOut, [TAGW-1:0] tagOut,
    input [INDW-1:0] index
   );


    reg [DATAW-1:0] data [INDW-1:0];
    reg [TAGW-1:0] tags [INDW-1:0];
    reg [1:0] status [INDW-1:0];  // {valid, dirty}

    int i;

    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            for(i = 0; i < DEPTH; i++) data[i] <= 0;
        end else if (en) begin
            if (write) begin
                
            end
        end

    end


endmodule