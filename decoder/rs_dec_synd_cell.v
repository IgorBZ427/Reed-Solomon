module rs_dec_synd_cell #(
    parameter SYMB_WIDTH = 8
    
)
(
    input [SYMB_WIDTH-1:0] data_in,
    input [SYMB_WIDTH-1:0] multiplier,
    input [SYMB_WIDTH-1:0] syndrome_in,
    output [SYMB_WIDTH-1:0] syndrome_out
);

wire [SYMB_WIDTH-1:0] mult_result;



gf_mult_no_lut mult0
(
    .a(syndrome_in),
    .b(multiplier),
    .result(mult_result)
);

gf_add add0
(
    .a(data_in),
    .b(mult_result),
    .sum(syndrome_out)
);

endmodule
