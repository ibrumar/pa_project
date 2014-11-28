module alu_stage_tb();
  
  reg [15:0] regA;
  reg [15:0] regB;
  reg [3:0] cop;
  reg [2:0] destReg_adr;
  reg [2:0] regA_adr;
  reg [2:0] regB_adr;
  reg [2:0] inst_freeBits;
  reg we;
  
  reg clk;
  reg enable;
  reg reset;

  wire OVF;
  wire[15:0]alu_result;
  wire[2:0] destReg_adr_output;
  wire we_output;
  
  //debug
  //wire cop_in_mux;
 
  initial begin
    clk=        1'b0;
    enable=     1'b1;
    reset=      1'b0;
    
    regA=16'h0000;
    regB=16'h0000;
    cop=4'b0000;
    destReg_adr=3'b000;
    we= 1'b0;
    regA_adr=3'b000;
    regB_adr=3'b000;
    inst_freeBits=3'b000;

    
    #10 reset=   1'b1;

    we= 1'b1;
    destReg_adr=3'b001;
   
    
    //Addition
    #10 regA= 16'h0001;
    regB=16'h0001;
    cop=4'b0001;

    //OVF
    #10 regA= 16'h0001;
    regB=16'hFFFF;

    //Substraction
    #10 regA= 16'h0001;
    regB=16'h0001;
    cop=4'b0010;
    
    //OVF
    #10 regA= 16'h0001;
    regB=16'h0002;
    
    //------------------
    //MOV
    #10 regA_adr=3'b001;
    regB_adr=3'b001;
    inst_freeBits=3'b001;
    cop=4'b0011;
    
    
    //Check MOV -> Sel
    #10 cop=4'b0000;
    #10 cop=4'b0001;
    #10 cop=4'b0010;
    #10 cop=4'b0011;
    #10 cop=4'b0100;
    #10 cop=4'b0101;
    #10 cop=4'b0110;                    
  end
  
  always begin
    #5 clk= ~clk;
  end

alu_stage my_alu_stage(
  .regA(regA),
  .regB(regB),
  .cop(cop),
  .destReg_adr(destReg_adr),
  .we(we),
  .regA_adr(regA_adr),
  .regB_adr(regB_adr),
  .inst_freeBits(inst_freeBits),

  .clk(clk),
  .enable(enable),
  .reset(reset),
  
  .alu_result(alu_result),
  .OVF(OVF),
  .destReg_adr_output(destReg_adr_output),
  .we_output(we_output)
  
  //debug
  //.cop_in_mux(cop_in_mux)
);

endmodule
