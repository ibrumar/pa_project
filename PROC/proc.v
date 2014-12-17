module proc(
  input clk,
  input reset
);

//fetch-decode
wire [7:0]  inst_code_high;
wire [7:0]  inst_code_low;

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

//alu-TLB

wire[15:0]  alu_resultTLB;
wire [2:0]  destReg_addrTLB;
wire        writeEnableTLB;

//TLB-WB
wire[15:0]  alu_resultWB;
wire [2:0]  destReg_addrWB;
wire        writeEnableWB;

//WB-DECODE
wire[15:0]  alu_resultDECODE;
wire [2:0]  destReg_addrDECODE;
wire        writeEnableDECODE;


fetch my_fetch(
.initial_inst_addr(16'h000c),  //fixed initial instruction address
.sel_pc(sel_pc),               //select the d input of pc register
.branch_pc(branch_pc_addr),    // address to jump in a branch
    
.clk(clk),                      
.enable_pc(1'b1),
.reset(reset),                //Not necessary by this moment

.inst_code_high(inst_code_high),  
.inst_code_low(inst_code_low)
);

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
  //common inputs
.clk(clk),   //the clock is the same for ev.
.reset(reset), //the reset is the same for everyone
  
  //inputs from fetch
.instruction_code_high(inst_code_high),
.instruction_code_low(inst_code_low),
  
  //inputs from write_back
.dWB(alu_resultDECODE),
.writeAddrWB(destReg_addrDECODE),
.writeEnableWB(writeEnableDECODE) //when write enable, write d into writeAddr
);


alu_stage my_alu(
.regA(regA),
.regB(regB),
.cop(cop),
.destReg_addr(destReg_addrALU),
.we(writeEnableALU),
.inmediate(inmediate),
  
.clk(clk),
.enable_alu(1'b1),
.reset(reset),

//output
.alu_result(alu_resultTLB),
.OVF(),                       //NOT CONNECTED
.destReg_addr_output(destReg_addrTLB),
.we_output(writeEnableTLB)

);


tlblookup_stage my_tlb(
.clk(clk),
.enable_tlblookup(1'b1),
.reset(reset),
  
.alu_result(alu_resultTLB),
.destReg_addr_input(destReg_addrTLB),
.we_input(writeEnableTLB),
  
//outputs
.tlblookup_result(alu_resultWB),
.destReg_addr_output(destReg_addrWB),
.we_output(writeEnableWB)
);


//WB
wb_stage my_wb(
.clk(clk),
.enable_tlblookup(1'b1),
.reset(reset),
  
 //input 
.tlblookup_result(alu_resultWB),
.destReg_addr_input(destReg_addrWB),
.we_input(writeEnableWB),
  
  //output
.wb_result(alu_resultDECODE),
.destReg_addr_output(destReg_addrDECODE),
.we_output(writeEnableDECODE)
);

endmodule
