module rob#(parameter ROB_REGISTER_SIZE=41, 
           parameter ROB_NUM_REGS=8,
           parameter LOG_ROB_NUM_REGS=3)(
  
  //common inputs
  input clk,
  input reset,
    
  //INPUTS

  //WRITES:
    //from WB
  input [2:0]   slot_id_input_sp,
  input [1:0]   valid_exception_input_sp,
  input [2:0]   addr_result_input_sp,
  input [15:0]  result_input_sp,
  input [15:0]  pc_input_sp,
  input         write_enable_input_sp, 
  input [1:0]   ex_vector_input_sp,
  input         ticketWE_input_sp, 
  input         ldBYTE,
  
    //from f_stages  
  input [2:0]   slot_id_input_lp,
  input [1:0]   valid_exception_input_lp,
  input [2:0]   addr_result_input_lp,
  input [15:0]  result_input_lp,
  input [15:0]  pc_input_lp,
  input         write_enable_input_lp,
  input [1:0]   ex_vector_input_lp, 
  input ticketWE_input_lp, 
      
  //from DECODE
  input tail_increment_enable,
  input [2:0]rb, //read portb
  input [2:0]rc, //read portc
  //to DECODE
    //write to RB (decode)
  output [15:0] result_head,
  output [2:0] addr_result_head,
  output        write_enable_RB,
  output [15:0] pc_output,
  output [1:0]  ex_vector_head,
  output ldBYTE_output,
  
  output reg[2:0]tail,
  output[ROB_REGISTER_SIZE-1:0] b,
  output[ROB_REGISTER_SIZE-1:0] c,
  output reg  empty
  
  );
    
  //WIRES & REGS
  wire [2:0]increment_tail;
  wire [2:0]increment_head;
  
  reg [2:0]     head;
  wire[1:0]     valid_exception_head;
  
  reg enable_increment_head;
  
  
   //MODULES
   rob_register_file #(ROB_NUM_REGS, LOG_ROB_NUM_REGS, ROB_REGISTER_SIZE) reorder_buffer(
  .clk(clk), 
  .reset(reset),
  
  //READ
  //read address
  .ra(head), 
  //read outputs
  .a({addr_result_head, result_head,
      valid_exception_head, pc_output, ex_vector_head, ldBYTE_output, write_enable_RB}),
  
  .rb(rb),
  .b(b),
  
  .rc(rc),
  .c(c),
  
  //WRITE
  .writeAddr_b(slot_id_input_sp),
  .d_b({addr_result_input_sp, result_input_sp, valid_exception_input_sp,
    pc_input_sp, ex_vector_input_sp, ldBYTE, write_enable_input_sp}),
  .writeEnable_b(ticketWE_input_sp),
  
  .d_a(41'h0000000000),
  .writeAddr_a(tail),
  .writeEnable_a(1'b1),

  
  .writeAddr_c(slot_id_input_lp),
  .d_c({addr_result_input_lp, result_input_lp, valid_exception_input_lp,
    pc_input_lp, ex_vector_input_lp, 1'b0, write_enable_input_lp}),
  .writeEnable_c(ticketWE_input_lp)
    
  );

  
  register #(LOG_ROB_NUM_REGS) tail_aux(
  .clk(clk),
  .reset(reset),
  .enable(tail_increment_enable),
  .d((increment_tail +1'b1)),
  .q(increment_tail)
  );
 
  register #(LOG_ROB_NUM_REGS) head_aux(
  .clk(clk),
  .reset(reset),
  .enable(enable_increment_head),
  .d((increment_head +1'b1)),
  .q(increment_head)
  );

    
  //LOGIC
  always @ (*)
  begin
      if(valid_exception_head==2'b10) begin 
        enable_increment_head<=1'b1;
      end
      else begin
        enable_increment_head<=1'b0;
      end
  end

  
  always @ (*)
  begin
    if((tail-head)==0 | (tail-head==1))begin
      empty<=1'b1;
    end
    else begin
      empty<=1'b0;
    end
    
    tail <=increment_tail;
    head <=increment_head;
   
  end
  
  always @ (*)
  begin
    if(reset==0)begin
        tail<=0;
        head<=0;
    end
  end
  
endmodule