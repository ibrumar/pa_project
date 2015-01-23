module wb_stage(
  
  input       clk,
  input       enable_wb,
  input       reset,
  
  //forward inputs
  input[15:0] cache_result,
  input[2:0]  destReg_addr_input,
  input       we_input,
  input [1:0] bp_input,
  input       word_access_from_cache,
  
  input       word_access,
  output[15:0]wb_result,
  output[2:0] destReg_addr_output,
  output      we_output,
  output [1:0]bp_output

  );
  
  register #(23) tlblookup_register(
    .clk(clk),
    .enable(enable_wb),
    .reset(reset),
    .d({cache_result, destReg_addr_input, we_input, bp_input, word_access_from_cache}),
    .q({wb_result, destReg_addr_output, we_output, bp_output, word_access})
  );

endmodule
