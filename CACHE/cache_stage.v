module cache_stage
  #(parameter cache_line_width = 256,
  parameter word_width = 16,
  parameter byte_width = 8,
  //in the data cache we will access not only
  //data with width 'word_width'
  parameter addr_width = 16,
  parameter num_cache_lines = 4,
  parameter num_bytes_per_line = 32)
(
  
  input       clk,
  input       enable_cache,
  input       reset,
  
  input[15:0] dataReg,  //contains the data to write in stores
  input[1:0]  ldSt_enable,
 
  //Inputs directly from TLBLOOKUP (don't use registers on those wires)
  input                       petitionFromTlb,

  input [1:0] lineIdFromTlb,
  input                       writeEnableFromTlb,

  //Communication with memory (managed by tlb stage)
  output [cache_line_width-1:0]  dataWrittenToMem,
  input [cache_line_width-1:0]  dataReadFromMem,


  //forward inputs
  input [15:0]tlb_result, //contains the virtual address
  input[15:0]  offendingAddress,
  input [2:0] destReg_addr_input,
  input      we_input,
  input [1:0] bp_input,
  input       word_access_from_tlb,
  output reg [15:0]cache_result,
  output[2:0] destReg_addr_output,
  output     we_output,
  output [1:0] bp_output,
  output      word_access 
  );
  
  wire [15:0] dataReg_output;
  wire [15:0] dataAddr;
  wire [1:0]  ldSt_enable_output;
 
  wire is_load = ldSt_enable_output[1]; //if in tlb lookup you had a miss
  wire is_store = ldSt_enable_output[0];//you won't even notice that now
  wire is_mem_access = is_load || is_store; //a mem access instrucion is passing
                                            //throught the stage
  //cache outputs
  wire [byte_width-1:0] byte0; //byte corresponding to loadw byte 0 or loadb
  wire [byte_width-1:0] byte1; //byte corresponding to loadw byte 1

  wire[15:0]  q_offendingAddress;

  register #(57) cache_register(
    .clk(clk),
    .enable(enable_cache),
    .reset(reset),
    .d({tlb_result, destReg_addr_input, we_input, bp_input, dataReg,
      ldSt_enable, word_access_from_tlb,  offendingAddress}),
    .q({dataAddr, destReg_addr_output, we_output, bp_output,
      dataReg_output, ldSt_enable_output, word_access, q_offendingAddress})
  );
  
  always @(*) begin
    if (is_load) begin
      cache_result <= {byte1, byte0};
    end
    else begin
      cache_result <= dataAddr;
    end
  end

   data_cache my_data_cache 
   (
   .address(dataAddr),
   .clk(clk),
   .reset(reset),
   .petFromProc(is_mem_access),
   .dataToStore(dataReg_output),
   .accessIsStore(is_store),
   .isWordAccess(word_access),

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
