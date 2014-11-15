module register#(parameter WIDTH = 16)
(
  input clk,
  input [WIDTH-1:0] d,
  input enable,
  output [WIDTH-1:0] q
);


generate
for(i=0; i<WIDTH; i=i+1) 
  begin:flipgen
    flip_flop my_flip_flop(.clk(clock), .d(d[i]), .enable(enable), .reset(reset), .q(q[i]));
  end
endgenerate

endmodule