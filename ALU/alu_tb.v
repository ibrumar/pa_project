module alu_tb();
  
  reg [15:0] reg_A;
  reg [15:0] reg_B;
  reg [3:0]  cop;
  
  wire [15:0] result;
  wire OVF;
  
  initial begin
    //testing NOP
    cop=  4'b 0000;
    
    //testing ADD
    #10 cop=  4'b0001; //ADD
    
    #5 reg_A= 16'h00_00;
       reg_B= 16'h00_01;

    #5 reg_A= 16'h00_01;
       reg_B= 16'h00_01;
    
    //OVF
    #5 reg_A= 16'hFF_FF;
       reg_B= 16'h00_01;
    #5 reg_A= 16'hFF_FF;
       reg_B= 16'hFF_FF;


    //testing SUB
    #10 cop=  4'b0010; //SUB
    
    #5 reg_A= 16'h00_01;
       reg_B= 16'h00_00;

    #5 reg_A= 16'h00_01;
       reg_B= 16'h00_01;
    
    //OVF
    #5 reg_A= 16'h00_00;
       reg_B= 16'h00_01;
       
    #5 reg_A= 16'h00_00;
       reg_B= 16'hFF_FF;


    //testing MOV
    #10 cop=  4'b0011; //MOV
    
    #5 reg_A= 16'h00_01;
       reg_B= 16'h00_00;

    #5 reg_A= 16'h00_01;
       reg_B= 16'h00_01;


    //testing CMP
    #10 cop=  4'b0100; //CMP
    
    #5 reg_A= 16'h00_01;
       reg_B= 16'h00_00;

    #5 reg_A= 16'h00_01;
       reg_B= 16'h00_01;
       

  end

alu my_alu(
  .reg_A(reg_A),
  .reg_B(reg_B),
  .cop(cop),
  .result(result),
  .OVF(OVF)
);

endmodule
