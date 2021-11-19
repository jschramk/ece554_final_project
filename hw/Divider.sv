module Divider #(
    parameter SIZE = 16
) (
    input clk,
    input rst,
    input en,
    input [SIZE-1:0] numer,
    input [SIZE-1:0] denom,
    output [SIZE-1:0] quotient,
    output [SIZE-1:0] remainder,
    output done
);

wire active;
reg [$clog2(SIZE)-1:0] remaining_cycles;
reg [SIZE-1:0] result_reg;
reg [SIZE-1:0] denom_reg;
reg [SIZE-1:0] current;

wire [SIZE-1:0] 
    abs_numer = numer[SIZE-1] ? -numer : numer,
    abs_denom = denom[SIZE-1] ? -denom : denom;

wire output_negative = numer[SIZE-1] ^ denom[SIZE-1];

// Calculate the current digit
wire [SIZE:0] sub = { current[SIZE-2:0], result_reg[SIZE-1] } - denom_reg;

assign quotient = output_negative ? -result_reg : result_reg;
assign remainder = current;
assign active = |remaining_cycles;
assign done = ~active;


always @(posedge clk, posedge rst) begin

    if (rst) begin

        remaining_cycles <= 0;
        result_reg <= 0;
        denom_reg <= 0;
        current <= 0;

    end else if (active) begin // if currently running, keep running until done

        if (~sub[SIZE]) begin

            current <= sub[SIZE-1:0];
            result_reg <= { result_reg[SIZE-2:0], 1'b1 };

        end else begin

            current <= { current[SIZE-2:0], result_reg[SIZE-1] };
            result_reg <= { result_reg[SIZE-2:0], 1'b0 };

        end

        remaining_cycles <= remaining_cycles - 1;

    end else if (en) begin // if not running and enable is high, start a new operation

        // Set up for an unsigned divide
        remaining_cycles <= { ($clog2(SIZE)){1'b1} };
        result_reg <= abs_numer;
        denom_reg <= abs_denom;
        current <= 0;

    end

end

endmodule  