module alu_stage(
  //common inputs
  input       clk,
  input       enable_alu,
  input       reset,
  
  //inputs from decode
  input [15:0]regA,
  input [15:0]regB,
  input [3:0] cop,
  input [8:0] inmediate,
  
  //forward inputs
  input [15:0]dataReg,
  input [1:0] ldSt_enable,
  input [2:0] destReg_addr,

  input       we,
  input [1:0] bp_input,
  input [2:0] tail_rob_input,
  
  //outputs
  output[15:0]  alu_result,
  output        OVF,
  output[2:0]   destReg_addr_output,
  output        we_output,
  output [1:0]  bp_output,
  output [15:0] dataReg_output,
  output [1:0]  ldSt_enable_output,
  output [2:0]tail_rob_output
  
  );
  
  wire [15:0]q_regA__alu_in;
  wire [15:0]q_regB__mux_a;
  wire [15:0]mux_out__alu_in;
  wire [3:0] q_cop__alu_in;
  wire [8:0] q_inmediate__mux_b; 
   
  reg regB_sel;
  
  register #(72) alu_register(
    .clk(clk),
    .enable(enable_alu),
    .reset(reset),
    .d({regA, regB, cop, destReg_addr, we, inmediate, bp_input, dataReg,
       ldSt_enable, tail_rob_input}),
    .q({q_regA__alu_in, q_regB__mux_a, q_cop__alu_in, destReg_addr_output,
       we_output, q_inmediate__mux_b, bp_output, dataReg_output, 
       ldSt_enable_output, tail_rob_output})
  );
  
  
  mux2 my_mux(
    .a(q_regB__mux_a),
    .b({ 7'b0000000, q_inmediate__mux_b}),
    .out(mux_out__alu_in),
    .sel(regB_sel)
  );
  
 
  alu my_alu(
    .reg_A(q_regA__alu_in),
    .reg_B(mux_out__alu_in),
    .cop(q_cop__alu_in),
    .result(alu_result),
    .OVF(OVF)
  );
  
  
  
  always @(*)
  begin
    case (q_cop__alu_in)
      //MOV, LD and ST uses the inmediate instead of regB
      4'b0011, 4'b0110, 4'b0111: regB_sel<=1;
      default:                   regB_sel<=0;
      
    endcase
    
  end
  

endmodule