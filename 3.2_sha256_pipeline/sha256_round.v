module sha256_round (
  input wire clk,
  input wire [WORDSIZE-1:0] in_reg_a,
  input wire [WORDSIZE-1:0] in_reg_b,
  input wire [WORDSIZE-1:0] in_reg_c,
  input wire [WORDSIZE-1:0] in_reg_d,
  input wire [WORDSIZE-1:0] in_reg_e,
  input wire [WORDSIZE-1:0] in_reg_f,
  input wire [WORDSIZE-1:0] in_reg_g,
  input wire [WORDSIZE-1:0] in_reg_h,
  input wire [WORDSIZE-1:0] in_kt,
  input wire [BLOCKSIZE-1:0] in_message,
  output reg [WORDSIZE-1:0] out_reg_a,
  output reg [WORDSIZE-1:0] out_reg_b,
  output reg [WORDSIZE-1:0] out_reg_c,
  output reg [WORDSIZE-1:0] out_reg_d,
  output reg [WORDSIZE-1:0] out_reg_e,
  output reg [WORDSIZE-1:0] out_reg_f,
  output reg [WORDSIZE-1:0] out_reg_g,
  output reg [WORDSIZE-1:0] out_reg_h,
  output reg [BLOCKSIZE-1:0] out_messasge
  );

  localparam  WORDSIZE = 32;
  localparam  BLOCKSIZE = 512;

  wire [WORDSIZE-1:0] wt;

  wire [WORDSIZE-1:0] t1 = in_reg_h + calc_sum_1(in_reg_e) + calc_ch(in_reg_e, in_reg_f, in_reg_g) + in_kt + wt;
  wire [WORDSIZE-1:0] t2 = calc_sum_0(in_reg_a) + calc_maj(in_reg_a, in_reg_b, in_reg_c);

  always @ (posedge clk) begin
    out_reg_a <= t1 + t2;
    out_reg_b <= in_reg_a;
    out_reg_c <= in_reg_b;
    out_reg_d <= in_reg_c;
    out_reg_e <= in_reg_d + t1;
    out_reg_f <= in_reg_e;
    out_reg_g <= in_reg_f;
    out_reg_h <= in_reg_g;
  end

  wire [WORDSIZE-1:0] wt_2 = in_message[WORDSIZE*1 +: WORDSIZE];
  wire [WORDSIZE-1:0] wt_7 = in_message[WORDSIZE*6 +: WORDSIZE];
  wire [WORDSIZE-1:0] wt_15 = in_message[WORDSIZE*14 +: WORDSIZE];
  wire [WORDSIZE-1:0] wt_16 = in_message[WORDSIZE*15 +: WORDSIZE];
  wire [WORDSIZE-1:0] wt_next = calc_s_sum_1(wt_2) + wt_7 + calc_s_sum_0(wt_15) + wt_16;
  assign wt = in_message[WORDSIZE*15 +: WORDSIZE];

  always @ (posedge clk) begin
    out_messasge <= {in_message[0 +: WORDSIZE*15], wt_next};
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

endmodule
