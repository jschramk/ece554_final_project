module cache
  #(
    parameter INDW=16,
    parameter DATAW=32,
    parameter TAGW=6,
    parameter DEPTH= 2 ** INDW,
   )
   (
    input clk, rst_n, write, en, // r_w=0 read, =1 write
    input [DATAW-1:0] data_in, [TAGW-1:0] tag_in,
    output valid, dirty, stall, 
    output [DATAW-1:0] data_out, [TAGW-1:0] tag_out,
   );

    reg [DATAW-1:0] data [INDW-1:0];
    reg [TAGW-1:0] tags [INDW-1:0];
    reg [1:0] status [INDW-1:0];  // {valid, dirty}

    int i;

    logic [INDW-1:0] insert_index, found_index

    CacheCtrl cachectrl #() ();

    assign valid = status[found_index][0];
    assign dirty = status[found_index][1];
    assign data_out = data[found_index];
    assign tag_out = tags[found_index];

    always_ff @(posedge clk, negedge rst_n) begin
        found_index = 0;

        if (~rst_n) begin
            insert_index = 0;
            for(i = 0; i < DEPTH; i++) begin
                data[i] = 0;
                tags[i] = 0;
                status[i] = 0;
            end
        end else if (en) begin
            for (i = 0; i < DEPTH; i++) begin
                if (tags[i] == tag_in) found_index = i;
            end

            if (write) begin


                insert_index = insert_index + 1;
            end else begin

            end
        end

    end


endmodule