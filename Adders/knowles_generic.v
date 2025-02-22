`timescale 1ns / 1ps

module knowles_generic(a,b,cout,sum);   // kogge stone + sklansky  ([2,1,1,1])
  
  parameter N = 64;
  
  input [N-1:0] a , b;
  output cout;
  output [N-1:0] sum ;
  
  wire cin;
  assign cin = 0;
  
  reg [N-1:0] g_mem [0:$clog2(N)];
  reg [N-1:0] p_mem [0:$clog2(N)];
  
  
  integer stage , i,j;
  always@(*) begin 
    g_mem[0] = a & b;
    p_mem[0] = a ^ b;
    
    for(stage = 0; stage < $clog2(N); stage = stage + 1) begin 
      
      g_mem[stage + 1] = g_mem[stage];
      p_mem[stage + 1] = p_mem[stage];
      
      
      if(stage >= 0 && stage <= $clog2(N)-1) begin   // normal kogge stone algorithm
        for(i = 0; i < (N - 2**stage) ; i = i + 1) begin 

          g_mem[stage + 1][i+(2**stage)] = g_mem[stage][i+(2**stage)] | (g_mem[stage][i] & p_mem[stage][i+(2**stage)]);
          p_mem[stage + 1][i+(2**stage)] = p_mem[stage][i] & p_mem[stage][i+(2**stage)];

        end 
      end 
      
      if(stage == $clog2(N)) begin   // kogge stone modified to be like sklansky in the final stage
        for(i = 1; i < (N - 2**stage) ; i = i + 2) begin 
          for(j = 0 ; j < 2 ; j = j + 1) begin // sklansky repeatition algorithm (always will be 2 to divide the no of routes to half)
            g_mem[stage + 1][i+(2**stage)-1+j] = g_mem[stage][i+(2**stage)-1+j] | (g_mem[stage][i] & p_mem[stage][i+(2**stage)-1+j]);
            p_mem[stage + 1][i+(2**stage)-1+j] = p_mem[stage][i] & p_mem[stage][i+(2**stage)-1+j];
          end 
        end 
      end 
      
    end 
  end 
  
  assign sum = p_mem[0] ^ {g_mem[$clog2(N)][N-2:0],cin};
  assign cout = g_mem[$clog2(N)][N-1];
endmodule 