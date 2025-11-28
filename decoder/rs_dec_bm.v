
// RiBM(Reformulated inversionless Berlekamp-Massey) algorithm implementation in verilog, receives syndrome and outputs omega and sigma 
//TODO: 
//loops runs 5 times,gamma and k are vars
//1.handle k when its negative
//2.compile and test

//compile command: iverilog -o waves rs_dec_bm_tb.v ../rs_gf/gf_poly_scale.v ../rs_gf/gf_poly_add.v ../rs_gf/gf_mult_no_lut.v ../rs_gf/gf_add.v rs_dec_bm.v
module rs_dec_bm #(
    parameter SYMB_WIDTH = 8 ,  
    parameter T = 2 
)
(
    input [SYMB_WIDTH*4-1:0] syndrome, //len 4
    output bm_error,
    output [SYMB_WIDTH*2-1:0] omega, //len 2
    output [SYMB_WIDTH*3-1:0] sigma //len 3 

);


// Reverse syndrome for matching Python algorithm
    wire [SYMB_WIDTH-1:0] syndrome_reversed [0:2*T-1];
    genvar r;
    generate
        for (r = 0; r < 2*T; r = r + 1) begin: reverse_syndrome
            assign syndrome_reversed[r] = syndrome[SYMB_WIDTH*(2*T-r)-1:SYMB_WIDTH*(2*T-r-1)];
        end
    endgenerate

    // Constants and arrays for all iterations
    // We need 2*T+1 stages (0 to 2*T) for each value
    wire [SYMB_WIDTH-1:0] delta [0:2*T][0:3*T+1];
    wire [SYMB_WIDTH-1:0] theta [0:2*T][0:3*T];
    wire [SYMB_WIDTH-1:0] gamma [0:2*T];
    wire signed [SYMB_WIDTH:0] k [0:2*T];
    
    // Polynomial wires for each iteration
    wire [SYMB_WIDTH*(3*T+2)-1:0] delta_shifted [0:2*T-1];
    wire [SYMB_WIDTH*(3*T+1)-1:0] theta_poly [0:2*T-1];
    wire [SYMB_WIDTH*(3*T+2)-1:0] term1 [0:2*T-1]; 
    wire [SYMB_WIDTH*(3*T+1)-1:0] term2 [0:2*T-1];
    wire [SYMB_WIDTH*(3*T+1)-1:0] new_delta [0:2*T-1];
    
    // Condition signals for each iteration
    wire condition [0:2*T-1];
    
    // Initialize iteration 0
    genvar i, j;
    generate
        // Set first 2*T positions to reversed syndrome
        for (i = 0; i < 2*T; i = i + 1) begin: init_syndrome
            assign delta[0][i] = syndrome_reversed[i];
            assign theta[0][i] = syndrome_reversed[i];
        end
        
        // Set middle positions to zero
        for (i = 2*T; i < 3*T; i = i + 1) begin: init_zeros
            assign delta[0][i] = {SYMB_WIDTH{1'b0}};
            assign theta[0][i] = {SYMB_WIDTH{1'b0}};
        end
        
        // Set last positions
        assign delta[0][3*T] = {{(SYMB_WIDTH-1){1'b0}}, 1'b1};  // 1
        assign delta[0][3*T+1] = {SYMB_WIDTH{1'b0}};            // 0
        assign theta[0][3*T] = {{(SYMB_WIDTH-1){1'b0}}, 1'b1};  // 1
        
        // Initialize gamma and k
        assign gamma[0] = {{(SYMB_WIDTH-1){1'b0}}, 1'b1};  // 1
        assign k[0] = 0;
        
        // Main algorithm iterations
        for (i = 0; i < 2*T; i = i + 1) begin: iterations
            // Pack delta and theta for polynomial operations
            for (j = 0; j < 3*T+2; j = j + 1) begin: pack_delta_shifted
                if (j < 3*T+1) begin
                    assign delta_shifted[i][SYMB_WIDTH*(j+1)-1:SYMB_WIDTH*j] = 
                        (j+1 < 3*T+2) ? delta[i][j+1] : {SYMB_WIDTH{1'b0}};
                end
            end
            
            for (j = 0; j <= 3*T; j = j + 1) begin: pack_theta
                assign theta_poly[i][SYMB_WIDTH*(j+1)-1:SYMB_WIDTH*j] = theta[i][j];
            end
            
            // Step RiBM.1: Calculate the next delta
            // term1 = gamma * delta_0(1:3*t+1)
            gf_poly_scale #(.N(3*T+2)) scale_gamma_delta(
                .x(gamma[i]),
                .p(delta_shifted[i]),
                .result(term1[i])
            );
            
            // term2 = delta_0(0) * theta
            gf_poly_scale #(.N(3*T+1)) scale_delta0_theta(
                .x(delta[i][0]),
                .p(theta_poly[i]),
                .result(term2[i])
            );
            
            // new_delta = term1 - term2 (XOR in GF)
            gf_poly_add #(.N(3*T+1)) add_terms(
                .a(term1[i][SYMB_WIDTH*(3*T+1)-1:0]), // Only use first 3*T+1 elements
                .b(term2[i]),
                .result(new_delta[i])
            );
            
            // Update delta for next iteration
            for (j = 0; j <= 3*T; j = j + 1) begin: update_delta
                assign delta[i+1][j] = new_delta[i][SYMB_WIDTH*(j+1)-1:SYMB_WIDTH*j];
            end
            assign delta[i+1][3*T+1] = {SYMB_WIDTH{1'b0}};  // Last element is 0
            
            // Step RiBM.2: Conditional update
            assign condition[i] = (delta[i][0] != {SYMB_WIDTH{1'b0}}) && (k[i] >= 0);
            
            // Update theta based on condition
            for (j = 0; j <= 3*T; j = j + 1) begin: update_theta
                if (j < 3*T) begin
                    assign theta[i+1][j] = condition[i] ? delta[i][j+1] : theta[i][j];
                end else begin
                    assign theta[i+1][j] = condition[i] ? {SYMB_WIDTH{1'b0}} : theta[i][j];
                end
            end
            
            // Update gamma and k
            assign gamma[i+1] = condition[i] ? delta[i][0] : gamma[i];
            assign k[i+1] = condition[i] ? (-k[i] - 1) : (k[i] + 1);
        end
    endgenerate
    
    wire [SYMB_WIDTH-1:0] div_term;
    wire [SYMB_WIDTH-1:0] omega_terms[0:T-1];
    wire [SYMB_WIDTH-1:0] sigma_terms[0:T];
    //assign div_term = delta[2*T][T+1];
    assign div_term = |delta[2*T][3*T+1] ?  delta[2*T][3*T+1] : //7
                      |delta[2*T][3*T]   ?  delta[2*T][3*T]   :  //6
                      |delta[2*T][3*T-1] ?  delta[2*T][3*T-1]   :  //5
                      |delta[2*T][2*T] ?  delta[2*T][2*T]   :  //4
                      |delta[2*T][2*T-1] ?  delta[2*T][2*T-1]  : delta[2*T][2*T-1];  //3
    assign bm_error = |delta[2*T][5] | |delta[2*T][6] | |delta[2*T][7];
    wire [7:0] delta_4 = delta[2*T][4];
    wire [7:0] delta_5 = delta[2*T][5];
    wire [7:0] delta_6 = delta[2*T][6];
    wire [7:0] delta_7 = delta[2*T][7];
    /*
    generate
        for (i = 0; i < T; i = i + 1) begin: extract_omega
            gf_div div_omega(
                //.a(delta[2*T][T-1-i]), //0,1
                .a(delta[2*T][i]), 
                .b(div_term),
                .result(omega_terms[i])
            );
            assign omega[SYMB_WIDTH*(i+1)-1:SYMB_WIDTH*i] = omega_terms[i];
        end
        
        for (i = 0; i <= T; i = i + 1) begin: extract_sigma
        gf_div div_omega(
                .a(delta[2*T][T+i]), //2,3,4
                .b(div_term),
                .result(sigma_terms[i])
            );
            assign sigma[SYMB_WIDTH*(i+1)-1:SYMB_WIDTH*(i)] = sigma_terms[i];
        end
    endgenerate
    */


    gf_div div_omega0(
                //.a(delta[2*T][T-1-i]), //0,1
                .a(delta[2*T][0]), 
                .b(div_term),
                .result(omega_terms[0])
            );
    
    gf_div div_omega1(
                //.a(delta[2*T][T-1-i]), //0,1
                .a(delta[2*T][1]), 
                .b(div_term),
                .result(omega_terms[1])
            );

    gf_div div_sigma0(
                //.a(delta[2*T][T-1-i]), //0,1
                .a(delta[2*T][2]), 
                .b(div_term),
                .result(sigma_terms[0])
    );


    gf_div div_sigma1(
                //.a(delta[2*T][T-1-i]), //0,1
                .a(delta[2*T][3]), 
                .b(div_term),
                .result(sigma_terms[1])
    );

    gf_div div_sigma2(
                //.a(delta[2*T][T-1-i]), //0,1
                .a(delta[2*T][4]), 
                .b(div_term),
                .result(sigma_terms[2])
    );

    

    assign omega = |sigma_terms[2] ? {omega_terms[0],omega_terms[1]} : {omega_terms[1],omega_terms[0]};
    assign sigma = |sigma_terms[2] ? {sigma_terms[0],sigma_terms[1],sigma_terms[2]} : {sigma_terms[2],sigma_terms[0],sigma_terms[1]};
endmodule
