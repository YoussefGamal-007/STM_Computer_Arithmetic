///////////////////////////////////////////////////////////////////////////////
// File Name      : kogge_stone_generic.v
// Author         : Youssef Gamal Eldein
// Date           : 1/2/2025
// Description    : Generic implementation of a Kogge-Stone adder.
//                  This module implements a parallel prefix adder using the
//                  Kogge-Stone architecture. It supports any bit-width (N)
//                  that is a power of 2.
// Assumptions    : 1) Cin = 0 to ease the implementation of the algorithm
//                  2) all squares in the architecture are the black ones
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module kogge_stone_generic(a, b, cout, sum);
  
  parameter N = 64;  // Bit-width of the adder (must be a power of 2)
  
  input [N-1:0] a, b;  // Input operands
  output cout;         // Carry-out
  output [N-1:0] sum;  // Sum of a and b
  
  wire cin;
  assign cin = 0;  // Carry-in is set to 0 for addition
  
  // Memory arrays to store generate (g) and propagate (p) signals at each stage
  reg [N-1:0] g_mem [0:$clog2(N)];  // Generate signals
  reg [N-1:0] p_mem [0:$clog2(N)];  // Propagate signals
  
  integer stage, i;  // Loop variables for stages and bits
  
  always @(*) begin
    // Stage 0: Compute initial generate (g) and propagate (p) signals
    g_mem[0] = a & b;  // Generate: g[i] = a[i] & b[i]
    p_mem[0] = a ^ b;  // Propagate: p[i] = a[i] ^ b[i]
    
    // Parallel prefix computation: Build the prefix tree
    for (stage = 0; stage < $clog2(N); stage = stage + 1) begin
      // Copy previous stage values
      g_mem[stage + 1] = g_mem[stage];
      p_mem[stage + 1] = p_mem[stage];
      
      // Combine generate and propagate signals for the current stage
      for (i = 0; i < (N - 2**stage); i = i + 1) begin
        g_mem[stage + 1][i + (2**stage)] = g_mem[stage][i + (2**stage)] | 
                                           (g_mem[stage][i] & p_mem[stage][i + (2**stage)]);
        p_mem[stage + 1][i + (2**stage)] = p_mem[stage][i] & p_mem[stage][i + (2**stage)];
      end
    end
  end
  
  // Sum computation: sum[i] = p[i] ^ g[i-1:0]
  assign sum = p_mem[0] ^ {g_mem[$clog2(N)][N-2:0], cin};
  
  // Carry-out computation: cout = g[N-1]
  assign cout = g_mem[$clog2(N)][N-1];
  
endmodule