module gf_poly_add #(
    parameter N = 4  // Number of coefficients in the polynomial
)(
    input  [8*N-1:0] a,    // Polynomial A: [aN-1, ..., a0]
    input  [8*N-1:0] b,    // Polynomial B: [bN-1, ..., b0]
    output [8*N-1:0] result // Output: A + B
);

genvar i;
generate
    for (i = 0; i < N; i = i + 1) begin : add_loop
        assign result[8*i +: 8] = a[8*i +: 8] ^ b[8*i +: 8];
    end
endgenerate

endmodule
