`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2024 06:34:06 PM
// Design Name: 
// Module Name: brent_kung_generic
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module brent_kung_generic (a , b , cout , sum);
  
  parameter N =64;

  input [N-1:0] a , b;
  output cout;
  output [N-1:0] sum;
  
  wire [N-1:0] g , p ;
  wire cin;
  reg [N-1:0] g_mem [0:2*$clog2(N)-1];
  reg [N-1:0] p_mem [0:2*$clog2(N)-1];
  
  assign cin = 0;
  assign g = a & b;
  assign p = a ^ b;
  
  integer stage , i , j , offset; 
  always@(a or b) begin
    
     g_mem[0] = g;
     p_mem[0] = p;
    
    for(stage = 0; stage < $clog2(N) ; stage = stage + 1) begin 
        g_mem[stage + 1] = g_mem[stage];
        p_mem[stage + 1] = p_mem[stage];
      
      for(i = (2**stage -1); i < N ; i = i + (2**(stage+1))) begin : upper_half 
        g_mem[stage+1][i+(1 << stage)] = g_mem[stage][i+(1 << stage)] | (g_mem[stage][i] &  p_mem[stage][i+(1 << stage)]);
        p_mem[stage+1][i+(1 << stage)] = p_mem[stage][i] & p_mem[stage][i+(1 << stage)];
        
      end 
    end 
    
    for(stage = $clog2(N)-2 ; stage >= 0 ; stage = stage - 1) begin 
        offset = $clog2(N) + $clog2(N/2**2);
        g_mem[offset-stage + 1] = g_mem[offset-stage];
        p_mem[offset-stage + 1] = p_mem[offset-stage];
      
      for(j = (2**(stage+1)-1); j < N-1 ; j = j + (2**(stage+1))) begin : lower_half
        g_mem[offset-stage+1][j+(1 << stage)] = g_mem[offset-stage][j+(1 << stage)] | (g_mem[offset-stage][j] &  p_mem[offset-stage][j+(1 << stage)]);
        p_mem[offset-stage+1][j+(1 << stage)] = p_mem[offset-stage][j] & p_mem[offset-stage][j+(1 << stage)];
        
      end 
    end 
  end 
  
  assign sum = p_mem[0] ^ {g_mem[2*$clog2(N)-1][N-2:0] , cin};
  assign cout = g_mem[2*$clog2(N)-1][N-1];

endmodule