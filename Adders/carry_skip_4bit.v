`timescale 1ns / 1ps

module carry_skip_4bit (
  input  [3:0] a, b,
  input        cin,
  output [3:0] sum,
  output       cout
);
  wire [3:0] p, g;
  wire P;              // Group propagate signal
  wire c1, c2, c3, ripple_carry;

  // Propagate and generate signals
  assign p = a ^ b;    // Individual propagate
  assign g = a & b;    // Individual generate

  // Group propagate (P = p0 & p1 & p2 & p3)
  assign P = &p;

  // Ripple-carry computation
  assign c1 = g[0] | (p[0] & cin);
  assign c2 = g[1] | (p[1] & c1);
  assign c3 = g[2] | (p[2] & c2);
  assign ripple_carry = g[3] | (p[3] & c3);

  // Sum computation
  assign sum = p ^ {c3, c2, c1, cin};

  // Carry-out mux: bypass if P=1, else use ripple carry
  assign cout = P ? cin : ripple_carry;
endmodule
