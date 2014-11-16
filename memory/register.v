module register#(parameter WIDTH = 16)
(
  input clk,
  input [WIDTH-1:0] d,
  input enable,
  input reset,
  output [WIDTH-1:0] q
  );


  genvar i;
  generate
    for (i=0; i< WIDTH; i=i+1)
      begin: gen_register
        flip_flop my_flip_flop(.clk(clk), .d(d[i]), .enable(enable), 
          .reset(reset), .q(q[i]));
      end
  endgenerate

endmodule