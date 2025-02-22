`timescale 1ns / 1ps

module carry_lookahead_4bit (
  input  [3:0] a, b,
  input        cin,
  output [3:0] sum,
  output       cout
);
  wire [3:0] g, p;
  wire c1, c2, c3, c4;

  assign g = a & b;         // Generate
  assign p = a ^ b;         // Propagate

  // Carry computation
  assign c1 = g[0] | (p[0] & cin);
  assign c2 = g[1] | (p[1] & c1);
  assign c3 = g[2] | (p[2] & c2);
  assign c4 = g[3] | (p[3] & c3);  // Final carry-out

  // Sum computation
  assign sum[0] = p[0] ^ cin;
  assign sum[1] = p[1] ^ c1;
  assign sum[2] = p[2] ^ c2;
  assign sum[3] = p[3] ^ c3;

  assign cout = c4;  // Single carry-out for chaining
endmodule