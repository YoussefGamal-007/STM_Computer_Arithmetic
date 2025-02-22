///////////////////////////////////////////////////////////////////////////////
// File Name      : ladner_fischer_generic.v
// Author         : Youssef Gamal Eldein
// Date           : 1/2/2025
// Description    : Generic implementation of a Ladner-Fischer adder.
//                  This module implements a parallel prefix adder using the
//                  Kogge-Stone architecture. It supports any bit-width (N)
//                  that is a power of 2.
// Assumptions    : 1) Cin = 0 to ease the implementation of the algorithm
//                  2) all squares in the architecture are the black ones
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module ladner_fischer_generic(a, b, cout, sum); // Implementation of a Ladner Fischer adder
  
  parameter N = 64; // Parameter defining the width of the adder (default is 64 bits)
  
  input [N-1:0] a, b; // Input operands for addition
  output cout; // Carry out from the most significant bit
  output [N-1:0] sum; // Sum output
  
  wire cin; // Internal carry in signal
  assign cin = 0; // Initialize carry in to zero
  
  // Memory arrays for generating carry and propagate signals
  reg [N-1:0] g_mem [0:$clog2(N)+1]; // Generate signal memory
  reg [N-1:0] p_mem [0:$clog2(N)+1]; // Propagate signal memory
  
  integer stage, i, j, k; // Loop variables for stages and iterations

  always @(*) begin 
    // Initial computation of generate and propagate signals for stage 0
    g_mem[0] = a & b; // Generate signals: G[i] = A[i] AND B[i]
    p_mem[0] = a ^ b; // Propagate signals: P[i] = A[i] XOR B[i]
    
    // Loop through stages to compute generate and propagate signals
    for (stage = 0; stage < $clog2(N) + 1; stage = stage + 1) begin 
      
      g_mem[stage + 1] = g_mem[stage]; // Copy previous generate signals
      p_mem[stage + 1] = p_mem[stage]; // Copy previous propagate signals
      
      if (stage == 0 || stage == 1) begin // Brent-Kung upper half algorithm 
        for (i = (2**stage - 1); i < N; i = i + (2**(stage + 1))) begin : upper_half 
          // Compute generate and propagate for upper half
          g_mem[stage + 1][i + (1 << stage)] = g_mem[stage][i + (1 << stage)] | 
            (g_mem[stage][i] & p_mem[stage][i + (1 << stage)]);
          p_mem[stage + 1][i + (1 << stage)] = p_mem[stage][i] & p_mem[stage][i + (1 << stage)];
        end 
      end 
      
      if (stage >= 2 && stage <= $clog2(N) - 1) begin // Sklansky algorithm
        for (k = 0; k < N / 4; k = k + 1) begin // Number of carry operators in each line
          for (i = (2**stage - 1); i < N; i = i + (2**(stage + 1))) begin 
            for (j = 0; j < 2**(stage - 1); j = j + 1) begin // Number of repetitions of first operand
              g_mem[stage + 1][i + 2 + 2 * j] = g_mem[stage][i + 2 + 2 * j] | 
                (g_mem[stage][i] & p_mem[stage][i + 2 + 2 * j]);
              p_mem[stage + 1][i + 2 + 2 * j] = p_mem[stage][i] & p_mem[stage][i + 2 + 2 * j];
            end 
          end
        end
      end 
     
      if (stage == $clog2(N)) begin // Brent-Kung lower half algorithm
        for (k = (2**0); k < N - 1; k = k + (2**(0 + 1))) begin : lower_half 
          // Compute generate and propagate for lower half
          g_mem[stage + 1][k + (1 << 0)] = g_mem[stage][k + (1 << 0)] | 
            (g_mem[stage][k] & p_mem[stage][k + (1 << 0)]);
          p_mem[stage + 1][k + (1 << 0)] = p_mem[stage][k] & p_mem[stage][k + (1 << 0)];
        end 
      end 
      
    end 
  end 
  
  // Calculate the final sum and carry out using the last generate and propagate signals
  assign sum = p_mem[0] ^ {g_mem[$clog2(N) + 1][N-2:0], cin}; // Final sum calculation
  assign cout = g_mem[$clog2(N) + 1][N-1]; // Final carry out assignment

endmodule