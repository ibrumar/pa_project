module registerFile#(parameter NUM_REGISTERS = 8, parameter LOG_NUM_REGISTERS=3, parameter WIDTH = 16)
( 
  input clk,
  input [LOG_NUM_REGISTERS-1:0]rb, //CAMBIAR LOS CLAUDATORS
  input ra[LOG_NUM_REGISTERS-1:0],
  output [WIDTH-1:0] a,
  output [WIDTH-1:0] b,
  input [WIDTH-1:0] d,
  input [LOG_NUM_REGISTERS-1:0] writeAddr,
  input writeEnable, //when write enable, write d into writeAddr
  input reset
  );

  wire writeEnableInternal[NUM_REGISTERS-1:0];
  
  wire writenContent = mux
  
  //an always block must be created to set to 0 all registers if reset == 3b0
  //otherwise writeEnableInternal[writeAddr] = d
  
  //we should use '=' inside always* blocks
  

  genvar i;
  generate
    for (i=0; i<NUM_REGISTERS; i=i+1)
      begin: gen_regfile
        register my_register(.clk(clk), .d(d[i]), .enable(enable), 
          .reset(reset), .q(q[i]));
      end
  endgenerate
  
   input clk,
  input [WIDTH-1:0] d,
  input enable,
  input reset,
  output [WIDTH-1:0] q

endmodule