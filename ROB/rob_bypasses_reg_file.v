module rob_bypasses_reg_file#(parameter NUM_REGISTERS = 8, parameter LOG_NUM_REGISTERS=3, parameter WIDTH = 3)
( 
  input clk,
  input [LOG_NUM_REGISTERS-1:0]rb, //CAMBIAR LOS CLAUDATORS
  input [LOG_NUM_REGISTERS-1:0]ra,
  output reg [WIDTH-1:0] a,
  output reg [WIDTH-1:0] b,
  input [WIDTH-1:0] d,
  input [LOG_NUM_REGISTERS-1:0] writeAddr,
  input writeEnable, //when write enable, write d into writeAddr
  input reset
  );

  //wire signed [NUM_REGISTERS-1:0] extendedReset = reset;
  wire [7:0] writeEnableInternal1;
  //wire writeEnableInternal2[NUM_REGISTERS-1:0];
  wire [WIDTH*NUM_REGISTERS - 1:0]concatenated_outputs; //reading

//we don't do this with multiplicative indexing because we 
//don't want to generate a multiplier outside the ALU  
  always @(*)
    begin
      case(ra)
        3'b000: a <= concatenated_outputs[WIDTH-1:0];
        3'b001: a <= concatenated_outputs[2*WIDTH-1:WIDTH];
        3'b010: a <= concatenated_outputs[3*WIDTH-1:2*WIDTH];
        3'b011: a <= concatenated_outputs[4*WIDTH-1:3*WIDTH];
        3'b100: a <= concatenated_outputs[5*WIDTH-1:4*WIDTH];
        3'b101: a <= concatenated_outputs[6*WIDTH-1:5*WIDTH];
        3'b110: a <= concatenated_outputs[7*WIDTH-1:6*WIDTH];
        3'b111: a <= concatenated_outputs[8*WIDTH-1:7*WIDTH];
      endcase

      case(rb)
        3'b000: b <= concatenated_outputs[WIDTH-1:0];
        3'b001: b <= concatenated_outputs[2*WIDTH-1:WIDTH];
        3'b010: b <= concatenated_outputs[3*WIDTH-1:2*WIDTH];
        3'b011: b <= concatenated_outputs[4*WIDTH-1:3*WIDTH];
        3'b100: b <= concatenated_outputs[5*WIDTH-1:4*WIDTH];
        3'b101: b <= concatenated_outputs[6*WIDTH-1:5*WIDTH];
        3'b110: b <= concatenated_outputs[7*WIDTH-1:6*WIDTH];
        3'b111: b <= concatenated_outputs[8*WIDTH-1:7*WIDTH];
      endcase

    end

  
  decode3 we_dec
  ( 
    .writeEnable(writeEnable),
    .d(writeAddr),
    .q(writeEnableInternal1)
  );
  
  genvar i;
  generate
    for (i=0; i<NUM_REGISTERS; i=i+1)
      begin: gen_regfile
        register#(WIDTH) my_register(.clk(clk), .d(d), .enable(writeEnableInternal1[i]), 
          .reset(reset), 
          .q(concatenated_outputs[(i + 1)*WIDTH - 1:i*WIDTH]));
      end //we hope that the indexing doesn't imply multiplying
          //in hardware
  endgenerate



endmodule
