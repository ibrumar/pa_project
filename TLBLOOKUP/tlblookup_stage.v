module tlblookup_stage(
  
  input       clk,
  input       enable_tlblookup,
  input       reset,
  
  //forward inputs
  input[15:0] alu_result,
  input[15:0] dataReg,
  input[1:0]  ldSt_enable,
  input[2:0]  destReg_addr_input,
  input       we_input,
  input [1:0] bp_input,
  
  output[15:0]  tlblookup_result,
  output[2:0]   destReg_addr_output,
  output        we_output,
  output [1:0]  bp_output,
  output[15:0]  dataReg_output,
  output[1:0]   ldSt_enable_output,
  
  //BYPASSES
  //inputs from CACHE
  input[2:0]destReg_addrCACHE,
  input[15:0]cache_result,

  //inputs from WB
  input[2:0]destReg_addrWB,
  input[15:0]wb_result

  );
  wire [15:0]q_dataReg;
  reg [1:0]sel_bypass;
  
  mux4 mux_bypass(
  .a(q_dataReg),
  .b(cache_result),
  .c(wb_result),
  .d(16'hxxxx),
  .sel(sel_bypass),
  .out(dataReg_output)
  );

  register #(40) tlblookup_register(
    .clk(clk),
    .enable(enable_tlblookup),
    .reset(reset),
    .d({alu_result, destReg_addr_input, we_input, bp_input,
     dataReg, ldSt_enable}),
       
    .q({tlblookup_result, destReg_addr_output, we_output, bp_output,
        q_dataReg, ldSt_enable_output})
  );
  
  always @(*)
  begin
      //BYPASS
      case(ldSt_enable_output)
        //ST
        2'b01:
          if(destReg_addr_output == destReg_addrCACHE)
              sel_bypass<= 2'b01;
          else if(destReg_addr_output == destReg_addrWB)
                sel_bypass<= 2'b10;
          else
                sel_bypass<= 2'b00;
        
        default: sel_bypass<= 2'b00;
      endcase
  end

endmodule
