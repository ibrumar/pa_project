module wb_stage(
  
  input       clk,
  input       enable_wb,
  input       reset,
  
  //forward inputs
  input[15:0] cache_result,
  input[2:0]  destReg_addr_input,
  input       we_input,
  input [1:0] bp_input,
  input [2:0]  tail_rob_input,
  input [15:0]  pc_input,
  input [1:0] ex_vector_input,
  input ticketWE_input,
  
  output[15:0]wb_result,
  output[2:0] destReg_addr_output,
  output      we_output,
  output [1:0]bp_output,
  output [2:0]  tail_rob_output,
  output [15:0]  pc_output,
  output [1:0] ex_vector_output,
  output ticketWE_output
  );
  
  register #(44) tlblookup_register(
    .clk(clk),
    .enable(enable_wb),
    .reset(reset),
    .d({cache_result, destReg_addr_input, we_input, bp_input,
      tail_rob_input, pc_input, ex_vector_input, ticketWE_input}),
    .q({wb_result, destReg_addr_output, we_output, bp_output,
      tail_rob_output, pc_output, ex_vector_output, ticketWE_output})
  );

endmodule
