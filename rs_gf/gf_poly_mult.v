//galois feild multiplication  of 2 polynomials
//p,q are both polynomials of degree 4,each corefiect is 8 bits
//order of coefficients is from leaset coefficient to highest i.e. MSB [p3,p2,p1,p0] LSB
// Galois field multiplication of 2 polynomials
// p, q are both polynomials of degree 3 (i.e. 4 coefficients of 8 bits each)
// Coefficients are ordered from least to most significant: [p3, p2, p1, p0]
module gf_poly_mult (
    input [31:0] p,  // 4 bytes: p0, p1, p2, p3
    input [31:0] q,  // 4 bytes: q0, q1, q2, q3
    output [55:0] result  // 7 coefficients: degree 0 to 6
);

wire [7:0] p0 = p[7:0];
wire [7:0] p1 = p[15:8];
wire [7:0] p2 = p[23:16];
wire [7:0] p3 = p[31:24];

wire [7:0] q0 = q[7:0];
wire [7:0] q1 = q[15:8];
wire [7:0] q2 = q[23:16];
wire [7:0] q3 = q[31:24];

wire [7:0] r0_0;
wire [7:0] r1_0, r1_1;
wire [7:0] r2_0, r2_1, r2_2;
wire [7:0] r3_0, r3_1, r3_2, r3_3;
wire [7:0] r4_0, r4_1, r4_2;
wire [7:0] r5_0, r5_1;
wire [7:0] r6_0;

// Degree 0 term
gf_mult_no_lut m0(.a(p0), .b(q0), .result(r0_0));

// Degree 1 terms
gf_mult_no_lut m1_0(.a(p0), .b(q1), .result(r1_0));
gf_mult_no_lut m1_1(.a(p1), .b(q0), .result(r1_1));

// Degree 2 terms
gf_mult_no_lut m2_0(.a(p0), .b(q2), .result(r2_0));
gf_mult_no_lut m2_1(.a(p1), .b(q1), .result(r2_1));
gf_mult_no_lut m2_2(.a(p2), .b(q0), .result(r2_2));

// Degree 3 terms
gf_mult_no_lut m3_0(.a(p0), .b(q3), .result(r3_0));
gf_mult_no_lut m3_1(.a(p1), .b(q2), .result(r3_1));
gf_mult_no_lut m3_2(.a(p2), .b(q1), .result(r3_2));
gf_mult_no_lut m3_3(.a(p3), .b(q0), .result(r3_3));

// Degree 4 terms
gf_mult_no_lut m4_0(.a(p1), .b(q3), .result(r4_0));
gf_mult_no_lut m4_1(.a(p2), .b(q2), .result(r4_1));
gf_mult_no_lut m4_2(.a(p3), .b(q1), .result(r4_2));

// Degree 5 terms
gf_mult_no_lut m5_0(.a(p2), .b(q3), .result(r5_0));
gf_mult_no_lut m5_1(.a(p3), .b(q2), .result(r5_1));

// Degree 6 term
gf_mult_no_lut m6(.a(p3), .b(q3), .result(r6_0));

// Assign result terms
assign result[7:0]   = r0_0;
assign result[15:8]  = r1_0 ^ r1_1;
assign result[23:16] = r2_0 ^ r2_1 ^ r2_2;
assign result[31:24] = r3_0 ^ r3_1 ^ r3_2 ^ r3_3;
assign result[39:32] = r4_0 ^ r4_1 ^ r4_2;
assign result[47:40] = r5_0 ^ r5_1;
assign result[55:48] = r6_0;

endmodule
