module adder #(parameter INC=2)(
  input [15:0]in,
  output reg [15:0]out
  );

always @(*)
  begin
      out <= in+INC;
  end
  
endmodule
