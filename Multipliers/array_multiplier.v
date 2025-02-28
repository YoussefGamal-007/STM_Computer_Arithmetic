// 32 signed array multiplier using Modified Baugh-Wooley
module array_multiplier #(
    parameter N = 32  // Parameter for N-bit inputs, default to 5 for the diagram
) (
    input  [N-1:0] a,  // Multiplicand
    input  [N-1:0] x,  // Multiplier
    output [2*N-1:0] p // Product (2N bits)
);

    // Internal wires for partial products and intermediate sums/carries
    wire [N-1:0] pp [0:N-1];  	// Partial products (N x N grid)
    wire [N-1:0] sum [0:N-1]; 	// Sum outputs from full-adders
  	wire [N-1:0] carry [0:N-1]; // Carry outputs (extra row for initial carry-in of 0)

    // Generate partial products (AND gates)
    genvar i, j;
    generate
        for (i = 0; i < N; i = i + 1) begin : gen_pp
            for (j = 0; j < N; j = j + 1) begin : gen_pp_bits
                if(j == N-1 ^ i == N-1)
                    assign pp[i][j] = !(a[i] & x[j]);
                else 
                    assign pp[i][j] = a[i] & x[j];
            end
        end
    endgenerate

    // Initialize carry[0] to 0 (no carry-in for the first row)
    //assign carry[0] = {N{1'b0}};

    // Array of full-adders to compute sums and carries
    generate
        for (i = 0; i < N; i = i + 1) begin : gen_rows
            for (j = 0; j < N; j = j + 1) begin : gen_cols
                if (i == 0) begin
                    // First row: add partial product with carry from previous column
                    full_adder fa (
                        .a(pp[i][j]),
                        .b(1'b0),
                        .cin(1'b0), // No carry-in from above in first row
                        .sum(sum[i][j]),
                        .cout(carry[i][j])
                    );
                end
                else if (i > 1 && j == N-1) begin
                    // First column: add partial product with sum from previous row
                    full_adder fa (
                        .a(pp[i][j]),
                        .b(carry[i-1][j]),
                        .cin(1'b0), // No carry-in from left in first column
                        .sum(sum[i][j]),
                        .cout(carry[i][j])
                    );
                end
                else begin
                    // General case: add partial product, sum from previous row, and carry from previous column
                    full_adder fa (
                        .a(pp[i][j]),
                        .b(sum[i-1][j+1]),
                        .cin(carry[i-1][j]),
                        .sum(sum[i][j]),
                        .cout(carry[i][j])
                    );
                end
            end
        end
    endgenerate

    // Form the final product
    // The bottom row (sum[N-1]) and rightmost column (carry) form the product
    assign p[0] = sum[0][0]; // Least significant bit
    generate
        for (i = 1; i < N; i = i + 1) begin : gen_product_lower
          assign p[i] = sum[i][0]; // Lower N bits from first row
        end
      for (i = 0; i < N-1; i = i + 1) begin : gen_product_upper
             full_adder fa (
                        .a(sum[N-1][i+1]),
                        .b(carry[N-1][i]),
                        .cin(c[i]),
            			.sum(p[N+i]),
            			.cout(c[i+1])
                     );
        end
    endgenerate
 	wire [N-1:0] c;
 	assign c[0] = 1'b1;
    assign p[2*N-1] = c[N-1] + 1;
                    
endmodule