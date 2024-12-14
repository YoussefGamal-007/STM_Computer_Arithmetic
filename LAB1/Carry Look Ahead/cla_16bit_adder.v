`timescale 1ns / 1ps
// Code your testbench here
module cla_16bit_adder(
  input 	[15:0]	 x , y,
  input				 cin,
  //output 			 cout,
  output 	[15:0]	 sum,
  output 			 G_15to0,
  output             P_15to0
);
  
  //internal signals
  wire [15:0] g,p;
  wire [16:0] c;   			//internal carry signals
  wire [4:1]  G;			// combined generate for the 4 bit block
  wire [4:1]  P;			// combined propagate for the 4 bit block
  
  assign c[0] = cin;
  assign cout = c[16];
  
  //g & p generation 
  genvar j;
  generate 
    for(j = 0; j<16 ; j = j + 1) begin
      assign g[j] = x[j] & y[j];
      assign p[j] = x[j] ^ y[j];
    end 
  endgenerate
  
  //CLA 16 bit carry generation UNIT
  cla_4bit_network INST1 (.g(g[3:0]),
                          .p(p[3:0]),
                          .cin(c[0]),
                          .c(c[3:1]),
                          .G(G[1]),
                          .P(P[1])
                         );
  
  cla_4bit_network INST2 (.g(g[7:4]),
                          .p(p[7:4]),
                          .cin(c[4]),
                          .c(c[7:5]),
                          .G(G[2]),
                          .P(P[2])
                         );
  
  cla_4bit_network INST3 (.g(g[11:8]),
                          .p(p[11:8]),
                          .cin(c[8]),
                          .c(c[11:9]),
                          .G(G[3]),
                          .P(P[3])
                         );
  
  cla_4bit_network INST4 (.g(g[15:12]),
                          .p(p[15:12]),
                          .cin(c[12]),
                          .c(c[15:13]),
                          .G(G[4]),
                          .P(P[4])
                         );
  
  // assign G_15to0 = G[3] | (G[2]&P[3]) | (G[1]&P[2]&P[3]) | (G[0]&P[1]&P[2]&P[3]);
 // assign P_15to0 = &P;
  
  cla_4bit_network INST5 (.g(G),
                          .p(P),
                          .cin(c[0]),
                          .c({c[12],c[8],c[4]}),
                          .G(G_15to0),
                          .P(P_15to0)
                         );
  
  assign c[16] = G_15to0 | (P_15to0 & cin);
  
  //sum calculations
  genvar i;
  generate 
    for(i = 0; i<16 ; i = i + 1) begin
      assign sum[i] = p[i] ^ c[i];
    end
  endgenerate
endmodule
