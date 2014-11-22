module register_tb();
wire [15:0]q;
reg [15:0]d;
reg clock, reset, enable;

initial begin
  clock=1;
  enable=0;
  reset=0;
  d=16'h0;
  #10 reset=1;
  #10 d=16'hAA_AA;
  #5 enable=1;
  #10 enable=0;
  d=16'hBB_BB;
  #5 enable=1;
  #10 enable=0;
  d=16'hCC_CC;
  #5 enable=1;
  #10 enable=0;
  d=16'hDD_DD;
  #5 enable=1;
  #10 enable=0;
  #10 d=16'hAA_AA;
  #10 d=16'hBB_BB;
  #10 d=16'hCC_CC;
  #10 d=16'hDD_DD;

  #100 enable=0;
  
end

always begin
  #5 clock=~clock;
end

register #(16) my_register(
.clk(clock),
.enable(enable),
.q(q),
.d(d),
.reset(reset)
);

endmodule

