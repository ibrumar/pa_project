module mux4(
  input [15:0] a,
  input [15:0] b,
  input [15:0] c,
  input [15:0] d,
  input [3:0] sel,
  output reg   [15:0] out);
  
  always @(*)
  begin
    case(sel)
      2'd0 : out=a;
      2'd1 : out=b;
      2'd2 : out=c;
      2'd3 : out=d;
      default : out= 16'hx;
    endcase
  end
  
endmodule
  
  