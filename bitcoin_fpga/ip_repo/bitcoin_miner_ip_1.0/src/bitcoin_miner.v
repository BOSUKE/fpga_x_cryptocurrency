module bitcoin_miner (
  input wire clk,
  input wire start,
  input wire [255:0] first_block_hash,
  input wire [127:0] second_block,
  input wire [255:0] target,
  input wire [31:0]  max_nonce,
  output reg running,
  output reg found,
  reg [31:0] nonce
  );

  localparam  BLOCKSIZE = 512;
  localparam  HASHSIZE = 256;

  reg [31:0] current_nonce_be;
  wire [31:0] current_nonce_le;
  wire [31:0] output_nonce = current_nonce_be - 130;

  swap_endian swap_nonce_b2l(.src(current_nonce_be),.dst(current_nonce_le));

  wire [31:0] start_nonce_le = second_block[31:0];
  wire [31:0] start_nonce_be;
  swap_endian swap_nonce_l2b(.src(start_nonce_le), .dst(start_nonce_be));

  wire [HASHSIZE-1:0] hash_0, hash_1;
  wire hash_valid_0, hash_valid_1;

  wire [BLOCKSIZE-1:0] block_0 = {
    second_block[127:32], current_nonce_le,
    32'h80000000, 32'h00000000, 32'h00000000, 32'h00000000,
    32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000,
    32'h00000000, 32'h00000000, 32'h00000000, 32'h00000280};
  wire [BLOCKSIZE-1:0] block_1 = {
    hash_0,
    32'h80000000, 32'h00000000, 32'h00000000, 32'h00000000,
    32'h00000000, 32'h00000000, 32'h00000000, 32'h00000100};

  wire [HASHSIZE-1:0] prev_hash_0 = first_block_hash;
  wire [HASHSIZE-1:0] prev_hash_1 = {
    32'h6a09e667, 32'hbb67ae85, 32'h3c6ef372, 32'ha54ff53a,
    32'h510e527f, 32'h9b05688c, 32'h1f83d9ab, 32'h5be0cd19};

  sha256_pipeline sha256_0 (
    .clk(clk),
    .block_valid(running),
    .block(block_0),
    .prev_hash(prev_hash_0),
    .hash(hash_0),
    .hash_valid(hash_valid_0));

  sha256_pipeline sha256_1 (
    .clk(clk),
    .block_valid(hash_valid_0),
    .block(block_1),
    .prev_hash(prev_hash_1),
    .hash(hash_1),
    .hash_valid(hash_valid_1));

  wire [HASHSIZE-1:0] hash_sw;
  swap_endian #(.UNIT_WIDTH(8),
                .UNIT_COUNT(HASHSIZE/8)) swap_hash(.src(hash_1),
                                                   .dst(hash_sw));


  initial begin
    running <= 0;
    found <= 0;
    current_nonce_be <= 0;
  end

  wire nonce_end_flag = (nonce == max_nonce);
  wire found_flag = (hash_sw <= target);

  always @ (posedge clk) begin
    if (running) begin
      current_nonce_be <= current_nonce_be + 1;
      if (hash_valid_1) begin
          nonce <= output_nonce;
          found <= found_flag;
          if (nonce_end_flag || found_flag) begin
              running <= 0;
          end
      end
    end else begin
      if (start) begin
        running <= 1;
        found <= 0;
        current_nonce_be <= start_nonce_be;
        nonce <= start_nonce_be;
      end
    end
  end

endmodule
