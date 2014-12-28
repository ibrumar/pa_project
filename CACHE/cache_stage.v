module cache_stage(
  
  input       clk,
  input       enable_cache,
  input       reset,
  
  //forward inputs
  input[15:0]tlb_result,
  input[2:0] destReg_addr_input,
  input      we_input,
  input [1:0] bp_input,
  
  output[15:0]cache_result,
  output[2:0] destReg_addr_output,
  output     we_output,
  output [1:0] bp_output
  );
  

  register #(22) cache_register(
    .clk(clk),
    .enable(enable_cache),
    .reset(reset),
    .d({tlb_result, destReg_addr_input, we_input, bp_input}),
    .q({cache_result, destReg_addr_output, we_output, bp_output})
  );
  
  

endmodule
