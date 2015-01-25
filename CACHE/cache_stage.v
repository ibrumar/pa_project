module cache_stage(
  
  input       clk,
  input       enable_cache,
  input       reset,
  input[15:0] dataReg,
  input[1:0]  ldSt_enable,
  
  //forward inputs
  input[15:0]tlb_result,
  input[2:0] destReg_addr_input,
  input      we_input,
  input [1:0] bp_input,
  input [2:0] tail_rob_input,
  input [15:0]pc_input,
  input [1:0] ex_vector_input,
  input ticketWE_input,
  
  output[15:0]cache_result,
  output[2:0] destReg_addr_output,
  output     we_output,
  output [1:0] bp_output,
  output [2:0] tail_rob_output,
  output [15:0]pc_output,
  output [1:0] ex_vector_output,
  output ticketWE_output
  
  );
  
  wire[15:0] dataReg_output;
  wire[1:0]  ldSt_enable_output;

  register #(62) cache_register(
    .clk(clk),
    .enable(enable_cache),
    .reset(reset),
    .d({tlb_result, destReg_addr_input, we_input, bp_input, dataReg,
      ldSt_enable, tail_rob_input, pc_input, 
      ex_vector_input, ticketWE_input}),
    .q({cache_result, destReg_addr_output, we_output, bp_output,
      dataReg_output, ldSt_enable_output, tail_rob_output, pc_output,
      ex_vector_output, ticketWE_output})
  );
  
 
  

endmodule
