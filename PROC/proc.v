module proc(
  input clk,
  input reset,
  input enable_pc_external,
  input test
);

//fetch-decode
wire [15:0] inst_code;

//decode-fetch
wire [1:0]  sel_pc;     
wire [15:0] branch_pc_addr;
//bypass block
wire block_pc;

//decode-ROB
wire tail_rob_increment_enable;

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

//ROB-ALU
wire [2:0] tail_robALU;

//alu-TLB
wire [15:0] dataRegTLB;
wire [1:0]  ldSt_enableTLB;
wire[15:0]  alu_resultTLB;
wire [2:0]  destReg_addrTLB;
wire        writeEnableTLB;
wire [1:0]  bp_TLB;
wire [2:0]  tail_robTLB;

//TLB-CACHE
wire [15:0] dataRegCACHE;
wire [1:0]  ldSt_enableCACHE;
wire[15:0]  tlb_resultCACHE;
wire [2:0]  destReg_addrCACHE;
wire        writeEnableCACHE;
wire [1:0]  bp_CACHE;
wire [2:0]  tail_robCACHE;

//CACHE-WB
wire[15:0]  cache_resultWB;
wire [2:0]  destReg_addrWB;
wire        writeEnableWB;
wire [1:0]  bp_WB;
wire [2:0]  tail_robWB;

//WB-DECODE
wire[15:0]  wb_resultDECODE;
wire [2:0]  destReg_addrDECODE;
wire        writeEnableDECODE;
wire [1:0]  bp_DECODE;

//WB-ROB
wire [2:0]  tail_robROB;
wire[15:0]  wb_resultROB;
wire [2:0]  destReg_addrROB;
wire        writeEnableROB;
assign wb_resultROB = wb_resultDECODE;
assign destReg_addrROB =destReg_addrDECODE;
assign writeEnableROB= writeEnableDECODE;

//ROB-DECODE
wire[15:0]  wb_resultDECODE_ROB;
wire [2:0]  destReg_addrDECODE_ROB;
wire        writeEnableDECODE_ROB;


rob my_rob(

//common inputs
.clk(clk),
.reset(reset),

//INPUTS
//from DECODE
.tail_increment_enable(tail_rob_increment_enable),
//from WB    
.slot_id_input_sp(tail_robROB),
.addr_result_input_sp(destReg_addrROB),
.result_input_sp(wb_resultROB),
.valid_exception_input_sp({writeEnableROB, 1'b0}),
.pc_input_sp(16'hffff),
.write_enable_input_sp(writeEnableROB), //NOT NECESSARY
  
//output to DECODE
.result_head(wb_resultDECODE_ROB),
.addr_result_head(destReg_addrDECODE_ROB),
.write_enable_RB(writeEnableDECODE_ROB),

//this is the shif id
.tail(tail_robALU)



);

fetch my_fetch(
//common inputs
.clk(clk),                      
.enable_pc(block_pc & enable_pc_external),
.reset(reset),                //Not necessary by this moment

//fixed input
.initial_inst_addr(16'h000c),  //fixed initial instruction address

//input from DECODE
.sel_pc(sel_pc),               //select the d input of pc register
.branch_pc(branch_pc_addr),    // address to jump in a branch
    
//output to DECODE
.inst_code(inst_code)
);


decode my_decode(
//common inputs
.clk(clk),   //the clock is the same for ev.
.reset(reset), //the reset is the same for everyone

//inputs from FETCH
.instruction_code(inst_code),

//inputs from WB
.dWB(wb_resultDECODE),
.writeAddrWB(destReg_addrDECODE),
.writeEnableWB(writeEnableDECODE), //when write enable, write d into writeAddr

//inputs from ROB
.dROB(wb_resultDECODE_ROB),
.writeAddrROB(destReg_addrDECODE_ROB),
.writeEnableROB(writeEnableDECODE_ROB),

//output to fetch
.sel_pc(sel_pc),              //pc selection for fetch stage
.branch_pc(branch_pc_addr),        //where fetch should jump if branch done 
.enable_pc(block_pc),

//to ROB
.tail_rob_increment_enable(tail_rob_increment_enable),

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

//common inputs
.clk(clk),
.enable_alu(1'b1),
.reset(reset & ~clean_alu),

//inputs from DECODE
.regA(regA),
.regB(regB),
.cop(cop),
.destReg_addr(destReg_addrALU),
.we(writeEnableALU),
.inmediate(inmediate),
.bp_input(bp_ALU),
.dataReg(dataRegALU),
.ldSt_enable(ldSt_enableALU),

//input from ROB
.tail_rob_input(tail_robALU),


//outputs
.OVF(),                       //NOT CONNECTED
.alu_result(alu_resultTLB),
.destReg_addr_output(destReg_addrTLB),
.we_output(writeEnableTLB),
.bp_output(bp_TLB),
.dataReg_output(dataRegTLB),
.ldSt_enable_output(ldSt_enableTLB),
.tail_rob_output(tail_robTLB)
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
.dataReg(dataRegTLB),
.ldSt_enable(ldSt_enableTLB),
//from ALU
.tail_rob_input(tail_robTLB),
//from CACHE
.cache_result(cache_resultWB),
.destReg_addrCACHE(destReg_addrWB),
//from WB
.wb_result(wb_resultDECODE),
.destReg_addrWB(destReg_addrDECODE),

  
//outputs
.tlblookup_result(tlb_resultCACHE),
.destReg_addr_output(destReg_addrCACHE),
.we_output(writeEnableCACHE),
.bp_output(bp_CACHE),
.dataReg_output(dataRegCACHE),
.ldSt_enable_output(ldSt_enableCACHE),
.tail_rob_output(tail_robCACHE)

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
.dataReg(dataRegCACHE),
.ldSt_enable(ldSt_enableCACHE),
.tail_rob_input(tail_robCACHE),

//outputs
.cache_result(cache_resultWB),
.destReg_addr_output(destReg_addrWB),
.we_output(writeEnableWB),
.bp_output(bp_WB),
.tail_rob_output(tail_robWB)
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
.tail_rob_input(tail_robWB),
  
  //outputs
.wb_result(wb_resultDECODE),
.destReg_addr_output(destReg_addrDECODE),
.we_output(writeEnableDECODE),
.bp_output(bp_DECODE),
.tail_rob_output(tail_robROB)
);

endmodule
