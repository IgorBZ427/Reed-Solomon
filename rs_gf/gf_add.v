
//galois field addition using xor
module gf_add
(
    input [7:0] a,
    input [7:0] b,
    output [7:0] sum
);

    assign sum = a ^ b;

endmodule