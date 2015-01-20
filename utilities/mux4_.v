module mux4_#(parameter WIDTH=16)(
  input [WIDTH-1:0] a,
  input [WIDTH-1:0] b,
  input [WIDTH-1:0] c,
  input [WIDTH-1:0] d,
  input [1:0] sel, 
  output reg   [WIDTH-1:0] out);
  
  always @(*)
  begin
    case(sel)
      2'b00 : out<=a;
      2'b01 : out<=b;
      2'b10 : out<=c;
      2'b11 : out<=d;
      default : out<= 16'hxxxx;
    endcase
  end
  
endmodule
  
  
