module SignedDivider #(
    parameter SIGNED = 1,
    parameter SIZE = 16
) (
    input clk, start,
    input [SIZE-1:0] numer, denom,
    output reg [SIZE-1:0] quotient, remainder,
    output ready
);

reg [SIZE-1:0] quotient_temp;
reg [2*SIZE-1:0] dividend_copy, divider_copy, diff;
reg negative_output;

assign remainder = (!negative_output) ? dividend_copy[31:0] : ~dividend_copy[31:0] + 1'b1;

reg [$clog2(SIZE):0] count;
assign ready = !count;

initial count = 0;
initial negative_output = 0;

always @( posedge clk ) begin

    if( ready && start ) begin

        count = { 1'b1, {(SIZE){1'b0}} };
        quotient = 0;
        quotient_temp = 0;
        dividend_copy = (!SIGNED || !numer[SIZE-1]) ? {{(SIZE){1'b0}}, numer} : {{(SIZE){1'b0}}, ~numer + 1'b1};
        divider_copy = (!SIGNED || !denom[SIZE-1]) ? {1'b0, denom, {(SIZE-1){1'b0}}} : {1'b0, ~denom + 1'b1, {(SIZE-1){1'b0}}};

        negative_output = SIGNED && ((denom[SIZE-1] && !numer[SIZE-1]) || (!denom[SIZE-1] && numer[SIZE-1]));
    
    end else if ( count > 0 ) begin

        diff = dividend_copy - divider_copy;

        quotient_temp = quotient_temp << 1;

        if( !diff[2*SIZE-1] ) begin

            dividend_copy = diff;
            quotient_temp[0] = 1'b1;

        end

        quotient = (!negative_output) ? quotient_temp : ~quotient_temp + 1'b1;

        divider_copy = divider_copy >> 1;
        count = count - 1'b1;

    end

end

endmodule