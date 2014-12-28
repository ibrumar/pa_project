module proc(
  input clk,
  input reset
);

//fetch-decode
wire [7:0]  inst_code_high;
wire [7:0]  inst_code_low;
wire [15:0] inst_code;

//decode-fetch
wire [1:0]  sel_pc;     
wire [15:0] branch_pc_addr;

//decode-alu
wire [15:0] regA;
wire [15:0] regB;
wire [3:0]  cop;
wire [2:0]  destReg_addrALU;
wire        writeEnableALU;
wire [8:0]  inmediate;
wire [1:0]  bp_ALU;

//alu-TLB
wire[15:0]  alu_resultTLB;
wire [2:0]  destReg_addrTLB;
wire        writeEnableTLB;
wire [1:0]  bp_TLB;

//TLB-CACHE
wire[15:0]  tlb_resultCACHE;
wire [2:0]  destReg_addrCACHE;
wire        writeEnableCACHE;
wire [1:0]  bp_CACHE;

//CACHE-WB
wire[15:0]  cache_resultWB;
wire [2:0]  destReg_addrWB;
wire        writeEnableWB;
wire [1:0]  bp_WB;

//WB-DECODE
wire[15:0]  wb_resultDECODE;
wire [2:0]  destReg_addrDECODE;
wire        writeEnableDECODE;
wire [1:0]  bp_DECODE;


fetch my_fetch(
.initial_inst_addr(16'h000c),  //fixed initial instruction address
.sel_pc(sel_pc),               //select the d input of pc register
.branch_pc(branch_pc_addr),    // address to jump in a branch
    
.clk(clk),                      
.enable_pc(1'b1),
.reset(reset),                //Not necessary by this moment

.inst_code(inst_code)
);

assign inst_code_high = inst_code[15:8];
assign inst_code_low = inst_code[7:0];

decode my_decode(
.sel_pc(sel_pc),              //pc selection for fetch stage
.branch_pc(branch_pc_addr),        //where fetch should jump if branch done 
  
//alu outputs
.regA(regA),
.regB(regB),
.cop(cop),
.destReg_addr(destReg_addrALU),
.writeEnableALU(writeEnableALU),
.inmed(inmediate),
.bp_output(bp_ALU),
 
  //common inputs
.clk(clk),   //the clock is the same for ev.
.reset(reset), //the reset is the same for everyone
  
  //inputs from fetch
.instruction_code_high(inst_code_high),
.instruction_code_low(inst_code_low),
  
  //inputs from write_back
.dWB(wb_resultDECODE),
.writeAddrWB(destReg_addrDECODE),
.writeEnableWB(writeEnableDECODE), //when write enable, write d into writeAddr

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
.bp_input(bp_ALU),

//common inputs
.clk(clk),
.enable_alu(1'b1),
.reset(reset),

//outputs
.OVF(),                       //NOT CONNECTED
.alu_result(alu_resultTLB),
.destReg_addr_output(destReg_addrTLB),
.we_output(writeEnableTLB),
.bp_output(bp_TLB)

);


tlblookup_stage my_tlb(
.clk(clk),
.enable_tlblookup(1'b1),
.reset(reset),

//inputs
.alu_result(alu_resultTLB),
.destReg_addr_input(destReg_addrTLB),
.we_input(writeEnableTLB),
.bp_input(bp_TLB),
  
//outputs
.tlblookup_result(tlb_resultCACHE),
.destReg_addr_output(destReg_addrCACHE),
.we_output(writeEnableCACHE),
.bp_output(bp_CACHE)
);

cache_stage my_cache(
//common inputs
.clk(clk),
.enable_cache(1'b1),
.reset(reset),

//inputs
.tlb_result(tlb_resultCACHE),
.destReg_addr_input(destReg_addrCACHE),
.we_input(writeEnableCACHE),
.bp_input(bp_CACHE),

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
  
  //outputs
.wb_result(wb_resultDECODE),
.destReg_addr_output(destReg_addrDECODE),
.we_output(writeEnableDECODE),
.bp_output(bp_DECODE)
);

endmodule
