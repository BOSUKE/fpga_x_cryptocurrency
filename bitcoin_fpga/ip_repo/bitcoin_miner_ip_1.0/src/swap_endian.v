module swap_endian #(
  parameter UNIT_WIDTH = 8,
  parameter UNIT_COUNT = 4
  ) (
    input wire [(UNIT_WIDTH*UNIT_COUNT)-1:0] src,
    output reg [(UNIT_WIDTH*UNIT_COUNT)-1:0] dst
  );

 integer i;
  always @* begin
    for (i = 0; i < UNIT_COUNT; i = i + 1) begin
      dst[(i * UNIT_WIDTH) +: UNIT_WIDTH] = src[((UNIT_COUNT - i) * UNIT_WIDTH - 1) -: UNIT_WIDTH];
    end
  end

endmodule
