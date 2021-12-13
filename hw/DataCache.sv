module DataCache
  #(
    parameter DATAW=16,
    parameter INW=512,
    parameter ADDRW=32,
    parameter NUMINSTRUCTIONS=INW/DATAW
   )
   (
    input clk, rst_n, write,
    input [INW-1:0] data_in,
    input [ADDRW-1:0] addr_in,
    output logic valid_out,
    output logic [INW-1:0] data_out
   );

    reg [ADDRW-1:0] addr;
    reg valid;

    integer index;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            data_out = 0;
            addr = 0;
            valid = 0;
            valid_out = 0;
        end else begin
            if (write) begin
                data_out = data_in;
                addr = addr_in;
                valid = 1;
            end

            if (addr_in !== addr) begin
                valid_out = 0;
            end else begin
                valid_out = valid;
            end
        end
    end
endmodule
