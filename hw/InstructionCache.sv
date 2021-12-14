module InstructionCache
  #(
    parameter DATAW=16,
    parameter INW=512,
    parameter ADDRW=32,
    parameter NUMINSTRUCTIONS=INW/DATAW
   )
   (
    input clk, rst_n, write, stall,
    input [INW-1:0] data_in,
    input [ADDRW-1:0] addr_in, base_addr_in,
    output logic valid_out,
    output logic [DATAW-1:0] data_out
   );

    reg [INW-1:0] data;
    reg [ADDRW-1:0] base_addr;
    reg valid;

    integer index;
    assign index = (addr_in - base_addr) >> 1;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            data = 0;
            base_addr = 0;
            valid = 0;
            valid_out = 0;
        end else begin
            if (write) begin
                data = data_in;
                base_addr = base_addr_in;
                valid = 1;
            end

            if (index >= NUMINSTRUCTIONS || index < 0) begin
                valid_out = 0;
            end else begin
                if (!stall || (stall && !valid_out)) begin
                    valid_out = valid;
                    data_out = data[(INW-1) - (index * DATAW) -: DATAW];
                end
            end
        end
    end

endmodule
   /*

    reg [DATAW-1:0] data [INDW-1:0];
    reg [TAGW-1:0] tags [INDW-1:0];
    reg [1:0] status [INDW-1:0];  // {valid, dirty}

    int i;

    logic [INDW-1:0] insert_index, found_index

    //CacheCtrl cachectrl #() ();

    assign valid = status[found_index][0];
    assign dirty = status[found_index][1];
    assign data_out = data[found_index];
    assign tag_out = tags[found_index];

    always_ff @(posedge clk, negedge rst_n) begin
        found_index = 0;
        stall = 0;
        mem_op = 0;

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
                if (tag_out !== tag_in || !valid) begin
                    stall = 1;
                    mem_op = 1;
                end
            end
        end

    end


endmodule
*/