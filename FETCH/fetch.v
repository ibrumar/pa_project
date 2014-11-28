module fetch(
  input [15:0]initial_instruction,
  input [3:0]sel,
    
  input clk,
  input enable,
  input reset,

  input clk_mem,  
  output[7:0]instruction_code_high,
  output[7:0]instruction_code_low
  
  //output[15:0]out_mux,  //debugg
  //output[15:0]out_reg  //debugg     
  //output[15:0]in_mux_b,  //debugg

);

  wire [15:0]mux_out__reg_in;
  wire [15:0]reg_out___adder_in;
  wire [15:0]adder_out__mux_b_in;

  //assign out_mux= mux_out__reg_in;//debugg
  //assign out_reg= reg_out___adder_in; //debbug
  //assign in_mux_b= adder_out__mux_b_in; //debbug

  
mux4 my_mux(
.a(initial_instruction), //cambiar a i_I_address
.b(adder_out__mux_b_in),
.sel(sel),
.out(mux_out__reg_in)
);

register my_pc(
.clk(clk),
.enable(enable),
.reset(reset),
.d(mux_out__reg_in),
.q(reg_out___adder_in)
);

adder my_adder(
.in(reg_out___adder_in),
.out(adder_out__mux_b_in)

);

memory my_memory(
.address(reg_out___adder_in),
.data_read_high(instruction_code_high),
.data_read_low(instruction_code_low),
.clk(clk_mem)
);


endmodule

