module mux4_tb();
reg clk;
reg [15:0]a;
reg [15:0]b;
reg [15:0]c;
reg [15:0]d;
reg [3:0] sel;
wire [15:0]out;

initial begin
  clk=1;
  #10 a= 16'hAA_AA;
  b= 16'hBB_BB;
  c= 16'hCC_CC;
  d= 16'hDD_DD;
    
  #10 sel= 4'h0;
  #10 sel= 4'h1;
  #10 sel= 4'h2;
  #10 sel= 4'h3;  
end

always begin
  #5 clk=~clk;
end

mux4 my_mux4(
.a(a),
.b(b),
.c(c),
.d(d),
.sel(sel),
.out(out)
);

endmodule

