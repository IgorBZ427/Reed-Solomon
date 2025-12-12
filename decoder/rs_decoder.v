//RS decoder top
//GF(256), generator polynomial: x^8 + x^4 + x^3 + x^2 + 1,primitive polynomial: x^8 + x^4 + x^3 + x^2 + 1
//RS(197,194),each RS frame is 49.5 clocks, each clock has 32bits(4 byte symbols) input, can correct up to 2 bytes(symbols) error
//made of 3 stages: syndrome calculation, error locator, error evaluator

module RS_decoder #(parameter SYMB_WIDTH = 8,
                    parameter T = 2
                    )
(
    input clk,
    input rst_n,
    input [SYMB_WIDTH*4-1:0] data_in, // 4 byte symbols input
    input input_valid, // input valid signal
    input dec_align_in, // align input, used to toggle between frames
    input dec_sof_in, // start of frame indicator
    output reg dec_error_valid, // decoder fails to decode the last frame
    output reg dec_output_valid, //decoder output for last frame 
    output reg dec_no_error_found, // no error found in the last frame
    output reg [SYMB_WIDTH-1:0] err1_mag, // error1 magnitude
    output reg [SYMB_WIDTH-1:0] err2_mag, // error2 magnitude
    output reg [SYMB_WIDTH-1:0] err1_loc, // error1 location
    output reg [SYMB_WIDTH-1:0] err2_loc  // error2 location
);


//Syndrome calculation


wire part_sof,full_sof;
reg partial_sof_d;
wire [SYMB_WIDTH*2-1:0] omega;
wire [SYMB_WIDTH*3-1:0] sigma;
wire [SYMB_WIDTH*4-1:0] syndrome;
wire [SYMB_WIDTH*3-1:0] X, X_inv;
wire [SYMB_WIDTH*3-1:0] err_mag,error_loc;
wire [SYMB_WIDTH-1:0] err_count;
reg [SYMB_WIDTH*3-1:0] sigma_d;
reg [SYMB_WIDTH*2-1:0] omega_d;    // FIXED: Should match omega width (2 coefficients)
reg [SYMB_WIDTH*3-1:0] X_d, X_inv_d;
reg sof_d,sof_2d,sof_3d;
reg error_count_err;
reg [SYMB_WIDTH-1:0] err_count_reg;
wire bm_error;


always @(posedge clk or negedge rst_n)
begin
    if(~rst_n) begin
        sigma_d <= {SYMB_WIDTH*3{1'b0}};
        omega_d <= {SYMB_WIDTH*2{1'b0}};    
        X_d <= {SYMB_WIDTH*3{1'b0}};
        X_inv_d <= {SYMB_WIDTH*3{1'b0}};
        
        sof_d <= 1'b0;
        sof_2d <= 1'b0;
        sof_3d <= 1'b0;
        dec_output_valid <= 1'b0;
        dec_no_error_found <= 1'b0;
        
        error_count_err <= 1'b0;
        dec_error_valid <= 1'b0;
    end
    else begin
        sof_d <= dec_sof_in;
        sof_2d <= sof_d;
        sof_3d <= sof_2d;
        dec_output_valid <= sof_3d & ~sof_2d & input_valid; // output
        sigma_d <= sigma;
        omega_d <= omega;
        X_d <= X;
        X_inv_d <= X_inv;
        

        if(dec_sof_in && ~(|syndrome)) dec_no_error_found <= 1'b1;
        else if(dec_sof_in) dec_no_error_found <= 1'b0;

        error_count_err <= (dec_sof_in & (|syndrome) & ((err_count_reg > T) | ( err_count_reg == 0)));


        dec_error_valid <= error_count_err | bm_error;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n) begin
        err_count_reg <= {SYMB_WIDTH{1'b0}};
        err2_loc <= {SYMB_WIDTH{1'b0}};
        err1_loc <= {SYMB_WIDTH{1'b0}};
        err2_mag <= {SYMB_WIDTH{1'b0}};
        err1_mag <= {SYMB_WIDTH{1'b0}};
    end
    else if(dec_output_valid) begin
        err2_loc <= error_loc[SYMB_WIDTH*2-1:SYMB_WIDTH];
        err1_loc <= error_loc[SYMB_WIDTH-1:0];
        err2_mag <= err_mag[SYMB_WIDTH*2-1:SYMB_WIDTH];
        err1_mag <= err_mag[SYMB_WIDTH-1:0];
        err_count_reg <= err_count; 
        
    end
end

//syndrome calculation
rs_dec_syndrome #(
        .SYMB_WIDTH(SYMB_WIDTH)
) dec_syndrome (
        .clk(clk),
        .rst_n(rst_n),
        .dec_sof_in(dec_sof_in),
        .input_valid(input_valid),
        .dec_align_in(dec_align_in),
        .data_in(data_in),
        .syndrome_out(syndrome)
    );


//BM
rs_dec_bm #(
    .SYMB_WIDTH(SYMB_WIDTH),
    .T(T)
) bm (
    .syndrome(syndrome),
    .bm_error(bm_error),
    .omega(omega),
    .sigma(sigma)
);


//chien
rs_dec_chien #(
    .SYMB_WIDTH(SYMB_WIDTH),
    .T(T)
) chien (
    .sigma(sigma_d),
    .err_count(err_count),
    .error_loc(error_loc),
    .X(X),
    .X_inv(X_inv)
);

//forney
rs_dec_forney #(
    .SYMB_WIDTH(SYMB_WIDTH),
    .T(T)
) forney (

    .X_inv(X_inv_d),
    .X(X_d),
    .omega(omega_d),
    .err_mag(err_mag)
);

endmodule