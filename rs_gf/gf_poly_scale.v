module gf_poly_scale #(
    parameter N = 4  // Number of coefficients in the polynomial
)(
    input  [8*N-1:0] p,    // Input polynomial coefficients: [pN-1, ..., p0]
    input  [7:0]     x,    // Scalar multiplier in GF(2^8)
    output [8*N-1:0] result // Output: scaled polynomial
);

genvar i;
generate
    for (i = 0; i < N; i = i + 1) begin : scale_loop
        wire [7:0] coef_in = p[8*i +: 8];
        wire [7:0] coef_out;

        gf_mult_no_lut mult_inst (
            .a(coef_in),
            .b(x),
            .result(coef_out)
        );

        assign result[8*i +: 8] = coef_out;
    end
endgenerate

endmodule
