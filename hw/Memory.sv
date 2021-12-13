module Memory 
#(
    DATAW=16,
    INW=512,
    ADDRW=32,
    NUMINSTRUCTIONS=INW/DATAW
 ) (
    input clk, rst_n, write,
    input [INW-1:0] data_in,
    input [ADDRW-1:0] addr_in,
    output valid_out,
    output [INW-1:0] data_out
 );

    DataCache cache (
        .clk(clk), .rst_n(rst_n), .write(write),
        .data_in(data_in),
        .addr_in(addr_in),
        .valid_out(valid_out),
        .data_out(data_out)
    );
endmodule