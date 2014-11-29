module fetch_tb();
  reg [15:0]initial_instruction;
  reg [3:0]sel;
  
  reg clk;
  reg clk_mem;
  reg enable;
  reg reset;

  wire [7:0]instruction_code_high;
  wire [7:0]instruction_code_low;

  //wire [15:0]out_mux;//debug
  //wire [15:0]in_mux_b;//debug
  //wire [15:0]out_reg;//debug
     
initial begin
  clk=1;
  clk_mem=1;
  enable=0;
  reset=0;
  initial_instruction= 16'h00_0C;
  sel=4'h0; //starts with the initial instruction
 
  #10 reset=1; 
  #10 enable=1;
 
  
  #50  sel=4'h1; //change to next instruction

end

always begin
  #5 clk=~clk;
end

always begin
  #5 clk_mem= ~clk_mem;
end


fetch my_fetch(
  .initial_instruction(initial_instruction),
  .sel(sel),
  .instruction_code_high(instruction_code_high),
  .instruction_code_low(instruction_code_low),
  .clk_mem(clk_mem),  
  .clk(clk),
  .enable(enable),
  .reset(reset)
  //.out_mux(out_mux),//debug
  //.in_mux_b(in_mux_b),//debug
  //.out_reg(out_reg)//debug
  );
  
endmodule

