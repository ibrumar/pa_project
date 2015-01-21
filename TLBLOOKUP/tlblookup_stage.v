module tlblookup_stage
  #(parameter cache_line_width = 256,
  parameter word_width = 16,
  parameter byte_width = 8,
  //in the data cache we will access not only
  //data with width 'word_width'
  parameter addr_width = 16,
  parameter num_cache_lines = 4)

  (
  input       clk,
  input       enable_tlblookup,
  input       reset,

  output      blockPreviousStages,

  //forward inputs
  input[15:0] alu_result,
  input[15:0] dataReg,
  input[1:0]  ldSt_enable,
  input[2:0]  destReg_addr_input,
  input       we_input,
  input [1:0] bp_input,
  
  //address where the access is made
  output[15:0]  tlblookup_result,
  output[2:0]   destReg_addr_output,
  output        we_output,
  output [1:0]  bp_output,
  output[15:0]  dataReg_output,
  output[1:0]   ldSt_enable_output,
  
  //Ouputs directly to CACHE (without register)
  output                  petitionToData,

  output [num_cache_lines-1:0] lineIdData,
  output                  writeEnableData,

  
  //TLB-ARB

  input serviceReadyArbTlb,
  output petitionTlbArb,
  output addrTlbArb,
  output weTlbArb,


  //BYPASSES
  //inputs from CACHE
  input[2:0]destReg_addrCACHE,
  input[15:0]cache_result,

  //inputs from WB
  input[2:0]destReg_addrWB,
  input[15:0]wb_result

  );

  wire we_output_aux;
  wire bp_output_aux;
  wire ldSt_enable_output_aux;
  wire enable_tlblookup_internal;

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


  wire is_load = ldSt_enable_output[0];
  wire is_store = ldSt_enable_output[1];
  wire is_mem_access = is_load || is_store;
  wire is_hit;

  assign weTlbArb = is_store;
  assign blockPreviousStages = !is_hit && is_mem_access;


  //for loads tlblookup_result is the address
  //and for stores is the also the address
  //q_dataReg is the written data in a store
  //destReg is the register to be modified in a load
  tags cache_tags
      (
  //inputs from processor
  .address(tlblookup_result),
  .clk(clk),
  .reset(reset),
  .petFromProc(is_mem_access),
  .wordPetition(0),
  .we(is_store),

  .memServiceReady(serviceReadyArbTlb),

  .isHit(is_hit), //only one isHit is maintained for both bytes
                                 
  //output to arbitrer
  .addrToArb(addrTlbArb),
  .petitionToArb(petitionTlbArb),
  //the processor will directly plug in the write petition to the memory if the operation in tlblookup is a store.

  .petitionToData(petitionToData),

  .lineIdData(lineIdData),
  .writeEnableData(writeEnableData)
  );


  register #(40) tlblookup_register(
  .clk(clk),
  .enable(enable_tlblookup_internal),
  .reset(reset),
  .d({alu_result, destReg_addr_input, we_input, bp_input,
   dataReg, ldSt_enable}),
     
  .q({tlblookup_result, destReg_addr_output, we_output_aux, bp_output_aux,
      q_dataReg, ldSt_enable_output_aux})
  );

  //Blocking current and previous stages
  //and sending nops to the following
  always @(*) begin
    if (blockPreviousStages) begin
      we_output <= 1'b0;
      bp_output <= 2'b00;
      ldSt_enable_output <= 2'b00;
      enable_tlblookup_internal <= 1'b0;
    end
    else begin
      we_output <= we_output_aux;
      bp_output <= bp_output_aux;
      ldSt_enable_output <= ldSt_enable_output_aux;
      enable_tlblookup_internal <= enable_tlblookup;
    end
  end

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
