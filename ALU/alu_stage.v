module alu_stage(
  
  input [15:0]regA,
  input [15:0]regB,
  input [3:0]cop,
  input [2:0]destReg_adr,
  input we,
  
  //THE FOLLOWING 3 inputs must be an immediate of 9 bits
  //input [2:0]regA_adr,
  //input [2:0]regB_adr,
  //input [2:0]inst_freeBits,
        
  input clk,
  input enable,
  input reset,
  
  output[15:0]alu_result,
  output OVF,
  output[2:0] destReg_adr_output,
  output we_output
  
  //debug 
  //output cop_in_mux

  );
  
  wire [15:0]regA_out__alu_in;
  wire [15:0]regB_out__mux_in;
  wire [15:0]regB_mux_out__alu_in;
  wire [2:0]regA_adr_out__mux_in;
  wire [2:0]regB_adr_out__mux_in;
  wire [2:0]inst_freeBits_out__mux_in;
  wire [3:0]cop_out__alu_in;
  
  //debug
  //assign cop_in_mux=cop_out__alu_in[0:0];
  
  register #(49) alu_register(
    .clk(clk),
    .enable(enable),
    .reset(reset),
    .d({regA, regB, cop, destReg_adr, we, regA_adr, 
        regB_adr, inst_freeBits}),
    
    .q({regA_out__alu_in, regB_out__mux_in, cop_out__alu_in,
       destReg_adr_output, we_output, regA_adr_out__mux_in, 
       regB_adr_out__mux_in, inst_freeBits_out__mux_in})
  );
  
  
  mux2 my_mux(
    .a(regB_out__mux_in),
    .b({ 7'b0000000, regA_adr_out__mux_in, regB_adr_out__mux_in, 
        inst_freeBits_out__mux_in}),
        .out(regB_mux_out__alu_in),
    //when cop == 0011 select b, otherwise select A
    .sel((~cop_out__alu_in[3:3] & ~cop_out__alu_in[2:2])
      &(cop_out__alu_in[1:1] & cop_out__alu_in[0:0]))
    //.sel(cop_out__alu_in[2])
  );
  
 
  alu my_alu(
    .reg_A(regA_out__alu_in),
    .reg_B(regB_mux_out__alu_in),
    .cop(cop_out__alu_in),
    .result(alu_result),
    .OVF(OVF)
  );
  

endmodule