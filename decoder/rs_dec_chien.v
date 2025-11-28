

module rs_dec_chien #(parameter SYMB_WIDTH = 8,
                    parameter POLY_WIDTH = 3,
                    parameter NSYMB = 198,
                    parameter T = 2
)    
(

    input [SYMB_WIDTH*3-1:0] sigma,
    output [SYMB_WIDTH*3-1:0] error_loc,
    output [SYMB_WIDTH-1:0] err_count, //number of errors found
    output [SYMB_WIDTH*3-1:0] X,
    output [SYMB_WIDTH*3-1:0] X_inv
  
);
integer j;
reg [2:0] zero_count;

reg [SYMB_WIDTH-1:0] error_location_temp[2:0];
wire [SYMB_WIDTH*3-1:0] reversed_sigma;

wire [SYMB_WIDTH-1:0] pow_value[NSYMB-1:0];
wire [SYMB_WIDTH-1:0] error_loc_vector[NSYMB-1:0];
wire [7:0] l0,l1,l2;
wire [7:0] pow_value_0,pow_value_1,pow_value_2,inv_pow_value_X0,inv_pow_value_X1,inv_pow_value_X2;

assign error_loc = {l2, l1, l0};
assign reversed_sigma = sigma;
assign err_count = zero_count;
genvar i;

assign pow_value[0] = 8'd1;
assign pow_value[1] = 8'd2;
assign pow_value[2] = 8'd4;
assign pow_value[3] = 8'd8;
assign pow_value[4] = 8'd16;
assign pow_value[5] = 8'd32;
assign pow_value[6] = 8'd64;
assign pow_value[7] = 8'd128;
assign pow_value[8] = 8'd29;
assign pow_value[9] = 8'd58;
assign pow_value[10] = 8'd116;
assign pow_value[11] = 8'd232;
assign pow_value[12] = 8'd205;
assign pow_value[13] = 8'd135;
assign pow_value[14] = 8'd19;
assign pow_value[15] = 8'd38;
assign pow_value[16] = 8'd76;
assign pow_value[17] = 8'd152;
assign pow_value[18] = 8'd45;
assign pow_value[19] = 8'd90;
assign pow_value[20] = 8'd180;
assign pow_value[21] = 8'd117;
assign pow_value[22] = 8'd234;
assign pow_value[23] = 8'd201;
assign pow_value[24] = 8'd143;
assign pow_value[25] = 8'd3;
assign pow_value[26] = 8'd6;
assign pow_value[27] = 8'd12;
assign pow_value[28] = 8'd24;
assign pow_value[29] = 8'd48;
assign pow_value[30] = 8'd96;
assign pow_value[31] = 8'd192;
assign pow_value[32] = 8'd157;
assign pow_value[33] = 8'd39;
assign pow_value[34] = 8'd78;
assign pow_value[35] = 8'd156;
assign pow_value[36] = 8'd37;
assign pow_value[37] = 8'd74;
assign pow_value[38] = 8'd148;
assign pow_value[39] = 8'd53;
assign pow_value[40] = 8'd106;
assign pow_value[41] = 8'd212;
assign pow_value[42] = 8'd181;
assign pow_value[43] = 8'd119;
assign pow_value[44] = 8'd238;
assign pow_value[45] = 8'd193;
assign pow_value[46] = 8'd159;
assign pow_value[47] = 8'd35;
assign pow_value[48] = 8'd70;
assign pow_value[49] = 8'd140;
assign pow_value[50] = 8'd5;
assign pow_value[51] = 8'd10;
assign pow_value[52] = 8'd20;
assign pow_value[53] = 8'd40;
assign pow_value[54] = 8'd80;
assign pow_value[55] = 8'd160;
assign pow_value[56] = 8'd93;
assign pow_value[57] = 8'd186;
assign pow_value[58] = 8'd105;
assign pow_value[59] = 8'd210;
assign pow_value[60] = 8'd185;
assign pow_value[61] = 8'd111;
assign pow_value[62] = 8'd222;
assign pow_value[63] = 8'd161;
assign pow_value[64] = 8'd95;
assign pow_value[65] = 8'd190;
assign pow_value[66] = 8'd97;
assign pow_value[67] = 8'd194;
assign pow_value[68] = 8'd153;
assign pow_value[69] = 8'd47;
assign pow_value[70] = 8'd94;
assign pow_value[71] = 8'd188;
assign pow_value[72] = 8'd101;
assign pow_value[73] = 8'd202;
assign pow_value[74] = 8'd137;
assign pow_value[75] = 8'd15;
assign pow_value[76] = 8'd30;
assign pow_value[77] = 8'd60;
assign pow_value[78] = 8'd120;
assign pow_value[79] = 8'd240;
assign pow_value[80] = 8'd253;
assign pow_value[81] = 8'd231;
assign pow_value[82] = 8'd211;
assign pow_value[83] = 8'd187;
assign pow_value[84] = 8'd107;
assign pow_value[85] = 8'd214;
assign pow_value[86] = 8'd177;
assign pow_value[87] = 8'd127;
assign pow_value[88] = 8'd254;
assign pow_value[89] = 8'd225;
assign pow_value[90] = 8'd223;
assign pow_value[91] = 8'd163;
assign pow_value[92] = 8'd91;
assign pow_value[93] = 8'd182;
assign pow_value[94] = 8'd113;
assign pow_value[95] = 8'd226;
assign pow_value[96] = 8'd217;
assign pow_value[97] = 8'd175;
assign pow_value[98] = 8'd67;
assign pow_value[99] = 8'd134;
assign pow_value[100] = 8'd17;
assign pow_value[101] = 8'd34;
assign pow_value[102] = 8'd68;
assign pow_value[103] = 8'd136;
assign pow_value[104] = 8'd13;
assign pow_value[105] = 8'd26;
assign pow_value[106] = 8'd52;
assign pow_value[107] = 8'd104;
assign pow_value[108] = 8'd208;
assign pow_value[109] = 8'd189;
assign pow_value[110] = 8'd103;
assign pow_value[111] = 8'd206;
assign pow_value[112] = 8'd129;
assign pow_value[113] = 8'd31;
assign pow_value[114] = 8'd62;
assign pow_value[115] = 8'd124;
assign pow_value[116] = 8'd248;
assign pow_value[117] = 8'd237;
assign pow_value[118] = 8'd199;
assign pow_value[119] = 8'd147;
assign pow_value[120] = 8'd59;
assign pow_value[121] = 8'd118;
assign pow_value[122] = 8'd236;
assign pow_value[123] = 8'd197;
assign pow_value[124] = 8'd151;
assign pow_value[125] = 8'd51;
assign pow_value[126] = 8'd102;
assign pow_value[127] = 8'd204;
assign pow_value[128] = 8'd133;
assign pow_value[129] = 8'd23;
assign pow_value[130] = 8'd46;
assign pow_value[131] = 8'd92;
assign pow_value[132] = 8'd184;
assign pow_value[133] = 8'd109;
assign pow_value[134] = 8'd218;
assign pow_value[135] = 8'd169;
assign pow_value[136] = 8'd79;
assign pow_value[137] = 8'd158;
assign pow_value[138] = 8'd33;
assign pow_value[139] = 8'd66;
assign pow_value[140] = 8'd132;
assign pow_value[141] = 8'd21;
assign pow_value[142] = 8'd42;
assign pow_value[143] = 8'd84;
assign pow_value[144] = 8'd168;
assign pow_value[145] = 8'd77;
assign pow_value[146] = 8'd154;
assign pow_value[147] = 8'd41;
assign pow_value[148] = 8'd82;
assign pow_value[149] = 8'd164;
assign pow_value[150] = 8'd85;
assign pow_value[151] = 8'd170;
assign pow_value[152] = 8'd73;
assign pow_value[153] = 8'd146;
assign pow_value[154] = 8'd57;
assign pow_value[155] = 8'd114;
assign pow_value[156] = 8'd228;
assign pow_value[157] = 8'd213;
assign pow_value[158] = 8'd183;
assign pow_value[159] = 8'd115;
assign pow_value[160] = 8'd230;
assign pow_value[161] = 8'd209;
assign pow_value[162] = 8'd191;
assign pow_value[163] = 8'd99;
assign pow_value[164] = 8'd198;
assign pow_value[165] = 8'd145;
assign pow_value[166] = 8'd63;
assign pow_value[167] = 8'd126;
assign pow_value[168] = 8'd252;
assign pow_value[169] = 8'd229;
assign pow_value[170] = 8'd215;
assign pow_value[171] = 8'd179;
assign pow_value[172] = 8'd123;
assign pow_value[173] = 8'd246;
assign pow_value[174] = 8'd241;
assign pow_value[175] = 8'd255;
assign pow_value[176] = 8'd227;
assign pow_value[177] = 8'd219;
assign pow_value[178] = 8'd171;
assign pow_value[179] = 8'd75;
assign pow_value[180] = 8'd150;
assign pow_value[181] = 8'd49;
assign pow_value[182] = 8'd98;
assign pow_value[183] = 8'd196;
assign pow_value[184] = 8'd149;
assign pow_value[185] = 8'd55;
assign pow_value[186] = 8'd110;
assign pow_value[187] = 8'd220;
assign pow_value[188] = 8'd165;
assign pow_value[189] = 8'd87;
assign pow_value[190] = 8'd174;
assign pow_value[191] = 8'd65;
assign pow_value[192] = 8'd130;
assign pow_value[193] = 8'd25;
assign pow_value[194] = 8'd50;
assign pow_value[195] = 8'd100;
assign pow_value[196] = 8'd200;
assign pow_value[197] = 8'd141;


generate
  for (i = 0; i < NSYMB; i = i + 1) begin : eval_loop

    // Power of 2 calculation
    //gf_pow u_gf_pow_$i (
    //  .index(i[7:0]),
    //  .value(pow_value[i])
    //);

    gf_poly_eval u_poly_eval_$i (
      .poly(reversed_sigma),
      .x(pow_value[i]),
      .result(error_loc_vector[i])
    ); 

  end
endgenerate

reg [2:0] valid_index;

always @(*) begin
  zero_count = 0;
  valid_index = 0;
  error_location_temp[0] =0;
  error_location_temp[1] =0;
  error_location_temp[2] =0;
  for (j = 0; j < NSYMB; j = j + 1) begin
    if (error_loc_vector[j] == 8'b0) begin
      error_location_temp[zero_count] = j;
      valid_index[zero_count] = 1;
      zero_count = zero_count + 1;
    end
  end
end






assign X_inv = {inv_pow_value_X2,inv_pow_value_X1,inv_pow_value_X0};
assign l0 = valid_index[0] ? (8'd197 - error_location_temp[0]) : 8'b0;
assign l1 = valid_index[1] ? (8'd197 - error_location_temp[1]) : 8'b0;
assign l2 = valid_index[2] ? (8'd197 - error_location_temp[2]) : 8'b0;  //it shouldnt get here since this RS supports detection of up to 2 errors, could indicated a more than 2 errors

assign X[7:0] = valid_index[0] ? pow_value_0 : 8'b0;
assign X[15:8] = valid_index[1] ? pow_value_1 : 8'b0;
assign X[23:16] = valid_index[2] ? pow_value_2 : 8'b0;



gf_pow u_gf_pow_0 (
    .index(error_location_temp[0]),
    .value(pow_value_0)
);

gf_pow u_gf_pow_1 (
    .index(error_location_temp[1]),
    .value(pow_value_1)
);

gf_pow u_gf_pow_2 (
    .index(error_location_temp[2]),
    .value(pow_value_2)
);


gf_inv u_gf_inv_0 (
      .index(X[7:0]),
      .value(inv_pow_value_X0)
    );

gf_inv u_gf_inv_1 (
      .index(X[15:8]),
      .value(inv_pow_value_X1)
    );

gf_inv u_gf_inv_2 (
      .index(X[23:16]),
      .value(inv_pow_value_X2)
    );

endmodule