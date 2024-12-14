`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/14/2024 03:43:57 PM
// Design Name: 
// Module Name: ladner_fischer_generic
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
// Code your design here
module ladner_fischer_generic (a , b , cout , sum);
  
  parameter N = 64;

  input [N-1:0] a , b;
  output cout;
  output [N-1:0] sum;
  
  wire [N-1:0] g , p ;
  wire cin;
  reg [N-1:0] g_mem [0:$clog2(N)];
  reg [N-1:0] p_mem [0:$clog2(N)];
  
  assign cin = 0;
  assign g = a & b;
  assign p = a ^ b;
  
  integer stage , i , j ,k;
  always@(a or b) begin
    
     g_mem[0] = g;
     p_mem[0] = p;
    
    for(stage = 0; stage < $clog2(N) ; stage = stage + 1) begin 
        g_mem[stage + 1] = g_mem[stage];
        p_mem[stage + 1] = p_mem[stage];
      
      for(k = 0 ; k < N/2 ; k = k + 1) begin 
        for(i = (2**stage -1); i < N ; i = i + (2**(stage+1))) begin 
          for(j = 0 ; j < 2**stage ; j = j + 1) begin 
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