`timescale 1ns / 1ps

module carry_ripple_generic(a,b,cout,sum);  // carry ripple adder
  
  parameter N = 64;
  
  input [N-1:0] a , b;
  output cout;
  output [N-1:0] sum ;
  
  wire cin;
  assign cin = 0;
  
  reg [N-1:0] g_mem [0:N-1];
  reg [N-1:0] p_mem [0:N-1];
  
  
  integer stage ;
  always@(*) begin 
    g_mem[0] = a & b;
    p_mem[0] = a ^ b;
    
    for(stage = 0; stage < N-1; stage = stage + 1) begin 
      
      g_mem[stage + 1] = g_mem[stage];
      p_mem[stage + 1] = p_mem[stage];
        
      g_mem[stage + 1][stage + 1] = g_mem[stage][stage + 1] | (g_mem[stage][stage] & p_mem[stage][stage + 1]);
    //  p_mem[stage + 1][i+(2**stage)] = p_mem[stage][i] & p_mem[stage][i+(2**stage)];
        
    end 
  end 
  
  assign sum = p_mem[0] ^ {g_mem[N-1][N-2:0],cin};
  assign cout = g_mem[N-1][N-1];
endmodule 