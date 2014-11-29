module register_file_tb();
wire [15:0]a;
wire [15:0]b;


reg [15:0]d;
reg clock, reset, writeEnable;
reg [2:0] writeAddr;
reg [2:0] ra;
reg [2:0] rb;


initial begin
  clock<=1;
  d<=4'h5;
  reset<=0;
  writeEnable<=1;  
  writeAddr<=1;
  ra <= 1;
  rb <= 8;
  
  
  #20 reset<=1;
  //we should read ra=1 and rb=8
  
  #20 
 // writeEnable<=0;
  d<=4'h1; 
  writeAddr<=8;
  ra <= 1;
  rb <= 8;
  //writing should't be allowed and in rb we should read 0
  
 // #20 writeEnable<=1;  

end

always begin
  #5 clock=~clock;
end


register_file #(16) my_register_file(
.clk(clock),
.ra(ra),
.rb(rb),
.d(d),
.writeAddr(writeAddr),
.writeEnable(writeEnable),
.reset(reset),
.a(a),
.b(b)
);

endmodule

