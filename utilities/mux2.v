module mux2(
  input [15:0] a,
  input [15:0] b,
  input sel,
  output reg   [15:0] out);
  
  always @(*)
  begin
    case(sel)
      1'b0 : out=a;
      1'b1 : out=b;
      default : out= 16'hx;
    endcase
  end
  
endmodule
  
  
