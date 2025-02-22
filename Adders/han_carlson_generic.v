`timescale 1ns / 1ps

module han_carlson_generic(a,b,cout,sum); // brent-kung + kogge-stone
  
  parameter N = 64;
  
  input [N-1:0] a , b;
  output cout;
  output [N-1:0] sum ;
  
  wire cin;
  assign cin = 0;
  
  reg [N-1:0] g_mem [0:$clog2(N)+1];
  reg [N-1:0] p_mem [0:$clog2(N)+1];
  
  
  integer stage , i , j , k;
  always@(*) begin 
    g_mem[0] = a & b;
    p_mem[0] = a ^ b;
    
    for(stage = 0; stage < $clog2(N)+1; stage = stage + 1) begin 
      
      g_mem[stage + 1] = g_mem[stage];
      p_mem[stage + 1] = p_mem[stage];
      
      if(stage == 0) begin 	// brent kung upper half algorithm
        for(i = (2**stage -1); i < N ; i = i + (2**(stage+1))) begin : upper_half 
          
          g_mem[stage+1][i+(1 << stage)] = g_mem[stage][i+(1 << stage)] | (g_mem[stage][i] &  p_mem[stage][i+(1 << stage)]);
          p_mem[stage+1][i+(1 << stage)] = p_mem[stage][i] & p_mem[stage][i+(1 << stage)];
        
      	end 
      end 
      
      
      if(stage >= 1 && stage <= $clog2(N)-1) begin	// kogge stone algorithm
        for(j = 1; j < (N - 2**stage) ; j = j + 2) begin 

          g_mem[stage + 1][j+(2**stage)] = g_mem[stage][j+(2**stage)] | (g_mem[stage][j] & p_mem[stage][j+(2**stage)]);
          p_mem[stage + 1][j+(2**stage)] = p_mem[stage][j] & p_mem[stage][j+(2**stage)];

        end 
      end 
      
      if(stage == $clog2(N)) begin // brent kung lower half algorithm
        //stage = 0;
        for(k = (2**0); k < N-1 ; k = k + (2**(0+1))) begin : lower_half 
          
          g_mem[stage+1][k+(1 << 0)] = g_mem[stage][k+(1 << 0)] | (g_mem[stage][k] &  p_mem[stage][k+(1 << 0)]);
          p_mem[stage+1][k+(1 << 0)] = p_mem[stage][k] & p_mem[stage][k+(1 << 0)];
        
      	end 
        //stage = $clog2(N);
      end 
      
    end 
  end 
  
  assign sum = p_mem[0] ^ {g_mem[$clog2(N)+1][N-2:0],cin};
  assign cout = g_mem[$clog2(N)+1][N-1];
endmodule 