module alu_stage(
  
  input [15:0]regA,
  input [15:0]regB,
  input [3:0] cop,
  input [2:0] destReg_addr,
  input       we,
  input [8:0] inmediate,
  
  input       clk,
  input       enable_alu,
  input       reset,
  
  output[15:0]alu_result,
  output      OVF,
  output[2:0] destReg_addr_output,
  output      we_output
  
  );
  
  wire [15:0]q_regA__alu_in;
  wire [15:0]q_regB__mux_a;
  wire [15:0]mux_out__alu_in;
  wire [3:0] q_cop__alu_in;
  wire [8:0] q_inmediate__mux_b; 

  
  register #(49) alu_register(
    .clk(clk),
    .enable(enable_alu),
    .reset(reset),
    .d({regA, regB, cop, destReg_addr, we, inmediate}),
    .q({q_regA__alu_in, q_regB__mux_a, q_cop__alu_in,
       destReg_addr_output, we_output, q_inmediate__mux_b})
  );
  
  
  mux2 my_mux(
    .a(q_regB__mux_a),
    .b({ 7'b0000000, q_inmediate__mux_b}),
    .out(mux_out__alu_in),
    //when cop == 0011 select b, otherwise select A
    .sel((~q_cop__alu_in[3:3] & ~q_cop__alu_in[2:2])
      &(q_cop__alu_in[1:1] & q_cop__alu_in[0:0]))
  );
  
 
  alu my_alu(
    .reg_A(q_regA__alu_in),
    .reg_B(mux_out__alu_in),
    .cop(q_cop__alu_in),
    .result(alu_result),
    .OVF(OVF)
  );
  

endmodule