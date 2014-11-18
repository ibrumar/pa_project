module adder_tb();
  reg [15:0]adder_in;
  wire [15:0]adder_out;

initial begin
  #10 adder_in= 16'h00_00;
  #10 adder_in= 16'h00_01;
  #10 adder_in= 16'h00_02;
  #10 adder_in= 16'h00_03;
  
  #20 $finish;
  
end

adder my_adder(
  .in(adder_in),
  .out(adder_out)
  );

endmodule

