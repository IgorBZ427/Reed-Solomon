//RS top wrapper
//Used for verification


module rs_top #(parameter SYMB_WIDTH = 8,
                    parameter T = 2
                    )
(
    input clk,
    input rst_n,
    input sof,
    input [47:0] data_in,
    input input_valid,
    output wire error_valid,
    output wire no_error_found,
    output reg [SYMB_WIDTH-1:0] err1_mag,err2_mag,
    output reg [SYMB_WIDTH-1:0] err1_loc,err2_loc,
    output wire decoder_output_valid
);



// Simple FSM states
typedef enum logic [1:0] {
    COLLECT_DATA = 2'b00,    // Collecting data, feeding encoder
    WAIT_PARITY  = 2'b01,    // Waiting for parity symbols
    FEED_DECODER = 2'b10     // Feeding data+parity to decoder
} state_t;

state_t state;

// Data collection
reg [31:0] frame_data [0:196];  // 193 data + 4 parity = 197 total
reg [7:0] data_count;
reg [7:0] parity_count;
reg [7:0] decoder_count;

// Parity collection
wire [SYMB_WIDTH*4-1:0] parity_out;
reg parity_ready;

// Decoder interface
reg dec_sof_out;
reg dec_valid_out;
reg [31:0] dec_data_out;

//rs encoder
RS_encoder rs_enc (
    clk(clk),
    rst_n(rst_n),
    sof(sof),  // start of frame indicator
    m_high(data_in[31:0]), // 4 byte symbols input
    m_low(data_in[47:32]), // 2 byte symbols input, valid only when sof is high
    input_valid(input_valid), // input valid signal
    parity_out(parity_out) 
);



//=============================================================================
// RS Encoder
//=============================================================================
RS_encoder rs_enc (
    .clk(clk),
    .rst_n(rst_n),
    .sof(sof),
    .m_high(data_in[31:0]),
    .m_low(data_in[47:32]),
    .input_valid(input_valid),
    .parity_out(parity_out)
);

//=============================================================================
// Simple FSM
//=============================================================================
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        state <= COLLECT_DATA;
        data_count <= 0;
        parity_count <= 0;
        decoder_count <= 0;
        parity_ready <= 0;
        dec_sof_out <= 0;
        dec_valid_out <= 0;
    end else begin
        case (state)
            COLLECT_DATA: begin
                // Store incoming data and pass to encoder
                if (input_valid) begin
                    if (sof) begin
                        // First cycle: store both high and low data
                        frame_data[0] <= data_in[31:0];
                        frame_data[1] <= {16'h0, data_in[47:32]};
                        data_count <= 2;
                    end else if (data_count < 193) begin
                        // Store 4 bytes per cycle
                        frame_data[data_count] <= data_in[31:0];
                        data_count <= data_count + 1;
                    end
                end
                
                // Move to wait parity when data collection is done
                if (data_count >= 193) begin
                    state <= WAIT_PARITY;
                    parity_count <= 0;
                end
            end
            
            WAIT_PARITY: begin
                // Collect 4 parity symbols (assuming they come out sequentially)
                if (parity_count < 4) begin
                    // Extract parity bytes from parity_out
                    case (parity_count)
                        0: frame_data[193] <= {24'h0, parity_out[7:0]};
                        1: frame_data[194] <= {24'h0, parity_out[15:8]};
                        2: frame_data[195] <= {24'h0, parity_out[23:16]};
                        3: frame_data[196] <= {24'h0, parity_out[31:24]};
                    endcase
                    parity_count <= parity_count + 1;
                end else begin
                    parity_ready <= 1;
                    state <= FEED_DECODER;
                    decoder_count <= 0;
                end
            end
            
            FEED_DECODER: begin
                // Feed complete frame (data + parity) to decoder
                if (decoder_count < 197) begin
                    dec_valid_out <= 1;
                    dec_sof_out <= (decoder_count == 0);
                    
                    // Apply error injection if requested
                    if (inject_error && decoder_count == error_pos) begin
                        dec_data_out <= frame_data[decoder_count] ^ {24'h0, error_val};
                    end else begin
                        dec_data_out <= frame_data[decoder_count];
                    end
                    
                    decoder_count <= decoder_count + 1;
                end else begin
                    // Frame complete, wait for next SOF
                    dec_valid_out <= 0;
                    dec_sof_out <= 0;
                    if (sof && input_valid) begin
                        state <= COLLECT_DATA;
                        data_count <= 0;
                        parity_ready <= 0;
                    end
                end
            end
        endcase
    end
end

//rs decoder
RS_decoder rs_dec (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(dec_data_out),
    .input_valid(dec_valid_out),
    .dec_align_in(dec_align_in),
    .dec_sof_in(dec_sof_out),
    .dec_error_valid(error_valid),
    .dec_output_valid(decoder_output_valid),
    .dec_no_error_found(no_error_found),
    .err1_mag(err1_mag),
    .err2_mag(err2_mag),
    .err1_loc(err1_loc),
    .err2_loc(err2_loc)
);



endmodule