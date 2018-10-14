`timescale 1ns / 1ps
module test_sha256_pipeline;

    localparam STEP = 20;
    localparam HALF_STEP = STEP / 2;
    localparam BLOCKSIZE = 512;
    localparam HASHSIZE = 256;

    reg clk = 0;
    reg [BLOCKSIZE-1:0] block;
    reg block_valid = 0;
    wire [HASHSIZE-1:0] prev_hash_const = {
      32'h6a09e667, 32'hbb67ae85, 32'h3c6ef372, 32'ha54ff53a,
      32'h510e527f, 32'h9b05688c, 32'h1f83d9ab, 32'h5be0cd19
    };
    wire [HASHSIZE-1:0] hash;
    wire hash_valid;

    always #(HALF_STEP) begin
        clk <= ~clk;
    end

    sha256_pipeline sha256_pipeline (
        .clk(clk),
        .block(block),
        .block_valid(block_valid),
        .prev_hash(prev_hash_const),
        .hash(hash),
        .hash_valid(hash_valid)
    );
    always @ (posedge clk) begin
      if (hash_valid) begin
        $display("Hash: %064x", hash);
      end
    end

    initial begin
      #1;
      #(STEP*5)
      block_valid <= 1;
      block <= 512'h67458b6bc6237b3269983c647348336651dcb074ff5c49194a94e82aec585562291f8e23cd7ce846ba581b3dabd77e50f241b12efb1eb741e3a9e27946e14575;
      #(STEP);
      block <= 512'h7c005f51c262d05b54082012f827b14d1b231602e8e9161fe7cd90118d43ef66760f0e145a2552332ef99c106372ed0d33c2dc7f9fd7ef1bc9c4a7419a07686b;
      #(STEP);
      block <= 512'h66fb6a4e325de4250d509b51b7d71b4331ba2d3f58e4837ca33071255ad9bb6225616c435d898c6205b13a3317a31d7258a84324e95a1d2d5e846367d4a8a275;
      #(STEP);
      block <= 512'habbded08b28c8379cdd05343c6e0030b9b769a18b49ee4545424f3711186a82c0ec43608821d900274f8953a4186130821f57f1e3dbd3d7cdc8d7b7387f0ea6c;
      #(STEP);
      block <= 512'h701a2222e9dd16453ec80630a1d44f6141c29a41e1f87755fcad0b44672307053e820438015f46777ec62477972a485ceab96324dc4a885e6bd3ea519677512d;
      #(STEP);
      block <= 512'h8fd70b5838a43e155c5855382a4ea670ec42236ab07c482a3bd44e1dfb065a72329ad82cafcce4573c8d6d7a548f584bec892254181be96ddb7f43385ca44476;
      #(STEP);
      block <= 512'h02f9ff321a484a68fe78945743bb9a74fb40c23dfa26a01baadea1793ac3c675fb85e61229a5c670d1ed0e52e63f4a3705f04e4f3cc1f9237cb79b6494c75a27;
      #(STEP);
      block <= 512'h75653839d80ff11cbe15011861a85b23898c3947f9e94f355cafb515bb261274a8b6340d993c23100fb66a3f95405761b1570c7eeb35ae77f1e49b57b3500c31;
      #(STEP);
      block_valid <= 0;
      #(STEP*64);
      wait(hash_valid == 0);
      #(STEP*10);
      $finish;
    end

endmodule
