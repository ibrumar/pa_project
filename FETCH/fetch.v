module fetch(
  input [15:0]initial_inst_addr,  //fixed initial instruction address
  input [1:0]sel_pc,              //select the d input of pc register
  input [15:0]branch_pc,          // address to jump in a branch
    
  input clk,
  input enable_pc,
  input reset,

  output[7:0]inst_code_high,  
  output[7:0]inst_code_low
  
);

  wire [15:0]mux_out__pc_in;
  wire [15:0]pc_out__mem_in;

  
mux4 my_mux(
  .a(initial_inst_addr), 
  .b(pc_out__mem_in+2'b10),
  .c(branch_pc),
  .d(16'h000),
  .sel(sel_pc),
  .out(mux_out__pc_in)
);

register my_pc(
  .clk(clk),
  .enable(enable_pc),
  .reset(1'b1),
  .d(mux_out__pc_in),
  .q(pc_out__mem_in)
);


memory my_memory(
  .address(pc_out__mem_in),
  .data_read_high(inst_code_high),
  .data_read_low(inst_code_low),
  .data_write_low(8'hxx),
  .data_write_high(8'hxx),
  .we(1'b0),
  .clk(clk)
);


endmodule

