module proc
     #(parameter cache_line_width = 256,
      parameter word_width = 16,
      //in the data cache we will access not only
      //data with width 'word_width'
      parameter addr_width = 16,
      parameter num_cache_lines = 4)

(
  input clk,
  input reset,
  input enable_pc_external,
  input test
);

//memory-oriented wires

   //arb,memory-instr-cache
wire                        serviceReadyArbCache;
wire [cache_line_width-1:0] dataMemCache;
wire [addr_width-1:0]       addrCacheArb;
   //memory-arb
wire                        serviceReadyMemArb;
wire                        petitionArbMem;
wire [addr_width-1:0]       addressArbMem;
wire                        petitionCacheArb;

//arb, memory, data-cache

wire [cache_line_width-1:0] dataCacheMem;
wire                        blockAluDecodeFetch;

//fetch-decode
wire [15:0] inst_code;

//decode-fetch
wire [1:0]  sel_pc;     
wire [15:0] branch_pc_addr;
//bypass block
wire enableFetchFromDecode;

//decode-alu
wire [15:0] regA;
wire [15:0] regB;
wire [3:0]  cop;
wire [15:0] dataRegALU;
wire [1:0]  ldSt_enableALU;
wire [2:0]  destReg_addrALU;
wire        writeEnableALU;
wire [8:0]  inmediate;
wire [1:0]  bp_ALU;
wire        clean_alu;
wire        wordAccessDECODE_ALU;

//alu-TLB
wire [15:0] dataRegTLB;
wire [1:0]  ldSt_enableTLB;
wire[15:0]  alu_resultTLB;
wire [2:0]  destReg_addrTLB;
wire        writeEnableTLB;
wire [1:0]  bp_TLB;
wire        wordAccessALU_TLB;

//TLB-CACHE

wire petitionFromTlb;

wire [1:0] lineIdFromTlb;
wire       writeEnableFromTlb;

wire [15:0] dataRegCACHE;
wire [1:0]  ldSt_enableCACHE;
wire[15:0]  tlb_resultCACHE;
wire [2:0]  destReg_addrCACHE;
wire        writeEnableCACHE;
wire [1:0]  bp_CACHE;
wire        wordAccessTLB_CACHE;
wire [15:0] offendingAddressTLB_CACHE;

//CACHE-WB
wire[15:0]  cache_resultWB;
wire [2:0]  destReg_addrWB;
wire        writeEnableWB;
wire [1:0]  bp_WB;
wire        wordAccessCACHE_WB;

//WB-DECODE
wire[15:0]  wb_resultDECODE;
wire [2:0]  destReg_addrDECODE;
wire        writeEnableDECODE;
wire [1:0]  bp_DECODE;
wire        wordAccessWB_DECODE;

//ARB-TLB
wire serviceReadyArbTlb;
wire petitionTlbArb;
wire [addr_width-1:0] addrTlbArb;
wire weTlbArb;

fetch my_fetch(
//common inputs
.clk(clk),                      
//blockAluDecodeFetch comes from TLB and means that a cache miss
//has happened -> therefore we must block -> enable = 0
//enableFetchFromDecode == 0 when some bypass cannot be satisfied to the decode
//stage
.enable_pc(enableFetchFromDecode & enable_pc_external & !blockAluDecodeFetch),
.reset(reset),                //Not necessary by this moment

//memory stuff

.serviceReadyArbCache(serviceReadyArbCache),
.dataMemCache(dataMemCache),
.addrCacheArb(addrCacheArb),
.petitionCacheArb(petitionCacheArb),
//fixed input
.initial_inst_addr(16'h020c),  //fixed initial instruction address

//input from DECODE
.sel_pc(sel_pc),               //select the d input of pc register
.branch_pc(branch_pc_addr),    // address to jump in a branch
    
//output to DECODE
.inst_code(inst_code)
);

//memory and arbiter accessed by fetch and tlblookup
arbiter my_arbiter
     (.addressInstr(addrCacheArb),
      .addressDat(addrTlbArb),
      .petitionInstr(petitionCacheArb),
      .petitionDat(petitionTlbArb),
      .serviceReady(serviceReadyMemArb),
      .serviceReadyInstr(serviceReadyArbCache),
      .serviceReadyDat(serviceReadyArbTlb),
      .petitionMem(petitionArbMem),
      .addressMem(addressArbMem)
      );



memory my_memory
     (.address(addressArbMem),
      .data_write(dataCacheMem),
      .clk(clk),
      .we(weTlbArb),
      .reset(reset),
      .petition(petitionArbMem),
      .serviceReady(serviceReadyMemArb),
      //output reg [data_width-1:0] data_read_high,
      .data_read(dataMemCache));

decode my_decode(
//common inputs
.clk(clk),   //the clock is the same for ev.
.reset(reset), //the reset is the same for everyone
.externalEnable(!blockAluDecodeFetch),

//inputs from FETCH
.instruction_code(inst_code),


//inputs from WB

.word_access_from_wb(wordAccessWB_DECODE),
.dWB(wb_resultDECODE),
.writeAddrWB(destReg_addrDECODE),
.writeEnableWB(writeEnableDECODE), //when write enable, write d into writeAddr


//output to fetch
.sel_pc(sel_pc),              //pc selection for fetch stage
.branch_pc(branch_pc_addr),        //where fetch should jump if branch done 
.enable_pc(enableFetchFromDecode),

//outputs to alu
.regA(regA),
.regB(regB),
.cop(cop),
.destReg_addr(destReg_addrALU),
.writeEnableALU(writeEnableALU),
.inmed(inmediate),
.bp_output(bp_ALU),
.clean_alu(clean_alu),
.dataReg(dataRegALU),
.ldSt_enable(ldSt_enableALU),
  
.wordAccess(wordAccessDECODE_ALU),

//inputs for BYPASS

//from ALU
.alu_result(alu_resultTLB),
.destReg_addrALU(destReg_addrTLB),
.bp_ALU(bp_TLB),

//from TLB
.tlblookup_result(tlb_resultCACHE),
.destReg_addrTLB(destReg_addrCACHE),
.bp_TLB(bp_CACHE),

//from CACHE
.cache_result(cache_resultWB),
.destReg_addrCACHE(destReg_addrWB),
.bp_CACHE(bp_WB),

//from WB
.wb_result(wb_resultDECODE),
.destReg_addrWB(destReg_addrDECODE),
.bp_WB(bp_DECODE)
);


alu_stage my_alu(
//inputs from DECODE
.regA(regA),
.regB(regB),
.cop(cop),
.destReg_addr(destReg_addrALU),
.we(writeEnableALU),
.inmediate(inmediate),
.word_access_from_decode(wordAccessDECODE_ALU),
.bp_input(bp_ALU),
.dataReg(dataRegALU),
.ldSt_enable(ldSt_enableALU),


//common inputs
.clk(clk),
.enable_alu(!blockAluDecodeFetch),
.reset(reset & ~clean_alu),

//outputs
.OVF(),                       //NOT CONNECTED
.alu_result(alu_resultTLB),
.destReg_addr_output(destReg_addrTLB),
.we_output(writeEnableTLB),
.bp_output(bp_TLB),
.dataReg_output(dataRegTLB),
.ldSt_enable_output(ldSt_enableTLB),
.word_access(wordAccessALU_TLB) 
);



tlblookup_stage my_tlb(
.clk(clk),
.enable_tlblookup(1'b1),
.reset(reset),

.blockPreviousStages(blockAluDecodeFetch),

//inputs
.alu_result(alu_resultTLB),
.destReg_addr_input(destReg_addrTLB),
.we_input(writeEnableTLB),
.bp_input(bp_TLB),
.dataReg(dataRegTLB),
.ldSt_enable(ldSt_enableTLB),
 
.word_access_from_alu(wordAccessALU_TLB),

//outputs
.tlblookup_result(tlb_resultCACHE),

.offendingAddress(offendingAddressTLB_CACHE), //for itlb and dtlb exceptions

.destReg_addr_output(destReg_addrCACHE),
.we_output(writeEnableCACHE),
.bp_output(bp_CACHE),
.dataReg_output(dataRegCACHE),
.ldSt_enable_output(ldSt_enableCACHE),

//this should be directly connected to cache stage
.petitionToData(petitionFromTlb),
.lineIdData(lineIdFromTlb),
.writeEnableData(writeEnableFromTlb),


//ARB-TLB
.serviceReadyArbTlb(serviceReadyArbTlb),
.petitionTlbArb(petitionTlbArb),
.addrTlbArb(addrTlbArb),
.weTlbArb(weTlbArb),

.wordAccess(wordAccessTLB_CACHE),

//from CACHE
.cache_result(cache_resultWB),
.destReg_addrCACHE(destReg_addrWB),
.bp_from_cache(bp_WB),
//from WB
.wb_result(wb_resultDECODE),
.destReg_addrWB(destReg_addrDECODE),
.bp_from_wb(bp_DECODE)

);

cache_stage my_cache(
//common inputs
.clk(clk),
.enable_cache(1'b1),
.reset(reset),

//communication with mem

.dataWrittenToMem(dataCacheMem),

.dataReadFromMem(dataMemCache),
//inputs
.tlb_result(tlb_resultCACHE),
.offendingAddress(offendingAddressTLB_CACHE), //for itlb and dtlb exceptions
.destReg_addr_input(destReg_addrCACHE),
.we_input(writeEnableCACHE),
.bp_input(bp_CACHE),
.dataReg(dataRegCACHE),
.ldSt_enable(ldSt_enableCACHE),

.petitionFromTlb(petitionFromTlb),
.lineIdFromTlb(lineIdFromTlb),
.writeEnableFromTlb(writeEnableFromTlb),


.word_access_from_tlb(wordAccessTLB_CACHE),
.word_access(wordAccessCACHE_WB),


//outputs
.cache_result(cache_resultWB),
.destReg_addr_output(destReg_addrWB),
.we_output(writeEnableWB),
.bp_output(bp_WB)
);

//WB
wb_stage my_wb(
.clk(clk),
.enable_wb(1'b1),
.reset(reset),
  
 //inputs
.cache_result(cache_resultWB),
.destReg_addr_input(destReg_addrWB),
.we_input(writeEnableWB),
.bp_input(bp_WB),
.word_access_from_cache(wordAccessCACHE_WB), 
  //outputs
.word_access(wordAccessWB_DECODE),
.wb_result(wb_resultDECODE),
.destReg_addr_output(destReg_addrDECODE),
.we_output(writeEnableDECODE),
.bp_output(bp_DECODE)
);

endmodule
