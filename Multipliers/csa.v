module csa #(
    parameter N = 32  // Default width is 32 bits
) (
    input  [N-1:0] a, b, c, // Input operands
    output [N-1:0] sum,     // Sum output
    output [N-1:0] carry    // Carry output
);
	
    // Sum is the XOR of all inputs
    assign sum = a ^ b ^ c;

    // Carry is the majority function (OR of AND pairs)
  	// Shifted left by 1
  assign carry = {(a & b) | (b & c) | (c & a), 1'b0};

endmodule