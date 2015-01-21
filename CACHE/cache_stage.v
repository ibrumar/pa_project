module cache_stage(
  
  input       clk,
  input       enable_cache,
  input       reset,
  
  input[15:0] dataReg,  //contains the data to write in stores
  input[1:0]  ldSt_enable,
 
  //Inputs directly from TLBLOOKUP (don't use registers on those wires)
  input                  petitionFromTlb,

  input [num_cache_lines-1:0] lineIdFromTlb,
  output                  writeEnableFromTlb,

  //Communication with memory (managed by tlb stage)
  output [cache_line_width-1:0]  dataWrittenToMem,

  input [cache_line_width-1:0]  dataReadFromMem,


  //forward inputs
  input [15:0]tlb_result, //contains the address where the access is made
  input [2:0] destReg_addr_input,
  input      we_input,
  input [1:0] bp_input,
 
  //inputs that should not be passed throught stage's register.
  //they come form tlblookup

  output reg [15:0]cache_result,
  output[2:0] destReg_addr_output,
  output     we_output,
  output [1:0] bp_output
  
  );
  
  wire [15:0] dataReg_output;
  wire [15:0] dataAddr;
  wire [1:0]  ldSt_enable_output;
 
  wire is_load = ldSt_enable_output[0];
  wire is_store = ldSt_enable_output[1];
  wire is_mem_access = is_load || is_store;

  //cache outputs
  wire [word_width-1:0] byte0, //byte corresponding to loadw byte 0 or loadb
  wire [word_width-1:0] byte1, //byte corresponding to loadw byte 1

  register #(40) cache_register(
    .clk(clk),
    .enable(enable_cache),
    .reset(reset),
    .d({tlb_result, destReg_addr_input, we_input, bp_input, dataReg,
      ldSt_enable}),
    .q({dataAddr, destReg_addr_output, we_output, bp_output,
      dataReg_output, ldSt_enable_output})
  );
  
  always @(*) begin
    if (is_load) begin
      cache_result <= {byte1, byte0};
    end
    else begin
      cache_result <= dataAddr;
    end
  end

   data_cache 
   (
   .address(dataAddr),
   .clk(clk),
   .reset(reset),
   .petFromProc(is_mem_access),
   .dataToStore(dataReg_output),
   .accessIsStore(is_store),
   .isWordAccess(1'b0),

   //output to processor
   .byte0(byte0), 
   .byte1(byte1), 
                            
   //Eviction and memory write part
   //inputs directly from tlb stage
   .petitionFromTlbStage(petitionFromTlb),
   .lineIdFromTlbStage(lineIdFromTlb),
   .writeEnableTlbStage(writeEnableFromTlb),

   //output to memory
   .dataWrittenToMem(dataWrittenToMem),

   //input from memory
   .dataReadFromMem(dataReadFromMem)

);

  

endmodule
