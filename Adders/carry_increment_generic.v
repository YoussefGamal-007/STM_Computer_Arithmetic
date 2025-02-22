`timescale 1ns / 1ps

module carry_increment_generic(a,b,cout,sum);  // carry increment adder
  
  parameter N = 64;
  parameter BLOCK_SIZE = 4;
  
  input [N-1:0] a , b;
  output cout;
  output [N-1:0] sum ;
  
  wire cin;
  assign cin = 0;
  
  reg [N-1:0] g_mem [0:3+(N/4 -1)];  // 3 fixed stages + N/4 -1 stages of 4 repeated squ.
  reg [N-1:0] p_mem [0:3+(N/4 -1)];
  
  
  integer stage , i, j;
  always@(*) begin 
    g_mem[0] = a & b;
    p_mem[0] = a ^ b;
    
    for(stage = 0; stage < 3+(N/4 -1); stage = stage + 1) begin 
      
      g_mem[stage + 1] = g_mem[stage];
      p_mem[stage + 1] = p_mem[stage];
      
      if(stage >= 0 && stage <= 2) begin // upper half algorithm
        for(i = stage; i < N ; i = i + 4) begin 

          g_mem[stage + 1][i+1] = g_mem[stage][i+1] | (g_mem[stage][i] & p_mem[stage][i+1]);
          p_mem[stage + 1][i+1] = p_mem[stage][i] & p_mem[stage][i+1];

        end 
      end 
      
      if(stage >= 3 && stage <= 3+(N/4 -2)) begin // lower half algorithm
        for(i = 3 + 4*(stage - 3) ; i < 4 + 4*(stage - 3) ; i = i + 1) begin 
          for(j = 0 ; j < BLOCK_SIZE ; j = j + 1) begin 
             
            g_mem[stage + 1][i+j+1] = g_mem[stage][i+j+1] | (g_mem[stage][i] & p_mem[stage][i+j+1]);
            p_mem[stage + 1][i+j+1] = p_mem[stage][i] & p_mem[stage][i+j+1];
             
           end 
        end 
      end 
      
    end 
  end 
  
  assign sum = p_mem[0] ^ {g_mem[3+(N/4 -1)][N-2:0],cin};
  assign cout = g_mem[3+(N/4 -1)][N-1];
endmodule 