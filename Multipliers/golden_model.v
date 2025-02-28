`timescale 1ns / 1ps

module golden_model #(
    parameter N = 32  // Parameter for N-bit inputs, default to 5 for the diagram
) (
    input  signed [N-1:0] a,  // Multiplicand
    input  signed [N-1:0] x,  // Multiplier
    output signed [2*N-1:0] p // Product (2N bits)
);

assign p = a*x;

endmodule
