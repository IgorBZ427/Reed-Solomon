//RS encoder
//GF(256), generator polynomial: x^8 + x^4 + x^3 + x^2 + 1,primitive polynomial: x^8 + x^4 + x^3 + x^2 + 1
//RS(197,194),each RS frame is 48.5 clocks, each clock has 32bits(4 byte symbols) input
//parity is 4 byte symbols
module RS_encoder #(parameter SYMB_WIDTH = 8)
(
    input clk,
    input rst_n,
    input sof,  // start of frame indicator
    input [SYMB_WIDTH*4-1:0] m_high, // 4 byte symbols input
    input [SYMB_WIDTH*2-1:0] m_low, // 2 byte symbols input, valid only when sof is high
    input input_valid, // input valid signal
    output reg [SYMB_WIDTH*4-1:0] parity_out // 4 byte parity output,valid only when sof is high
);


reg [SYMB_WIDTH-1:0] parity0,parity1,parity2,parity3;
reg sof_d;


always @(posedge clk or negedge rst_n)
begin
    if(~rst_n) sof_d <= 1'd0;
    else sof_d <= sof;
end


always @(posedge clk or negedge rst_n)
begin
    if(~rst_n) parity_out <= {SYMB_WIDTH*4{1'b0}};
    else if(sof) parity_out <= {parity0_3,parity1_3,parity2_3,parity3_3};
end



always @(posedge clk or negedge rst_n)
begin
    if(~rst_n) begin
        parity0 <= {SYMB_WIDTH{1'b0}};
        parity1 <= {SYMB_WIDTH{1'b0}};
        parity2 <= {SYMB_WIDTH{1'b0}};
        parity3 <= {SYMB_WIDTH{1'b0}};
    end
    else if(sof) begin 
        parity3 <= {SYMB_WIDTH{1'b0}};
        parity2 <= {SYMB_WIDTH{1'b0}};
        parity1 <= {SYMB_WIDTH{1'b0}};
        parity0 <= {SYMB_WIDTH{1'b0}};
    end
    else if(input_valid) begin
        parity3 <= parity3_3;
        parity2 <= parity2_3;
        parity1 <= parity1_3;
        parity0 <= parity0_3;
    end
end

// Remove unused signal declarations
wire [SYMB_WIDTH-1:0] parity3_0,parity3_1,parity3_2,parity3_3;
wire [SYMB_WIDTH-1:0] parity2_0,parity2_1,parity2_2,parity2_3;
wire [SYMB_WIDTH-1:0] parity1_0,parity1_1,parity1_2,parity1_3;
wire [SYMB_WIDTH-1:0] parity0_0,parity0_1,parity0_2,parity0_3;

wire [SYMB_WIDTH-1:0] parity3_l0,parity3_l1;
wire [SYMB_WIDTH-1:0] parity2_l0,parity2_l1;
wire [SYMB_WIDTH-1:0] parity1_l0,parity1_l1;
wire [SYMB_WIDTH-1:0] parity0_l0,parity0_l1;

wire [SYMB_WIDTH-1:0] parity_h0_mux,parity_h1_mux,parity_h2_mux,parity_h3_mux;
assign parity_h0_mux = sof_d ? parity0_l1 :  parity0;
assign parity_h1_mux = sof_d ? parity1_l1 :  parity1;
assign parity_h2_mux = sof_d ? parity2_l1 :  parity2;
assign parity_h3_mux = sof_d ? parity3_l1 :  parity3;

enc_symb enc_symb_l0 
(
    .data_symbol(m_low[7:0]), // first byte of m_low
    .parity0_in(parity0), // parity register values from previous round
    .parity1_in(parity1),
    .parity2_in(parity2),
    .parity3_in(parity3),
    .parity0_out(parity0_l0),
    .parity1_out(parity1_l0),
    .parity2_out(parity2_l0),
    .parity3_out(parity3_l0)
);


enc_symb enc_symb_l1
(
    .data_symbol(m_low[15:8]), // second byte of m_low
    .parity0_in(parity0_l0), // parity values from previous symbol
    .parity1_in(parity1_l0),
    .parity2_in(parity2_l0),
    .parity3_in(parity3_l0),
    .parity0_out(parity0_l1),
    .parity1_out(parity1_l1),
    .parity2_out(parity2_l1),
    .parity3_out(parity3_l1)
);



enc_symb enc_symb_h0 
(
    .data_symbol(m_high[7:0]), // first byte of m_high
    .parity0_in(parity_h0_mux), // parity register values from mux logic
    .parity1_in(parity_h1_mux),
    .parity2_in(parity_h2_mux),
    .parity3_in(parity_h3_mux),
    .parity0_out(parity0_0),
    .parity1_out(parity1_0),
    .parity2_out(parity2_0),
    .parity3_out(parity3_0)
);

enc_symb enc_symb_h1
(
    .data_symbol(m_high[15:8]), // second byte of m_high
    .parity0_in(parity0_0), // parity values from previous symbol
    .parity1_in(parity1_0),
    .parity2_in(parity2_0),
    .parity3_in(parity3_0),
    .parity0_out(parity0_1),
    .parity1_out(parity1_1),
    .parity2_out(parity2_1),
    .parity3_out(parity3_1)
);


enc_symb enc_symb_h2
(
    .data_symbol(m_high[23:16]), // third byte of m_high
    .parity0_in(parity0_1), // parity values from previous symbol
    .parity1_in(parity1_1),
    .parity2_in(parity2_1),
    .parity3_in(parity3_1),
    .parity0_out(parity0_2),
    .parity1_out(parity1_2),
    .parity2_out(parity2_2),
    .parity3_out(parity3_2)
);

enc_symb enc_symb_h3
(
    .data_symbol(m_high[31:24]), // fourth byte of m_high
    .parity0_in(parity0_2), // parity values from previous symbol
    .parity1_in(parity1_2),
    .parity2_in(parity2_2),
    .parity3_in(parity3_2),
    .parity0_out(parity0_3),
    .parity1_out(parity1_3),
    .parity2_out(parity2_3),
    .parity3_out(parity3_3)
);


endmodule