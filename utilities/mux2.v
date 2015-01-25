module mux2 #(parameter WIDTH=16)(
  input [WIDTH-1:0] a,
  input [WIDTH-1:0] b,
  input sel,
  output reg   [WIDTH-1:0] out);
  
  always @(*)
  begin
    case(sel)
      1'b0 : out=a;
      1'b1 : out=b;
      default : out= 16'hxxxx;
    endcase
  end
  
endmodule
  
  
