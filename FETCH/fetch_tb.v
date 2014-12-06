module fetch_tb();
  reg [15:0]initial_instruction;
  reg [15:0]branch_instruction;
  reg [1:0]sel;
  
  reg clk;
  reg clk_mem;
  reg enable;
  reg reset;

  wire [7:0]instruction_code_high;
  wire [7:0]instruction_code_low;

     
initial begin
  clk=1;
  clk_mem=1;
  enable=0;
  reset=0;
  initial_instruction= 16'h00_0C;
  sel=2'b00; //starts with the initial instruction
 
  #10 reset=1; 
  #10 enable=1;
 
  
  #50  sel=2'b01; //change to next instruction

end

always begin
  #5 clk=~clk;
end

always begin
  #5 clk_mem= ~clk_mem;
end


fetch my_fetch(
  .initial_inst_addr(initial_instruction),
  .branch_pc(branch_instruction),
  .sel_pc(sel),
  .inst_code_high(instruction_code_high),
  .inst_code_low(instruction_code_low),
  .clk(clk),
  .enable_pc(enable),
  .reset(reset)
  );
  
endmodule

