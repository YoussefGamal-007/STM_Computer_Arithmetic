`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/14/2024 03:57:16 PM
// Design Name: 
// Module Name: golden_model
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


module golden_model(a ,b , cout , sum);
    
    parameter N = 64;
    input [N-1:0] a , b;
    output cout;
    output [N-1:0] sum;
    
    assign {cout,sum} = a + b;
endmodule
