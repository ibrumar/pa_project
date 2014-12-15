module decode(
  //fetch outputs
  output reg [1:0]sel_pc, //pc selection for fetch stage
  output [15:0]branch_pc, //where fetch should jump if branch done 
  
  //alu outputs
  output [15:0] regA,
  output [15:0] regB,
  output [3:0] cop,
  output [2:0] destReg_addr,
  output reg writeEnableALU,
  
  //common inputs
  input clk,   //the clock is the same for ev.
  input reset, //the reset is the same for everyone
  
  //inputs from fetch
  input[7:0]instruction_code_high,
  input[7:0]instruction_code_low, //inputs from fetch
  //no pc is needed because we don't have relative jumps for the moment
  
  //inputs from write_back
  input [15:0] dWB,
  input [3:0] writeAddrWB,
  input writeEnableWB //when write enable, write d into writeAddr

);

  
  wire [7:0] q_instruction_code_high;
  wire [7:0] q_instruction_code_low;
  wire [15:0] regBWire;
  
  register #(49) decode_register(
    .clk(clk),
    .enable(1'b1), //the enable is generated by the decode itself
    .reset(reset),
    .d({instruction_code_high, instruction_code_low}),
    
    .q({q_instruction_code_high, q_instruction_code_low})
    //.q({regA_out__alu_in, regB_out__mux_in, cop_out__alu_in,
    //   destReg_adr_output, we_output, regA_adr_out__mux_in, 
    //   regB_adr_out__mux_in, inst_freeBits_out__mux_in})
  );
  
  wire [15:0] q_instruction_code = {q_instruction_code_high, q_instruction_code_low};
  assign cop = q_instruction_code[15:12]; // maybe the ALU shouldn't see the instruction code  
  assign destReg_addr = q_instruction_code[11:9];
  assign inmed = q_instruction_code[8:0];
  
 register_file my_register_file(
  .clk(clk), //cambiar a i_I_address
  .reset(reset),
  .ra(q_instruction_code[8:6]),
  .rb(q_instruction_code[2:0]),
  .d(dWB),
  .writeAddr(writeAddrWB),
  .writeEnable(writeEnableWB),
  .a(regA),
  .b(regBWire)
);

  //FETCH PC Control
  always @(*)
  begin
    if (reset == 1)
      begin
      sel_pc <= 2'b00; //select the initial address if we're in reset
      end
    else
      begin
      if (q_instruction_code[15:12] == 4'b0101 && regA != 16'h0000)
        sel_pc <= 2'b10; //if branch and regA != 0 then jump
      else 
        sel_pc <= 2'b01; //if not branch or branch doesn't jump then implicit sequencing
    end
  end
    
  assign branch_pc = regBWire; // goes to FETCH. The other inputs to the PC have their source in fetch.
  assign regB = regBWire; //goes to ALU
  

  //ALU write_enable
  always @(*)
  begin
    case(q_instruction_code[15:12])
      4'b0000 : writeEnableALU = 0;
      4'b0001 : writeEnableALU = 1;
      4'b0010 : writeEnableALU = 1;
      4'b0011 : writeEnableALU = 1;
      4'b0100 : writeEnableALU = 1; 
      default : writeEnableALU = 0; //when we'll add the loads they'll need a write permision
    endcase
  end

endmodule
