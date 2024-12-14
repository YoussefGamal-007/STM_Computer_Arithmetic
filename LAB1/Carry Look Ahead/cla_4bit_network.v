`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: STMicroelectronics 
// Engineer: Youssef Gamal Eldein
// 
// Create Date: 12/09/2024 12:50:10 PM
// Module Name: cla_4bit_network
// Target Devices: VCU118
// Tool Versions: VIVADO 22.2 ML Standard
// Description: 4 bit carry look ahead generation unit for fast carry generation 
//              submitted for ST computer arithmetic training
//////////////////////////////////////////////////////////////////////////////////

module cla_4bit_network(
  
  // input & output ports
  input 	[3:0] 	g , p, 	 // gi and pi
  input 		  	cin,
  output 	[4:1] 	c,		 // internal carry signals
  output 		  	G , P	 // G and P for the whole block (G3:0 & P3:0)
  
);
  
  // functional code
  assign c[1] = g[0] | (p[0]&cin),
    	 c[2] = g[1] | (g[0]&p[1]) | (p[0]&p[1]&cin),
         c[3] = g[2] | (g[1]&p[2]) | (g[0]&p[1]&p[2]) | (p[0]&p[1]&p[2]&cin),
         c[4] = g[3] | (g[2]&p[3]) | (g[1]&p[2]&p[3]) | (g[0]&p[1]&p[2]&p[3])| (p[0]&p[1]&p[2]&p[3]&cin);
  
  assign G = g[3] | (g[2]&p[3]) | (g[1]&p[2]&p[3]) | (g[0]&p[1]&p[2]&p[3]);
  assign P = &p;
  
endmodule 
