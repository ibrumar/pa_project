module proc_tb();
  
  reg clk;
  reg reset;
  reg enable_pc_external;
  reg test;

     
initial begin
  clk<=1;
  reset<=0;
  enable_pc_external<=1; 
  
  #20 reset<=1;
  //#60 enable_pc_external<=0; 
  
end

always begin
  test <=0;
  #5 clk=~clk;
  if(reset==1)
    test<=1;
end


proc my_proc(
  .clk(clk),
  .reset(reset),
  .enable_pc_external(enable_pc_external),
  .test(test)
);
  
endmodule


