module sha256_pipeline (
  input wire clk,
  input wire block_valid,
  input wire [BLOCKSIZE-1:0] block,
  input wire [HASHSIZE-1:0] prev_hash,
  output wire [HASHSIZE-1:0] hash,
  output wire hash_valid
  );

  localparam WORDSIZE = 32;
  localparam BLOCKSIZE = 512;
  localparam HASHSIZE = 256;
  localparam ROUNDCOUNT = 64;

  wire [WORDSIZE-1:0] iv_0 = prev_hash[WORDSIZE*7 +: WORDSIZE];
  wire [WORDSIZE-1:0] iv_1 = prev_hash[WORDSIZE*6 +: WORDSIZE];
  wire [WORDSIZE-1:0] iv_2 = prev_hash[WORDSIZE*5 +: WORDSIZE];
  wire [WORDSIZE-1:0] iv_3 = prev_hash[WORDSIZE*4 +: WORDSIZE];
  wire [WORDSIZE-1:0] iv_4 = prev_hash[WORDSIZE*3 +: WORDSIZE];
  wire [WORDSIZE-1:0] iv_5 = prev_hash[WORDSIZE*2 +: WORDSIZE];
  wire [WORDSIZE-1:0] iv_6 = prev_hash[WORDSIZE*1 +: WORDSIZE];
  wire [WORDSIZE-1:0] iv_7 = prev_hash[WORDSIZE*0 +: WORDSIZE];

  wire [WORDSIZE-1:0] reg_a_x [0:ROUNDCOUNT];
  wire [WORDSIZE-1:0] reg_b_x [0:ROUNDCOUNT];
  wire [WORDSIZE-1:0] reg_c_x [0:ROUNDCOUNT];
  wire [WORDSIZE-1:0] reg_d_x [0:ROUNDCOUNT];
  wire [WORDSIZE-1:0] reg_e_x [0:ROUNDCOUNT];
  wire [WORDSIZE-1:0] reg_f_x [0:ROUNDCOUNT];
  wire [WORDSIZE-1:0] reg_g_x [0:ROUNDCOUNT];
  wire [WORDSIZE-1:0] reg_h_x [0:ROUNDCOUNT];
  assign reg_a_x[0] = iv_0;
  assign reg_b_x[0] = iv_1;
  assign reg_c_x[0] = iv_2;
  assign reg_d_x[0] = iv_3;
  assign reg_e_x[0] = iv_4;
  assign reg_f_x[0] = iv_5;
  assign reg_g_x[0] = iv_6;
  assign reg_h_x[0] = iv_7;

  wire [BLOCKSIZE-1:0] message_x[0:ROUNDCOUNT];
  assign message_x[0] = block;

  reg [WORDSIZE-1:0] h_0, h_1, h_2, h_3, h_4, h_5, h_6, h_7;
  assign hash = {h_0, h_1, h_2, h_3, h_4, h_5, h_6, h_7};

  reg [ROUNDCOUNT:0] hash_valid_x;
  assign hash_valid = hash_valid_x[ROUNDCOUNT];

  localparam [ROUNDCOUNT*WORDSIZE-1:0] k_table = {
    32'h428a2f98, 32'h71374491, 32'hb5c0fbcf, 32'he9b5dba5,
    32'h3956c25b, 32'h59f111f1, 32'h923f82a4, 32'hab1c5ed5,
    32'hd807aa98, 32'h12835b01, 32'h243185be, 32'h550c7dc3,
    32'h72be5d74, 32'h80deb1fe, 32'h9bdc06a7, 32'hc19bf174,
    32'he49b69c1, 32'hefbe4786, 32'h0fc19dc6, 32'h240ca1cc,
    32'h2de92c6f, 32'h4a7484aa, 32'h5cb0a9dc, 32'h76f988da,
    32'h983e5152, 32'ha831c66d, 32'hb00327c8, 32'hbf597fc7,
    32'hc6e00bf3, 32'hd5a79147, 32'h06ca6351, 32'h14292967,
    32'h27b70a85, 32'h2e1b2138, 32'h4d2c6dfc, 32'h53380d13,
    32'h650a7354, 32'h766a0abb, 32'h81c2c92e, 32'h92722c85,
    32'ha2bfe8a1, 32'ha81a664b, 32'hc24b8b70, 32'hc76c51a3,
    32'hd192e819, 32'hd6990624, 32'hf40e3585, 32'h106aa070,
    32'h19a4c116, 32'h1e376c08, 32'h2748774c, 32'h34b0bcb5,
    32'h391c0cb3, 32'h4ed8aa4a, 32'h5b9cca4f, 32'h682e6ff3,
    32'h748f82ee, 32'h78a5636f, 32'h84c87814, 32'h8cc70208,
    32'h90befffa, 32'ha4506ceb, 32'hbef9a3f7, 32'hc67178f2};

  generate
    genvar i;
    for (i = 0; i < ROUNDCOUNT; i = i + 1) begin
      sha256_round r(
        .clk(clk),
        .in_reg_a(reg_a_x[i]),
        .in_reg_b(reg_b_x[i]),
        .in_reg_c(reg_c_x[i]),
        .in_reg_d(reg_d_x[i]),
        .in_reg_e(reg_e_x[i]),
        .in_reg_f(reg_f_x[i]),
        .in_reg_g(reg_g_x[i]),
        .in_reg_h(reg_h_x[i]),
        .in_kt(k_table[WORDSIZE*(ROUNDCOUNT-i-1) +: WORDSIZE]),
        .in_message(message_x[i]),
        .out_reg_a(reg_a_x[i+1]),
        .out_reg_b(reg_b_x[i+1]),
        .out_reg_c(reg_c_x[i+1]),
        .out_reg_d(reg_d_x[i+1]),
        .out_reg_e(reg_e_x[i+1]),
        .out_reg_f(reg_f_x[i+1]),
        .out_reg_g(reg_g_x[i+1]),
        .out_reg_h(reg_h_x[i+1]),
        .out_messasge(message_x[i+1]));
    end
  endgenerate

  always @ (posedge clk) begin
    h_0 <= iv_0 + reg_a_x[ROUNDCOUNT];
    h_1 <= iv_1 + reg_b_x[ROUNDCOUNT];
    h_2 <= iv_2 + reg_c_x[ROUNDCOUNT];
    h_3 <= iv_3 + reg_d_x[ROUNDCOUNT];
    h_4 <= iv_4 + reg_e_x[ROUNDCOUNT];
    h_5 <= iv_5 + reg_f_x[ROUNDCOUNT];
    h_6 <= iv_6 + reg_g_x[ROUNDCOUNT];
    h_7 <= iv_7 + reg_h_x[ROUNDCOUNT];
  end

  initial begin
    hash_valid_x <= 0;
  end
  always @ (posedge clk) begin
    hash_valid_x[0] <= block_valid;
    hash_valid_x[ROUNDCOUNT:1] <= hash_valid_x[ROUNDCOUNT-1:0];
  end

endmodule
