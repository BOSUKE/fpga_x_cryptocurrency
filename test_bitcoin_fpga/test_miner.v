`timescale 1ns / 1ps
module test_miner(
    );

  localparam STEP = 20;
  localparam HALF_STEP = STEP / 2;
  localparam WORDSIZE = 32;
  localparam HASHSIZE = 256;

  reg clk = 0;
  reg start = 0;
  reg [HASHSIZE-1:0] first_block_hash = 0;
  reg [127:0] second_block = 0;
  wire [255:0] target = 256'h0000000000000000002103e119df591d66792650fcb4334f1f6dd15641261729 + 1;
  wire [31:0] max_nonce = 32'hffffffff;
  wire running;
  wire found;
  wire [31:0] nonce;

  always #(HALF_STEP) begin
      clk <= ~clk;
  end

  always @(posedge found) begin
      $display("Nonce: %x", nonce);
  end

  bitcoin_miner miner (
    .clk(clk),
    .start(start),
    .first_block_hash(first_block_hash),
    .second_block(second_block),
    .target(target),
    .max_nonce(max_nonce),
    .running(running),
    .found(found),
    .nonce(nonce));

  initial begin
    #1;
    #(STEP * 10)
    first_block_hash <= 256'hb9f7a3c608fd99ee77e11ba51b486aa5a23a9b2a0518fb23c80991452cc89bdb;
    second_block <= 128'h1548730cd398af5b1f5a27177337f2f4 - 32'h0900_0000;
    start <= 1;
    #(STEP)
    start <= 0;
    wait(running == 0);
    @(posedge clk);
    #1;

    #(STEP * 10);
    $finish;
  end

endmodule
