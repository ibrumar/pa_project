module tlblookup_stage(
  
  input       clk,
  input       enable_tlblookup,
  input       reset,
  
  input[15:0]alu_result,
  input[2:0] destReg_addr_input,
  input      we_input,
  
  output[15:0]tlblookup_result,
  output[2:0] destReg_addr_output,
  output     we_output
  );
  

  register #(20) tlblookup_register(
    .clk(clk),
    .enable(enable_tlblookup),
    .reset(reset),
    .d({alu_result, destReg_addr_input, we_input}),
    .q({tlblookup_result, destReg_addr_output, we_output})
  );
  
  

endmodule
