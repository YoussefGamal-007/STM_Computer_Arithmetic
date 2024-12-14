`timescale 1ns / 1ps

module cla_64bit_adder(
  input  [63:0] x , y,
  input 		cin,
  output        cout,
  output [63:0] sum,
  output 		G_63to0,
  output 		P_63to0
);
  wire P_15to0 , P_31to16 , P_47to32 ,P_63to48;
  wire G_15to0 , G_31to16 , G_47to32, G_63to48;
  wire c16,c32,c48;
  
  cla_16bit_adder INST1(.x(x[15:0]), 
                        .y(y[15:0]),
                        .cin(cin),
                      //  .cout(),  // cin for next block
                        .sum(sum[15:0]),
                        .G_15to0(G_15to0),
                        .P_15to0(P_15to0)
                 		);
  
  cla_16bit_adder INST2(.x(x[31:16]), 
                        .y(y[31:16]),
                        .cin(c16),
                      //  .cout(),  // cin for next block
                        .sum(sum[31:16]),
                        .G_15to0(G_31to16),
                        .P_15to0(P_31to16)
                 		);
  
  cla_16bit_adder INST3(.x(x[47:32]), 
                        .y(y[47:32]),
                        .cin(c32),
                      //  .cout(),  // cin for next block
                        .sum(sum[47:32]),
                        .G_15to0(G_47to32),
                        .P_15to0(P_47to32)
                 		);
  
  cla_16bit_adder INST4(.x(x[63:48]), 
                        .y(y[63:48]),
                        .cin(c48),
                      //  .cout(),  // cin for next block
                        .sum(sum[63:48]),
                        .G_15to0(G_63to48),
                        .P_15to0(P_63to48)
                 		);
  
  cla_4bit_network INST5 (.g({G_63to48,G_47to32,G_31to16,G_15to0}),
                          .p({P_63to48,P_47to32,P_31to16,P_15to0}),
                          .cin(cin),
                          .c({c48,c32,c16}),
                          .G(G_63to0),
                          .P(P_63to0)
                         );
  
  assign cout = G_63to0 | (P_63to0 & cin);
 
endmodule
