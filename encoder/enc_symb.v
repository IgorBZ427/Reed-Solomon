module enc_symb #(parameter SYMB_WIDTH = 8)
(
    input [SYMB_WIDTH-1:0] data_symbol,
    input [SYMB_WIDTH-1:0] parity0_in,
    input [SYMB_WIDTH-1:0] parity1_in,
    input [SYMB_WIDTH-1:0] parity2_in,
    input [SYMB_WIDTH-1:0] parity3_in,
    output [SYMB_WIDTH-1:0] parity0_out,
    output [SYMB_WIDTH-1:0] parity1_out,
    output [SYMB_WIDTH-1:0] parity2_out,
    output [SYMB_WIDTH-1:0] parity3_out
);


wire [SYMB_WIDTH-1:0] feedback;
wire [SYMB_WIDTH-1:0] res3,res2,res1;
//first round of division
gf_add add0_0
(
    .a(data_symbol), // first byte of m_high
    .b(parity3_in), // parity3 reg value from previus round
    .sum(feedback)
);


gf_add add0_1
(
    .a(res3),
    .b(parity2_in),
    .sum(parity3_out)
);


gf_mult_no_lut mult0_1
(
    .a(feedback),
    .b(8'd15),
    .result(res3)
);


gf_add add0_2
(
    .a(res2),
    .b(parity1_in),
    .sum(parity2_out)
);


gf_mult_no_lut mult0_2
(
    .a(feedback),
    .b(8'd54),
    .result(res2)
);


gf_add add0_3
(
    .a(res1),
    .b(parity0_in),
    .sum(parity1_out)
);


gf_mult_no_lut mult0_3
(
    .a(feedback),
    .b(8'd120),
    .result(res1)
);


gf_mult_no_lut mult0_4
(
    .a(feedback),
    .b(8'd64),
    .result(parity0_out)
);

endmodule