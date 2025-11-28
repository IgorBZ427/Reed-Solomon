// Description: Parametrized Polynomial evaluation in GF(2^8) using Horner's method
module gf_poly_eval_N #(
    parameter N = 5  // Number of coefficients (e.g., 5 for degree-4 poly)
)(
    input  wire [8*N-1:0] poly,  // Packed: {a[N-1], ..., a[0]}
    input  wire [7:0] x,
    output wire [7:0] result
);

    wire [7:0] coeffs [0:N-1];
    wire [7:0] stage  [0:N-1];

    // Unpack the coefficients from the input bus
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : unpack
            assign coeffs[i] = poly[8*(N-1-i) +: 8];
        end
    endgenerate

    // Evaluate using Horner's method
    // stage[0] = coeffs[0]; stage[i+1] = gf_mult(stage[i], x) ^ coeffs[i+1]
    assign stage[0] = coeffs[0];

    generate
        for (i = 1; i < N; i = i + 1) begin : eval
            wire [7:0] mult_result;
            gf_mult_no_lut mult_inst (
                .a(stage[i-1]),
                .b(x),
                .result(mult_result)
            );
            assign stage[i] = mult_result ^ coeffs[i];
        end
    endgenerate

    assign result = stage[N-1];

endmodule
