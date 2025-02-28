module right_shift_mult (clk , rst , a , x , p , done);
  
  parameter N = 32;
   
  input 			clk , rst;
  input 	[N-1:0] 			a; 	// mulitiplcand
  input  	[N-1:0] 			x;	// multiplier
  output 	[2*N-1:0]			p; 	// product 
  
  reg signed [2*N-1:0] partial_reg;
  reg signed [N:0] x_reg;
  reg signed [N:0] a_reg;
  reg [$clog2(N):0] count;
  
  wire cout;
  output done;
  wire [N:0] sum;
  reg [N:0] temp;
  wire enable;
  wire select;
  wire cin;
  reg sign;
  reg last_bit;
  
  always@(*) begin 
    if(x_reg[1:0] == 0 || x_reg[1:0] == 3)
      temp = 0;
    else if(x_reg[1:0] == 1)
      temp = a_reg;
    else 
      temp = ~a_reg + 1;
  end 
  
  
//   assign enable = x_reg[0];
//   assign select = cin;
//   assign cin = (count == 4) && enable;
  
  
  
  assign {cout,sum} = partial_reg[2*N-1:N-1] + temp;
  
  always@(posedge clk or posedge rst) begin
    if(rst) begin
      x_reg <= {x,1'b0};  // extra bit for booth 
      a_reg <= {a[N-1],a};
      partial_reg <= 0;
      count <= 0;
      last_bit <= 0;
    
    end else begin
      partial_reg <= {sum[N] , sum , partial_reg[N-2:1]};
      last_bit <= count == N-1 ? partial_reg[0] : last_bit;
      x_reg <= x_reg >> 1;
      count <= count + 1;
    end 
  end 
  
  assign done = (count == N);
  assign p = {partial_reg[2*N-2:0],last_bit};
endmodule