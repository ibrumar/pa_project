module flip_flop_tb();
wire q;
reg d;
reg clock, reset, enable;

initial begin
  
  clock=1;
  d=0;
  reset=0;
  enable=1;  
  
  #10 reset=1;
  #15
  d=1;
  //we should read 1
  #15
  d=0;
  enable=0;
  
  /* OLD TEST
  clock=1;
  reset=1;
  enable=0;
  #5 reset=0;
  #5 enable=1;
  #10 d=1'h1;
  #10 d=1'h0;
  #10 d=1'h1;
  #10 d=1'h0;
  #5 enable=0;
  #10 d=1'h1;
  #10 d=1'h0;
  #10 d=1'h1;
  #10 d=1'h0;

  #100 enable=0;*/
  
end

always begin
  #5 clock=~clock;
end

flip_flop my_flip_flop(
.clk(clock),
.enable(enable),
.q(q),
.d(d)
);

endmodule

