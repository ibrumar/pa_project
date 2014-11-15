module flip_flop(input clk, d, enable, reset,
                 output reg q);
                 
always @(posedge clk)
begin
    if (reset == 0) begin
      q <= 0;  
    end
    
  else if (enable == 1) begin
      q <= d;
  end 
end
endmodule
  
