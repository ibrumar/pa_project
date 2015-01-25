module proc #(parameter ROB_REGISTER_SIZE=41, 
              parameter ROB_NUM_REGS=8,
              parameter LOG_ROB_NUM_REGS=3)(
  input clk,
  input reset,
  input enable_pc_external,
  input test
);

//fetch-decode
wire [15:0] inst_code;
wire [15:0] fetch_pcDECODE;
wire [1:0]  fetch_ex_vector_DECODE;

//decode-fetch
wire [1:0]  sel_pc;     
wire [15:0] branch_pc_addr;
//bypass block
wire block_pc;

//decode-ROB
wire tail_rob_increment_enable;


//decode-ROB_BYPASS STRUCTURE
wire [2:0]bypass_rob_addr;
wire [2:0]bypass_rob_data;
wire bypass_rob_we;

wire [2:0]bypass_rob_read_porta;
wire [2:0]bypass_rob_read_portb;

//ROB_BYPASS-ROB port b & c
wire [2:0]bypass_rob_read_roba;
wire [2:0]bypass_rob_read_robb;

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
wire        decode_enableALU;
wire [15:0] pcALU;
wire [1:0]  ex_vectorALU;
wire        ticketWE_ALU;

//DECODE-FSTAGES
wire        decode_enableFSTAGES;
wire [2:0]  opa_addr_fstages;
wire [2:0]  opb_addr_fstages;
//wire [15:0] pcFSTAGES; ->pcALU

//ROB-DECODE
wire [2:0] tail_robDECODE;
wire [ROB_REGISTER_SIZE-1:0]bypass_rob_opa;
wire [ROB_REGISTER_SIZE-1:0]bypass_rob_opb;
wire rob_empty;

//alu-TLB
wire [15:0] dataRegTLB;
wire [1:0]  ldSt_enableTLB;
wire[15:0]  alu_resultTLB;
wire [2:0]  destReg_addrTLB;
wire        writeEnableTLB;
wire [1:0]  bp_TLB;
wire [2:0]  tail_robTLB;
wire [15:0] pcTLB;
wire [1:0]  ex_vectorTLB;
wire        ticketWE_TLB;

//TLB-CACHE
wire [15:0] dataRegCACHE;
wire [1:0]  ldSt_enableCACHE;
wire[15:0]  tlb_resultCACHE;
wire [2:0]  destReg_addrCACHE;
wire        writeEnableCACHE;
wire [1:0]  bp_CACHE;
wire [2:0]  tail_robCACHE;
wire [15:0] pcCACHE;
wire [1:0]  ex_vectorCACHE;
wire        ticketWE_CACHE;

//CACHE-WB
wire[15:0]  cache_resultWB;
wire [2:0]  destReg_addrWB;
wire        writeEnableWB;
wire [1:0]  bp_WB;
wire [2:0]  tail_robWB;
wire [15:0] pcWB;
wire [1:0]  ex_vectorWB;
wire        ticketWE_WB;

//WB-DECODE
wire[15:0]  wb_resultDECODE;
wire [2:0]  destReg_addrDECODE;
wire [1:0]  bp_DECODE;

//WB-ROB
wire [2:0]  tail_robROB;
wire[15:0]  wb_resultROB;
wire [2:0]  destReg_addrROB;
wire        writeEnableROB;
wire [15:0] short_ppl_pcROB;
wire [1:0]  ex_vectorROB;
wire        wb_ticketWE_ROB;

//ROB-DECODE (to RB)
wire [15:0] result_ROB;
wire [2:0]  destReg_addr_ROB;
wire        writeEnable_ROB;

wire [15:0] ex_pc_DECODE;
wire [15:0] ex_dTLB_DECODE;
wire [1:0]  ex_vectorROB_DECODE;

//F_STAGES-ROB
wire [2:0]    long_ppl_destReg_addrROB;
wire          long_ppl_writeEnableROB;
wire [2:0]    long_ppl_tail_robROB;
wire [15:0]   long_ppl_pcROB;
wire [15:0]   long_ppl_wb_resultROB;

//FSTAGES-DECODE
wire [1:0]  bypass_here_ready_a;
wire [1:0]  bypass_here_ready_b;
wire [15:0] bypass_data_fstages;


rob_bypasses_reg_file my_rob_bypasses_reg_file(
//common inputs
.clk(clk),
.reset(reset),

//Outputs
.a(bypass_rob_read_roba),
.b(bypass_rob_read_robb),

//inputs
.ra(bypass_rob_read_porta),
.rb(bypass_rob_read_portb),
.d(bypass_rob_data),
.writeAddr(bypass_rob_addr),
.writeEnable(bypass_rob_we)

);
//The long pipeline...
f_stages my_f_stages(

//common inputs
.clk(clk),
.reset(reset),

//inputs from DECODE
.enable(decode_enableFSTAGES),
.destReg_addr(destReg_addrALU),
.we(writeEnableALU), //THIS SHOULD BE ALWAYS 1
.tail_rob_input(tail_robDECODE),
.pc_input(pcALU),
.inmediate(inmediate),
.opa_addr(opa_addr_fstages),
.opb_addr(opb_addr_fstages),


//input from ROB BYPASS STRUCTURE (indirectly from DECODE)
.opa_ticket(bypass_rob_read_roba),
.opb_ticket(bypass_rob_read_robb),


//outputs
.destReg_addr_output(long_ppl_destReg_addrROB),
.we_output(long_ppl_writeEnableROB),
.tail_rob_output(long_ppl_tail_robROB),
.pc_output(long_ppl_pcROB),
.result_output(long_ppl_wb_resultROB),

//to DECODE

.bypass_here_ready_a(bypass_here_ready_a),
.bypass_here_ready_b(bypass_here_ready_b),
.bypass_data(bypass_data_fstages)

);


rob my_rob(

//common inputs
.clk(clk),
.reset(reset),

//INPUTS
//from DECODE
.tail_increment_enable(tail_rob_increment_enable),
.rb(bypass_rob_read_roba),
.rc(bypass_rob_read_robb),


//WRITES:
  //from WB    
.slot_id_input_sp(tail_robROB),
.valid_exception_input_sp(2'b10),
.addr_result_input_sp(destReg_addrROB),
.result_input_sp(wb_resultROB),
.pc_input_sp(short_ppl_pcROB),
.ex_vector_input_sp(ex_vectorROB),
.write_enable_input_sp(writeEnableROB),
.ticketWE_input_sp(wb_ticketWE_ROB),

//IULIAN
.ldBYTE(1'b1),

  //from f_stages
.slot_id_input_lp(long_ppl_tail_robROB),
.valid_exception_input_lp(2'b10),
.addr_result_input_lp(long_ppl_destReg_addrROB),
.result_input_lp(long_ppl_wb_resultROB),
.pc_input_lp(long_ppl_pcROB),
.ex_vector_input_lp(2'b00), 
.write_enable_input_lp(long_ppl_writeEnableROB),
.ticketWE_input_lp(long_ppl_writeEnableROB),

  
//output to DECODE(to write in Register Bank)
.result_head(result_ROB),
.addr_result_head(destReg_addr_ROB),
.write_enable_RB(writeEnable_ROB),

.b(bypass_rob_opa),
.c(bypass_rob_opb),

//this is the shift id
.tail(tail_robDECODE),
.empty(rob_empty),

.ex_vector_head(ex_vectorROB_DECODE),
.pc_output(ex_pc_DECODE)
//.(ex_dTLB_DECODE);


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
.inst_code(inst_code),
.pc_output(fetch_pcDECODE),
.ex_vector_output(fetch_ex_vector_DECODE)

);


decode my_decode(
//common inputs
.clk(clk),   //the clock is the same for ev.
.reset(reset), //the reset is the same for everyone

//inputs from FETCH
.instruction_code_a(inst_code),
.pc_input(fetch_pcDECODE),
.ex_vector_input_a(fetch_ex_vector_DECODE),

//inputs from ROB
.tail_rob_input(tail_robDECODE),
.bypass_rob_opa(bypass_rob_opa),
.bypass_rob_opb(bypass_rob_opb),

.dROB(result_ROB),
.writeAddrROB(destReg_addr_ROB),
.writeEnableROB(writeEnable_ROB),

.rob_empty(rob_empty),

  //exception info
.ex_pc(ex_pc_DECODE),
.ex_dTLB(ex_dTLB_DECODE),
.ex_vectorROB(ex_vectorROB_DECODE),



//input from FSTAGES
.bypass_here_ready_a(bypass_here_ready_a),
.bypass_here_ready_b(bypass_here_ready_b),
.bypass_data_fstages(bypass_data_fstages),


//output to fetch
.sel_pc(sel_pc),              //pc selection for fetch stage
.branch_pc(branch_pc_addr),        //where fetch should jump if branch done 
.enable_pc(block_pc),

//to ROB
.tail_rob_increment_enable(tail_rob_increment_enable),

//to BYPASS ROB STRUCTURE
.bypass_rob_addr(bypass_rob_addr),
.bypass_rob_data(bypass_rob_data),
.bypass_rob_we(bypass_rob_we),
.bypass_rob_read_porta(bypass_rob_read_porta),
.bypass_rob_read_portb(bypass_rob_read_portb),

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
.enableALU(decode_enableALU),
.pc_output(pcALU),
.ex_vector_output(ex_vectorALU),
.ticketWE_output(ticketWE_ALU),

//outputs to FSTAGES
.enableFSTAGES(decode_enableFSTAGES),
.opa_addr_fstages(opa_addr_fstages),
.opb_addr_fstages(opb_addr_fstages),
  

//inputs for BYPASS

//from ALU
.alu_result(alu_resultTLB),
.destReg_addrALU(destReg_addrTLB),
.bp_ALU(bp_TLB),
.ticketALU(tail_robTLB),

//from TLB
.tlblookup_result(tlb_resultCACHE),
.destReg_addrTLB(destReg_addrCACHE),
.bp_TLB(bp_CACHE),
.ticketTLB(tail_robCACHE),

//from CACHE
.cache_result(cache_resultWB),
.destReg_addrCACHE(destReg_addrWB),
.bp_CACHE(bp_WB),
.ticketCACHE(tail_robWB),

//from WB
.wb_result(wb_resultROB),
.destReg_addrWB(destReg_addrROB),
.bp_WB(bp_DECODE),
.ticketWB(tail_robROB),

//from ROB_BYPASS STRUCTURE
.updated_ticket_opa(bypass_rob_read_roba),
.updated_ticket_opb(bypass_rob_read_robb)

);


alu_stage my_alu(

//common inputs
.clk(clk),
.reset(reset & ~clean_alu),

//inputs from DECODE
.enable_alu(decode_enableALU),
.regA(regA),
.regB(regB),
.cop(cop),
.destReg_addr(destReg_addrALU),
.we(writeEnableALU),
.inmediate(inmediate),
.bp_input(bp_ALU),
.dataReg(dataRegALU),
.ldSt_enable(ldSt_enableALU),
.tail_rob_input(tail_robDECODE),
.pc_input(pcALU),
.ex_vector_input(ex_vectorALU),
.ticketWE_input(ticketWE_ALU),


//outputs
.OVF(),                       //NOT CONNECTED
.alu_result(alu_resultTLB),
.destReg_addr_output(destReg_addrTLB),
.we_output(writeEnableTLB),
.bp_output(bp_TLB),
.dataReg_output(dataRegTLB),
.ldSt_enable_output(ldSt_enableTLB),
.tail_rob_output(tail_robTLB),
.pc_output(pcTLB),
.ex_vector_output(ex_vectorTLB),
.ticketWE_output(ticketWE_TLB)

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
.pc_input(pcTLB),
.ex_vector_input(ex_vectorTLB),
.ticketWE_input(ticketWE_TLB),



  
//outputs
.tlblookup_result(tlb_resultCACHE),
.destReg_addr_output(destReg_addrCACHE),
.we_output(writeEnableCACHE),
.bp_output(bp_CACHE),
.dataReg_output(dataRegCACHE),
.ldSt_enable_output(ldSt_enableCACHE),
.tail_rob_output(tail_robCACHE),
.pc_output(pcCACHE),
.ex_vector_output(ex_vectorCACHE),
.ticketWE_output(ticketWE_CACHE)

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
.pc_input(pcCACHE),
.ex_vector_input(ex_vectorCACHE),
.ticketWE_input(ticketWE_CACHE),

//outputs
.cache_result(cache_resultWB),
.destReg_addr_output(destReg_addrWB),
.we_output(writeEnableWB),
.bp_output(bp_WB),
.tail_rob_output(tail_robWB),
.pc_output(pcWB),
.ex_vector_output(ex_vectorWB),
.ticketWE_output(ticketWE_WB)

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
.pc_input(pcWB),
.ex_vector_input(ex_vectorWB),
.ticketWE_input(ticketWE_WB),

  
//outputs
  //to ROB
.wb_result(wb_resultROB),
.destReg_addr_output(destReg_addrROB),
.we_output(writeEnableROB),
.tail_rob_output(tail_robROB),
.pc_output(short_ppl_pcROB),
.ex_vector_output(ex_vectorROB),
.ticketWE_output(wb_ticketWE_ROB),


//to decode
.bp_output(bp_DECODE)

);

endmodule
