module flip_flop_tb();
wire q;
reg d;
reg clock, reset, enable;

initial begin
  
  clock<=1;
  d<=0;
  reset<=0;
  enable<=1;  
  
  #10 reset<=1;
  d <= 1'b1;
  #15 d <= 1'b0;
  #15 d <= 1'b1;
  #10 d <= 1'b0;
  
end

always begin
  #5 clock=~clock;
end

flip_flop my_flip_flop(
.clk(clock),
.enable(enable),
.reset(reset),
.q(q),
.d(d)
);

endmodule

