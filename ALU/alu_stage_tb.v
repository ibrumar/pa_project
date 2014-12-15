module alu_stage_tb();
  
  reg [15:0]  regA;
  reg [15:0]  regB;
  reg [3:0]   cop;
  reg [2:0]   destReg_adr;
  reg [8:0]   inmediate;
  reg         we;
  
  reg clk;
  reg enable_alu;
  reg reset;

  wire OVF;
  wire[15:0]alu_result;
  wire[2:0] destReg_addr_output;
  wire we_output;
  
 
  initial begin
    clk<=        1'b1;
    enable_alu<= 1'b1;
    reset<=      1'b0;
    
    regA<=16'h0000;
    regB<=16'h0000;
    cop<=4'b0000;
    destReg_adr<=3'b000;
    we<= 1'b0;
    inmediate<=9'b000_000_000;
    
    #10 reset<=   1'b1;

    we<= 1'b1;
    destReg_adr<=3'b001;
   
    
    //Addition
    #10 regA<= 16'h0001;
    regB<=16'h0001;
    cop<=4'b0001;

    //OVF
    #10 regA<= 16'h0001;
    regB<=16'hFFFF;

    //Substraction
    #10 regA<= 16'h0001;
    regB<=16'h0001;
    cop<=4'b0010;
    
    //OVF
    #10 regA<= 16'h0001;
    regB<=16'h0002;
    
    //------------------
    //MOV
    #10 inmediate<=9'b001_001_001;
    cop<=4'b0011;
    
    
    //Check MOV -> Sel
    #10 cop<=4'b0000;
    #10 cop<=4'b0001;
    #10 cop<=4'b0010;
    #10 cop<=4'b0011;
    #10 cop<=4'b0100;
    #10 cop<=4'b0101;
    #10 cop<=4'b0110;                    
  end
  
  always begin
    #5 clk= ~clk;
  end

alu_stage my_alu_stage(
  .regA(regA),
  .regB(regB),
  .cop(cop),
  .destReg_addr(destReg_adr),
  .we(we),
  .inmediate(inmediate),

  .clk(clk),
  .enable_alu(enable_alu),
  .reset(reset),
  
  .alu_result(alu_result),
  .OVF(OVF),
  .destReg_addr_output(destReg_addr_output),
  .we_output(we_output)
  
);

endmodule
