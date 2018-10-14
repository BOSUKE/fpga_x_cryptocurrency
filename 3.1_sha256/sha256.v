module sha256 (
  input wire clk,
  input wire [BLOCKSIZE-1:0] block,
  input wire block_valid,
  input wire [HASHSIZE-1:0] prev_hash,
  output wire [HASHSIZE-1:0] hash,
  output wire hash_valid,
  output wire ready
  );

  localparam  WORDSIZE = 32;
  localparam  BLOCKSIZE = 512;
  localparam  HASHSIZE = 256;

  reg running;
  reg [6:0] round;
  reg valid;

  reg [WORDSIZE-1:0] h_0, h_1, h_2, h_3, h_4, h_5, h_6, h_7;
  reg [WORDSIZE-1:0] reg_a, reg_b, reg_c, reg_d, reg_e, reg_f, reg_g, reg_h;
  wire [WORDSIZE-1:0] kt;
  wire [WORDSIZE-1:0] wt;

  wire req_update = ~running & block_valid;
  wire finished = (round == 64);

  assign hash = {h_0, h_1, h_2, h_3, h_4, h_5, h_6, h_7};
  assign hash_valid = valid;
  assign ready = ~running;

  initial begin
    running <= 0;
    round <= 0;
    valid <= 0;
  end

  always @ (posedge clk) begin
    if (running) begin
      if (finished) begin
        running <= 0;
      end
    end else begin
      if (req_update) begin
        running <= 1;
      end
    end
  end

  always @ (posedge clk) begin
    if (running) begin
      round <= round + 1;
    end else if (req_update) begin
      round <= 0;
    end
  end

  always @ (posedge clk) begin
    if (req_update) begin
      valid <= 0;
    end else if (finished) begin
      valid <= 1;
    end
  end

  wire [WORDSIZE-1:0] iv_0 = prev_hash[WORDSIZE*7 +: WORDSIZE];
  wire [WORDSIZE-1:0] iv_1 = prev_hash[WORDSIZE*6 +: WORDSIZE];
  wire [WORDSIZE-1:0] iv_2 = prev_hash[WORDSIZE*5 +: WORDSIZE];
  wire [WORDSIZE-1:0] iv_3 = prev_hash[WORDSIZE*4 +: WORDSIZE];
  wire [WORDSIZE-1:0] iv_4 = prev_hash[WORDSIZE*3 +: WORDSIZE];
  wire [WORDSIZE-1:0] iv_5 = prev_hash[WORDSIZE*2 +: WORDSIZE];
  wire [WORDSIZE-1:0] iv_6 = prev_hash[WORDSIZE*1 +: WORDSIZE];
  wire [WORDSIZE-1:0] iv_7 = prev_hash[WORDSIZE*0 +: WORDSIZE];

  always @ (posedge clk) begin
      if (req_update) begin
        h_0 <= iv_0;
        h_1 <= iv_1;
        h_2 <= iv_2;
        h_3 <= iv_3;
        h_4 <= iv_4;
        h_5 <= iv_5;
        h_6 <= iv_6;
        h_7 <= iv_7;
      end else if (running & finished) begin
        h_0 <= h_0 + reg_a;
        h_1 <= h_1 + reg_b;
        h_2 <= h_2 + reg_c;
        h_3 <= h_3 + reg_d;
        h_4 <= h_4 + reg_e;
        h_5 <= h_5 + reg_f;
        h_6 <= h_6 + reg_g;
        h_7 <= h_7 + reg_h;
      end
  end

  wire [WORDSIZE-1:0] t1 = reg_h + calc_sum_1(reg_e) + calc_ch(reg_e, reg_f, reg_g) + kt + wt;
  wire [WORDSIZE-1:0] t2 = calc_sum_0(reg_a) + calc_maj(reg_a, reg_b, reg_c);

  always @ (posedge clk) begin
    if (req_update) begin
      reg_a <= iv_0;
      reg_b <= iv_1;
      reg_c <= iv_2;
      reg_d <= iv_3;
      reg_e <= iv_4;
      reg_f <= iv_5;
      reg_g <= iv_6;
      reg_h <= iv_7;
    end else begin
      reg_a <= t1 + t2;
      reg_b <= reg_a;
      reg_c <= reg_b;
      reg_d <= reg_c;
      reg_e <= reg_d + t1;
      reg_f <= reg_e;
      reg_g <= reg_f;
      reg_h <= reg_g;
    end
  end

  reg [WORDSIZE*16-1:0] message;
  wire [WORDSIZE-1:0] wt_2 = message[WORDSIZE*1 +: WORDSIZE];
  wire [WORDSIZE-1:0] wt_7 = message[WORDSIZE*6 +: WORDSIZE];
  wire [WORDSIZE-1:0] wt_15 = message[WORDSIZE*14 +: WORDSIZE];
  wire [WORDSIZE-1:0] wt_16 = message[WORDSIZE*15 +: WORDSIZE];

  wire [WORDSIZE-1:0] wt_next = calc_s_sum_1(wt_2) + wt_7 + calc_s_sum_0(wt_15) + wt_16;
  assign wt = message[WORDSIZE*15 +: WORDSIZE];
  always @(posedge clk) begin
    if (req_update) begin
      message <= block;
    end else begin
      message <= {message[0 +: WORDSIZE*15], wt_next};
    end
  end

  function [WORDSIZE-1:0] calc_ch;
    input [WORDSIZE-1:0] x;
    input [WORDSIZE-1:0] y;
    input [WORDSIZE-1:0] z;
    begin
      calc_ch = (x & y) ^ (~x & z);
    end
  endfunction

  function [WORDSIZE-1:0] calc_maj;
    input [WORDSIZE-1:0] x;
    input [WORDSIZE-1:0] y;
    input [WORDSIZE-1:0] z;
    begin
      calc_maj = (x & y) ^ (x & z) ^ (y & z);
    end
  endfunction

  function [WORDSIZE-1:0] calc_sum_0;
    input [WORDSIZE-1:0] x;
    begin
      calc_sum_0 = {x[1:0], x[31:2]} ^ {x[12:0], x[31:13]} ^ {x[21:0], x[31:22]};
    end
  endfunction

  function [WORDSIZE-1:0] calc_sum_1;
    input [WORDSIZE-1:0] x;
    begin
      calc_sum_1 = {x[5:0], x[31:6]} ^ {x[10:0], x[31:11]} ^ {x[24:0], x[31:25]};
    end
  endfunction

  function [WORDSIZE-1:0] calc_s_sum_0;
    input [WORDSIZE-1:0] x;
    begin
      calc_s_sum_0 = {x[6:0], x[31:7]} ^ {x[17:0], x[31:18]} ^ (x >> 3);
    end
  endfunction

  function [WORDSIZE-1:0] calc_s_sum_1;
    input [WORDSIZE-1:0] x;
    begin
      calc_s_sum_1 = {x[16:0], x[31:17]} ^ {x[18:0], x[31:19]} ^ (x >> 10);
    end
  endfunction


  assign kt = k_table(round[5:0]);
  function [WORDSIZE-1:0] k_table;
    input [5:0] addr;
    begin
      case(addr)
        00: k_table = 32'h428a2f98;
        01: k_table = 32'h71374491;
        02: k_table = 32'hb5c0fbcf;
        03: k_table = 32'he9b5dba5;
        04: k_table = 32'h3956c25b;
        05: k_table = 32'h59f111f1;
        06: k_table = 32'h923f82a4;
        07: k_table = 32'hab1c5ed5;
        08: k_table = 32'hd807aa98;
        09: k_table = 32'h12835b01;
        10: k_table = 32'h243185be;
        11: k_table = 32'h550c7dc3;
        12: k_table = 32'h72be5d74;
        13: k_table = 32'h80deb1fe;
        14: k_table = 32'h9bdc06a7;
        15: k_table = 32'hc19bf174;
        16: k_table = 32'he49b69c1;
        17: k_table = 32'hefbe4786;
        18: k_table = 32'h0fc19dc6;
        19: k_table = 32'h240ca1cc;
        20: k_table = 32'h2de92c6f;
        21: k_table = 32'h4a7484aa;
        22: k_table = 32'h5cb0a9dc;
        23: k_table = 32'h76f988da;
        24: k_table = 32'h983e5152;
        25: k_table = 32'ha831c66d;
        26: k_table = 32'hb00327c8;
        27: k_table = 32'hbf597fc7;
        28: k_table = 32'hc6e00bf3;
        29: k_table = 32'hd5a79147;
        30: k_table = 32'h06ca6351;
        31: k_table = 32'h14292967;
        32: k_table = 32'h27b70a85;
        33: k_table = 32'h2e1b2138;
        34: k_table = 32'h4d2c6dfc;
        35: k_table = 32'h53380d13;
        36: k_table = 32'h650a7354;
        37: k_table = 32'h766a0abb;
        38: k_table = 32'h81c2c92e;
        39: k_table = 32'h92722c85;
        40: k_table = 32'ha2bfe8a1;
        41: k_table = 32'ha81a664b;
        42: k_table = 32'hc24b8b70;
        43: k_table = 32'hc76c51a3;
        44: k_table = 32'hd192e819;
        45: k_table = 32'hd6990624;
        46: k_table = 32'hf40e3585;
        47: k_table = 32'h106aa070;
        48: k_table = 32'h19a4c116;
        49: k_table = 32'h1e376c08;
        50: k_table = 32'h2748774c;
        51: k_table = 32'h34b0bcb5;
        52: k_table = 32'h391c0cb3;
        53: k_table = 32'h4ed8aa4a;
        54: k_table = 32'h5b9cca4f;
        55: k_table = 32'h682e6ff3;
        56: k_table = 32'h748f82ee;
        57: k_table = 32'h78a5636f;
        58: k_table = 32'h84c87814;
        59: k_table = 32'h8cc70208;
        60: k_table = 32'h90befffa;
        61: k_table = 32'ha4506ceb;
        62: k_table = 32'hbef9a3f7;
        63: k_table = 32'hc67178f2;
      endcase
    end
  endfunction

endmodule
