module proc_tb();
  
  reg clk;
  reg reset;

     
initial begin
  clk<=1;
  reset<=0;
 
  #10 reset<=1; 
  
end

always begin
  #5 clk=~clk;
end


proc my_proc(
  .clk(clk),
  .reset(reset)
);
  
endmodule


