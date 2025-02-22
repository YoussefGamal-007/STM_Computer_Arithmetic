`timescale 1ns / 1ps

module carry_skip_generic #(
  parameter N = 64      // Must be a power of 2 (16, 32, 64, ...)
) (
  input  [N-1:0] a, b,
  input           cin,
  output          cout,
  output [N-1:0] sum
);
  localparam NUM_BLOCKS = N / 4;  // Number of 4-bit blocks
  wire [NUM_BLOCKS:0] carry_chain;

  assign carry_chain[0] = cin;    // Global carry-in

  // Instantiate N/4 carry-skip blocks
  genvar i;
  generate
    for (i = 0; i < NUM_BLOCKS; i = i + 1) begin : block
      carry_skip_4bit cs4 (
        .a    (a[i*4 +: 4]),      // 4-bit slice of 'a'
        .b    (b[i*4 +: 4]),      // 4-bit slice of 'b'
        .cin  (carry_chain[i]),   // Carry-in from previous block
        .sum  (sum[i*4 +: 4]),    // 4-bit slice of 'sum'
        .cout (carry_chain[i+1])  // Carry-out to next block
      );
    end
  endgenerate

  assign cout = carry_chain[NUM_BLOCKS];  // Final carry-out
endmodule