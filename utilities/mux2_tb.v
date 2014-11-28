module mux2_tb();
reg clk;
reg [15:0]a;
reg [15:0]b;
reg sel;
wire [15:0]out;

initial begin
  clk=1;
  #10 a= 16'hAA_AA;
  b= 16'hBB_BB;
    
  #10 sel= 1'b0;
  #10 sel= 1'b1;  
end

always begin
  #5 clk=~clk;
end

mux2 my_mux(
.a(a),
.b(b),
.sel(sel),
.out(out)
);

endmodule

