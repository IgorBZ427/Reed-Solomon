
module rs_dec_syndrome #(
    parameter SYMB_WIDTH = 8
    
)
(
    input clk,
    input rst_n,
    input dec_sof_in,  // start of frame indicator
    input input_valid, // input valid signal
    input dec_align_in, // align input, used to toggle between frames
    input [SYMB_WIDTH*4-1:0] data_in,
    output reg [SYMB_WIDTH*4-1:0] syndrome_out
);

reg [SYMB_WIDTH-1:0] syndrome0,syndrome1,syndrome2,syndrome3;
wire [SYMB_WIDTH-1:0] synd0_out,synd1_out,synd2_out,synd3_out;
wire [SYMB_WIDTH-1:0] synd00_out, synd01_out, synd02_out, synd03_out;
wire [SYMB_WIDTH-1:0] synd10_out, synd11_out, synd12_out, synd13_out;
wire [SYMB_WIDTH-1:0] synd10_out_muxed, synd11_out_muxed, synd12_out_muxed, synd13_out_muxed;
wire [SYMB_WIDTH-1:0] synd20_out, synd21_out, synd22_out, synd23_out;

assign synd10_out_muxed = part_sof ? 8'b0 : synd10_out;
assign synd11_out_muxed = part_sof ? 8'b0 : synd11_out;
assign synd12_out_muxed = part_sof ? 8'b0 : synd12_out;
assign synd13_out_muxed = part_sof ? 8'b0 : synd13_out;
assign part_sof = dec_sof_in && ~dec_align_in && input_valid;

assign full_sof = dec_sof_in && dec_align_in && input_valid;

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n) syndrome_out<=32'b0;
    else if(full_sof) syndrome_out <=   {synd3_out,synd2_out,synd1_out,synd0_out} ;
    else if(part_sof) syndrome_out <=   {synd13_out, synd12_out, synd11_out, synd10_out};
    
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n) begin
        syndrome0 <= 8'd0;
        syndrome1 <= 8'd0;
        syndrome2 <= 8'd0;
        syndrome3 <= 8'd0;
    end
    else if(full_sof)
    begin
        syndrome0 <= 8'b0;
        syndrome1 <= 8'b0;
        syndrome2 <= 8'b0;
        syndrome3 <= 8'b0;
    end
    else if(input_valid)
    begin
        syndrome0 <= synd0_out;
        syndrome1 <= synd1_out;
        syndrome2 <= synd2_out;
        syndrome3 <= synd3_out;

    end

end

//data_in[7:0]

rs_dec_synd_cell  #(
    .SYMB_WIDTH(SYMB_WIDTH)
    ) 
syndrome_00 
(
    .data_in(data_in[7:0]),
    .multiplier(8'd1),
    .syndrome_in(syndrome0),
    .syndrome_out(synd00_out)
);

rs_dec_synd_cell  #(
    .SYMB_WIDTH(SYMB_WIDTH)
) syndrome_01
(
    .data_in(data_in[7:0]),
    .multiplier(8'd2),
    .syndrome_in(syndrome1),
    .syndrome_out(synd01_out)
);


rs_dec_synd_cell  #(
    .SYMB_WIDTH(SYMB_WIDTH)
) syndrome_02
(
    .data_in(data_in[7:0]),
    .multiplier(8'd4),
    .syndrome_in(syndrome2),
    .syndrome_out(synd02_out)
);



rs_dec_synd_cell  #(
    .SYMB_WIDTH(SYMB_WIDTH)
) syndrome_03
(
    .data_in(data_in[7:0]),
    .multiplier(8'd8),
    .syndrome_in(syndrome3),
    .syndrome_out(synd03_out)

);

//data_in[15:8]

rs_dec_synd_cell  #(
    .SYMB_WIDTH(SYMB_WIDTH)
    ) 
syndrome_10 
(
    .data_in(data_in[15:8]),
    .multiplier(8'd1),
    .syndrome_in(synd00_out),
    .syndrome_out(synd10_out)
);

rs_dec_synd_cell  #(
    .SYMB_WIDTH(SYMB_WIDTH)
) syndrome_11
(
    .data_in(data_in[15:8]),
    .multiplier(8'd2),
    .syndrome_in(synd01_out),
    .syndrome_out(synd11_out)
);


rs_dec_synd_cell  #(
    .SYMB_WIDTH(SYMB_WIDTH)
) syndrome_12
(
    .data_in(data_in[15:8]),
    .multiplier(8'd4),
    .syndrome_in(synd02_out),
    .syndrome_out(synd12_out)
);



rs_dec_synd_cell  #(
    .SYMB_WIDTH(SYMB_WIDTH)
) syndrome_13
(
    .data_in(data_in[15:8]),
    .multiplier(8'd8),
    .syndrome_in(synd03_out),
    .syndrome_out(synd13_out)

);



//data_in[23:16]


rs_dec_synd_cell  #(
    .SYMB_WIDTH(SYMB_WIDTH)
    ) 
syndrome_20 
(
    .data_in(data_in[23:16]),
    .multiplier(8'd1),
    .syndrome_in(synd10_out_muxed),
    .syndrome_out(synd20_out)
);

rs_dec_synd_cell  #(
    .SYMB_WIDTH(SYMB_WIDTH)
) syndrome_21
(
    .data_in(data_in[23:16]),
    .multiplier(8'd2),
    .syndrome_in(synd11_out_muxed),
    .syndrome_out(synd21_out)
);


rs_dec_synd_cell  #(
    .SYMB_WIDTH(SYMB_WIDTH)
) syndrome_22
(
    .data_in(data_in[23:16]),
    .multiplier(8'd4),
    .syndrome_in(synd12_out_muxed),
    .syndrome_out(synd22_out)
);



rs_dec_synd_cell  #(
    .SYMB_WIDTH(SYMB_WIDTH)
) syndrome_23
(
    .data_in(data_in[23:16]),
    .multiplier(8'd8),
    .syndrome_in(synd13_out_muxed),
    .syndrome_out(synd23_out)

);



//data_in[31:24]


rs_dec_synd_cell  #(
    .SYMB_WIDTH(SYMB_WIDTH)
    ) 
syndrome_30 
(
    .data_in(data_in[31:24]),
    .multiplier(8'd1),
    .syndrome_in(synd20_out),
    .syndrome_out(synd0_out)
);

rs_dec_synd_cell  #(
    .SYMB_WIDTH(SYMB_WIDTH)
) syndrome_31
(
    .data_in(data_in[31:24]),
    .multiplier(8'd2),
    .syndrome_in(synd21_out),
    .syndrome_out(synd1_out)
);


rs_dec_synd_cell  #(
    .SYMB_WIDTH(SYMB_WIDTH)
) syndrome_32
(
    .data_in(data_in[31:24]),
    .multiplier(8'd4),
    .syndrome_in(synd22_out),
    .syndrome_out(synd2_out)
);



rs_dec_synd_cell  #(
    .SYMB_WIDTH(SYMB_WIDTH)
) syndrome_33
(
    .data_in(data_in[31:24]),
    .multiplier(8'd8),
    .syndrome_in(synd23_out),
    .syndrome_out(synd3_out)

);


endmodule