module f_stages#(parameter NUM_STAGES=6, parameter REG_SIZE=39)(
  input         clk,
  input         enable,
  input         reset,

  //input from decode: bypass_ports
  input [2:0]   opa_addr,
  input [2:0]   opb_addr,

  input [8:0]   inmediate,

  
  //inputs from ROB BYPASS STRUCTURE
  input [2:0]   opa_ticket,
  input [2:0]   opb_ticket,
      
  //forward inputs
  input [2:0]   destReg_addr,
  input         we,
  input [2:0]   tail_rob_input,
  input [15:0]  pc_input,
  
  //outputs
  output[2:0]   destReg_addr_output,
  output        we_output,
  output [2:0]  tail_rob_output,
  output [15:0] pc_output,
  output[15:0]  result_output,
  
  //to decode
  output reg[1:0] bypass_here_ready_a,
  output reg[1:0] bypass_here_ready_b,
  output reg[15:0] bypass_data
  
);
//result is the last data in the array

wire [(REG_SIZE*(NUM_STAGES-1))-1:0]dq;
wire [15:0] result_input;

//calculate result: THIS SHOULD BE DONE AT THE LAST STAGE!
//assign result_input= {7'b1111111, inmediate};
assign result_input= {7'b0000000, inmediate};


genvar i;
generate
    for (i=0; i<NUM_STAGES; i=i+1)
      begin: generate_f_stages
       if(i==0)
        register #(REG_SIZE) my_register(.clk(clk), .enable(enable), .reset(reset&enable), 
          .d({destReg_addr, we, tail_rob_input, pc_input, result_input}), 
          .q(dq[REG_SIZE-1:0]) );
          
       else if(i==NUM_STAGES-1)
        register #(REG_SIZE) my_register(.clk(clk), .enable(1'b1), .reset(reset), 
          .d(dq[(i*REG_SIZE)-1 :(i-1)*REG_SIZE]), 
          .q({destReg_addr_output, we_output, tail_rob_output, pc_output, result_output}));
       else
         register #(REG_SIZE) my_register(.clk(clk), .enable(1'b1), .reset(reset), 
          .d(dq[(i*REG_SIZE)-1 :(i-1)*REG_SIZE]), 
          .q(dq[(i*REG_SIZE)+REG_SIZE-1 : i*REG_SIZE]) );
         
      end 
  endgenerate

  //CHECK BYPASSES IN ALL STAGES (OPERATING A)
  always @(*)
  begin
    bypass_data<=result_output;
     if(opa_addr==dq[REG_SIZE-1:REG_SIZE-3]         //destReg
      & dq[REG_SIZE-4]==1'b1                        //WE
      & opa_ticket==dq[REG_SIZE-5:REG_SIZE-7])begin //ticket
      bypass_here_ready_a<=2'b10;
    end
    
    else if(opa_addr==dq[REG_SIZE-3+(1*REG_SIZE)+2:REG_SIZE-3+(1*REG_SIZE)]
            & dq[36+(1*REG_SIZE)-1]==1'b1
            & opa_ticket==dq[REG_SIZE-3+(1*REG_SIZE)-2:REG_SIZE-3+(1*REG_SIZE)-4])begin
      bypass_here_ready_a<=2'b10;
    end
    else if(opa_addr==dq[REG_SIZE-3+(2*REG_SIZE)+2:REG_SIZE-3+(2*REG_SIZE)]
            & dq[36+(2*REG_SIZE)-1]==1'b1
            & opa_ticket==dq[REG_SIZE-3+(2*REG_SIZE)-2:REG_SIZE-3+(2*REG_SIZE)-4])begin
      bypass_here_ready_a<=2'b10;
    end
    else if(opa_addr==dq[REG_SIZE-3+(3*REG_SIZE)+2:REG_SIZE-3+(3*REG_SIZE)]
            & dq[36+(3*REG_SIZE)-1]==1'b1
            & opa_ticket==dq[REG_SIZE-3+(3*REG_SIZE)-2:REG_SIZE-3+(3*REG_SIZE)-4])begin
      bypass_here_ready_a<=2'b10;
    end
    else if(opa_addr==dq[REG_SIZE-3+(4*REG_SIZE)+2:REG_SIZE-3+(4*REG_SIZE)]
            & dq[36+(4*REG_SIZE)-1]==1'b1
            & opa_ticket==dq[REG_SIZE-3+(4*REG_SIZE)-2:REG_SIZE-3+(4*REG_SIZE)-4])begin
      bypass_here_ready_a<=2'b10;
    end


    //if register is in the last stage
    else if(opa_addr==destReg_addr_output 
            & we_output==1'b1
            & opa_ticket==tail_rob_output)begin
      bypass_here_ready_a<=2'b11;
    end
    else begin
      bypass_here_ready_a<=2'b00;
    end
      
  end
  
  
  
  
  //CHECK BYPASSES IN ALL STAGES (OPERATING B)
  always @(*)
  begin
    if(opb_addr==dq[REG_SIZE-1:REG_SIZE-3] 
      & dq[REG_SIZE-4]==1'b1
      & opb_ticket==dq[REG_SIZE-5:REG_SIZE-7])begin
      
      bypass_here_ready_b<=2'b10;
    end
    
    else if(opb_addr==dq[REG_SIZE-3+(1*REG_SIZE)+2:REG_SIZE-3+(1*REG_SIZE)]
            & dq[36+(1*REG_SIZE)-1]==1'b1
            & opb_ticket==dq[REG_SIZE-3+(1*REG_SIZE)-2:REG_SIZE-3+(1*REG_SIZE)-4])begin
            
            bypass_here_ready_b<=2'b10;
    end
    else if(opb_addr==dq[REG_SIZE-3+(2*REG_SIZE)+2:REG_SIZE-3+(2*REG_SIZE)]
            & dq[36+(2*REG_SIZE)-1]==1'b1
            & opb_ticket==dq[REG_SIZE-3+(2*REG_SIZE)-2:REG_SIZE-3+(2*REG_SIZE)-4])begin
            
            bypass_here_ready_b<=2'b10;
    end
    else if(opb_addr==dq[REG_SIZE-3+(3*REG_SIZE)+2:REG_SIZE-3+(3*REG_SIZE)]
            & dq[36+(3*REG_SIZE)-1]==1'b1
            & opb_ticket==dq[REG_SIZE-3+(3*REG_SIZE)-2:REG_SIZE-3+(3*REG_SIZE)-4])begin
            
            bypass_here_ready_b<=2'b10;
    end
    else if(opb_addr==dq[REG_SIZE-3+(4*REG_SIZE)+2:REG_SIZE-3+(4*REG_SIZE)]
            & dq[36+(4*REG_SIZE)-1]==1'b1
            & opb_ticket==dq[REG_SIZE-3+(4*REG_SIZE)-2:REG_SIZE-3+(4*REG_SIZE)-4])begin
            
            bypass_here_ready_b<=2'b10;
    end


    //if register is in the last stage
    else if(opb_addr==destReg_addr_output 
            & we_output==1'b1
            & opb_ticket==tail_rob_output)begin
            
            bypass_here_ready_b<=2'b11;
    end
    else begin
      bypass_here_ready_b<=2'b00;
    end
      
  end
 
  
endmodule