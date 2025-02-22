`timescale 1ns / 1ps

module sklansky_generic (a , b , cout , sum);
  
  //parameters
  parameter N = 64;

  //input & output ports
  input [N-1:0] a , b;
  output cout;
  output [N-1:0] sum;
  
  //internal signals
  wire [N-1:0] g , p ;
  wire cin;
  reg [N-1:0] g_mem [0:$clog2(N)];
  reg [N-1:0] p_mem [0:$clog2(N)];
  
  //functional code 
  assign cin = 0;
  assign g = a & b;
  assign p = a ^ b;
  
  integer stage , i , j ,k;		// loop iterators
  always@(a or b) begin
    
     g_mem[0] = g;
     p_mem[0] = p;
    
    for(stage = 0; stage < $clog2(N) ; stage = stage + 1) begin   // number of levels
        g_mem[stage + 1] = g_mem[stage];
        p_mem[stage + 1] = p_mem[stage];
      
      for(k = 0 ; k < N/2 ; k = k + 1) begin 					  // number of carry operators 
        for(i = (2**stage -1); i < N ; i = i + (2**(stage+1))) begin 
          for(j = 0 ; j < 2**stage ; j = j + 1) begin 				//number of repeatitions of first operand
            g_mem[stage + 1][i+1+j] = g_mem[stage][i+1+j] | (g_mem[stage][i] & p_mem[stage][i+1+j]);
            p_mem[stage + 1][i+1+j] = p_mem[stage][i] & p_mem[stage][i+1+j];
          end 
        end
      end 
    end 
  end 
  
  assign sum = p_mem[0] ^ {g_mem[$clog2(N)][N-2:0] , cin};
  assign cout = g_mem[$clog2(N)][N-1];
  
endmodule