`timescale 1ns / 1ps
module test_sha256;

    localparam STEP = 20;
    localparam HALF_STEP = STEP / 2;
    localparam BLOCKSIZE = 512;
    localparam HASHSIZE = 256;

    reg clk = 0;
    reg [BLOCKSIZE-1:0] block;
    reg block_valid;
    wire [HASHSIZE-1:0] prev_hash = {
      32'h6a09e667, 32'hbb67ae85, 32'h3c6ef372, 32'ha54ff53a,
      32'h510e527f, 32'h9b05688c, 32'h1f83d9ab, 32'h5be0cd19
    };
    wire [HASHSIZE-1:0] hash;
    wire hash_valid;
    wire ready;

    always #(HALF_STEP) begin
        clk <= ~clk;
    end

    sha256 sha256 (
        .clk(clk),
        .block(block),
        .block_valid(block_valid),
        .prev_hash(prev_hash),
        .hash(hash),
        .hash_valid(hash_valid),
        .ready(ready)
    );

    always @ (posedge hash_valid) begin
      $display("Hash: %064x", hash);
    end

    task feed_block;
      input [BLOCKSIZE-1:0] new_block;
      begin
        wait(ready);
        @ (posedge clk);
        #1;
        block <= new_block;
        block_valid <= 1;
        $display("FeedBlock: %0128x", new_block);
        #(STEP);
        block <= 0;
        block_valid <= 0;
        wait(hash_valid);
        @ (posedge clk);
        #1;
      end
    endtask

    initial begin
      feed_block(512'h67458b6bc6237b3269983c647348336651dcb074ff5c49194a94e82aec585562291f8e23cd7ce846ba581b3dabd77e50f241b12efb1eb741e3a9e27946e14575);
      feed_block(512'h7c005f51c262d05b54082012f827b14d1b231602e8e9161fe7cd90118d43ef66760f0e145a2552332ef99c106372ed0d33c2dc7f9fd7ef1bc9c4a7419a07686b);
      #(STEP*10)
      $finish;
    end

endmodule
