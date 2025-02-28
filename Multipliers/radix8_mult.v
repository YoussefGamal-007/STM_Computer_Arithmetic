	
module radix8_mult (clk , rst , a , x , p , done);
  
  parameter N = 32; 									// operands width 
  parameter RADIX = 8; 								// multiplier radix
  parameter EXTEND = $clog2(RADIX);					// extended width of registers
  //parameter DONE_CYCLE = $ceil(1.0 * N/EXTEND);
  parameter DONE_CYCLE = 11;
  //parameter LOWER = $rtoi(DONE_CYCLE)*EXTEND;
  
  input 								clk , rst;
  input signed 		[N-1:0] 			a; 			// mulitiplcand
  input signed   	[N-1:0] 			x;			// multiplier
  output signed  	[2*N-1:0]			p; 			// product 
  output done;
  
  reg signed [N+EXTEND-1:0] sum_reg;
  reg signed [N+EXTEND-1:0] carry_reg;
  reg signed [N:0] x_reg;   						// additional 1 bit (context) {x,context}
  reg signed [N-1:0] a_reg;
  reg signed [2*N-1:0] final_product;
  reg [$clog2(N)-1:0] count;
  
  // Internal registers
 // reg [2:0] count;        // Counter for Radix-8 groups
  reg signed [N+EXTEND-1:0] a_ext;       // Sign-extended multiplicand (N + EXTEND bits)
  reg signed [N+EXTEND-1:0] a_neg;       // -a (2's complement of a)
  reg signed [N+EXTEND-1:0] a_2x;        // 2a
  reg signed [N+EXTEND-1:0] a_4x;        // 4a
  reg signed [N+EXTEND-1:0] a_neg2x;     // -2a
  reg signed [N+EXTEND-1:0] a_neg4x;     // -4a
  reg signed [N+EXTEND-1:0] a_3x;        // 3a
  reg signed [N+EXTEND-1:0] a_neg3x;     // -3a
  reg signed [N+EXTEND-1:0] partial_product;

  // Done signal
 // assign done = (count == 11); // 32 bits / 3 bits per group = 11 groups

  always @(*) begin
    a_ext = { {3{a_reg[N-1]}}, a_reg }; 	// Sign-extend to N + EXTEND bits 
    a_neg = ~a_ext + 1;         			// -a (2's complement)
    a_2x = a_ext << 1;          			// 2a
    a_4x = a_ext << 2;          			// 4a
    a_neg2x = a_neg << 1;       			// -2a
    a_neg4x = a_neg << 2;       			// -4a
    a_3x = a_2x + a_ext;        			// 3a
    a_neg3x = a_neg2x + a_neg;  			// -3a
  end

  // Generate partial product based on 3-bit multiplier group
  always @(*) begin
    case (x_reg[3:0])
      4'b0000: partial_product = 0;          // 0a
      4'b0001: partial_product = a_ext;      // +1a
      4'b0010: partial_product = a_ext;      // +1a
      4'b0011: partial_product = a_2x;       // +2a
      4'b0100: partial_product = a_2x;       // +2a
      4'b0101: partial_product = a_3x;       // +3a
      4'b0110: partial_product = a_3x;       // +3a
      4'b0111: partial_product = a_4x;       // +4a
      4'b1000: partial_product = a_neg4x;   // -4a
      4'b1001: partial_product = a_neg3x;   // -3a
      4'b1010: partial_product = a_neg3x;   // -3a
      4'b1011: partial_product = a_neg2x;   // -2a
      4'b1100: partial_product = a_neg2x;   // -2a
      4'b1101: partial_product = a_neg;     // -1a
      4'b1110: partial_product = a_neg;     // -1a
      4'b1111: partial_product = 0;         // 0a
    endcase
  end

  wire [N+EXTEND-1:0] sum_csa;
  wire [N+EXTEND-1:0] carry_csa;
  
  csa #(.N(N+EXTEND)) CSA (sum_reg, carry_reg, partial_product, sum_csa, carry_csa);
  
  wire [EXTEND-1:0] op1 , op2;
  wire cout;
  reg cout_reg;
  wire [EXTEND-1:0] add_out;
  
  assign op1 = sum_csa[EXTEND-1:0];
  assign op2 = carry_csa[EXTEND-1:0];
  assign {cout,add_out} = op1 + op2 + cout_reg;
  
  always@(posedge clk or posedge rst) begin
    if(rst)
      cout_reg <=0;
    else
      cout_reg <= cout;
  end 
  
  always@(posedge clk or posedge rst) begin 
    if(rst) begin
      sum_reg <= 0;
      carry_reg <= 0;
      x_reg <= {x,1'b0};
      a_reg <= a;
      count <= 0;
    
    end else begin 
      sum_reg <= { {3{sum_csa[N+EXTEND-1]}}, sum_csa[N+EXTEND-1:3] };
      carry_reg <= { {3{carry_csa[N+EXTEND-1]}}, carry_csa[N+EXTEND-1:3] };
      x_reg <= x_reg >>> $clog2(RADIX);
      count <= count + 1;
    end 
  end 
  
  always@(posedge clk or posedge rst) begin
    if(rst)
      final_product <=0;
    else begin
        if (count == 0)
            final_product[2:0] <= add_out;         // count = 0: bits 2:0
        else if (count == 1)
            final_product[5:3] <= add_out;         // count = 1: bits 5:3
        else if (count == 2)
            final_product[8:6] <= add_out;         // count = 2: bits 8:6
        else if (count == 3)
            final_product[11:9] <= add_out;        // count = 3: bits 11:9
        else if (count == 4)
            final_product[14:12] <= add_out;       // count = 4: bits 14:12
        else if (count == 5)
            final_product[17:15] <= add_out;       // count = 5: bits 17:15
        else if (count == 6)
            final_product[20:18] <= add_out;       // count = 6: bits 20:18
        else if (count == 7)
            final_product[23:21] <= add_out;       // count = 7: bits 23:21
        else if (count == 8)
            final_product[26:24] <= add_out;       // count = 8: bits 26:24
        else if (count == 9)
            final_product[29:27] <= add_out;       // count = 9: bits 29:27
        else if (count == 10)
            final_product[32:30] <= add_out;       // count = 10: bits 32:30
        else
            final_product <= final_product;        // No change for other values
    end
 end
  
  wire [N+EXTEND:0] add_cpa;
  assign add_cpa = sum_reg + carry_reg + cout_reg;
  assign p = {add_cpa , final_product[(DONE_CYCLE)*EXTEND -1:0]};
  assign done = count == DONE_CYCLE;
    
endmodule 