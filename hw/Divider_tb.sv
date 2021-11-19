module Divider_tb;

reg clk;
reg rst;
reg en;
reg [15:0] numer, denom, exp_out;
wire out, done;
wire [15:0] quotient, remainder;

Divider #(
    .SIZE(16)
) d (
    .clk(clk),
    .rst(rst),
    .en(en),
    .numer(numer),
    .denom(denom),
    .quotient(quotient),
    .remainder(remainder),
    .done(done)
);

initial begin

    clk = 0;
    rst = 0;
    en = 1;
    numer = 0;
    denom = 1;

    @(posedge clk) rst = 1;
    @(negedge clk) rst = 0;

    for(int i = 1; i < 256; i++) begin
        
        for(int j = 1; j < 256; j++) begin
        
            numer = {i[7:0], 8'b0};
            denom = {j[7:0], 8'b0};

            $display("i: %b, j: %b", i, j);

            //@(negedge clk) en = 1;
            //@(posedge clk) en = 0;

            @(posedge done);
            //@(posedge clk);
            //@(negedge clk) rst = 1; 
            //@(posedge clk) rst = 0;


        end

    end

    $stop();

end

always #5 clk = ~clk;


endmodule