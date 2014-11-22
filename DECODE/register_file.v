module register_file#(parameter NUM_REGISTERS = 8, parameter LOG_NUM_REGISTERS=3, parameter WIDTH = 16)
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
  wire [NUM_REGISTERS-1:0] writeEnableInternal1;
  //wire writeEnableInternal2[NUM_REGISTERS-1:0];
  wire [WIDTH*NUM_REGISTERS - 1:0]concatenated_outputs; //reading

//we don't do this with multiplicative indexing because we 
//don't want to generate a multiplier outside the ALU  
  always @(*)
    begin
      case(ra)
        3'b000: a <= concatenated_outputs[15:0];
        3'b001: a <= concatenated_outputs[31:16];
        3'b010: a <= concatenated_outputs[47:32];
        3'b011: a <= concatenated_outputs[63:48];
        3'b100: a <= concatenated_outputs[79:64];
        3'b101: a <= concatenated_outputs[95:80];
        3'b110: a <= concatenated_outputs[111:96];
        default: a <= concatenated_outputs[127:112];
      endcase
    end


  always @(*)
    begin
      case(rb)
        3'b000: b <= concatenated_outputs[15:0];
        3'b001: b <= concatenated_outputs[31:16];
        3'b010: b <= concatenated_outputs[47:32];
        3'b011: b <= concatenated_outputs[63:48];
        3'b100: b <= concatenated_outputs[79:64];
        3'b101: b <= concatenated_outputs[95:80];
        3'b110: b <= concatenated_outputs[111:96];
        default: b <= concatenated_outputs[127:112];
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
        register my_register(.clk(clk), .d(d), .enable(writeEnableInternal1[i]), 
          .reset(reset), 
          .q(concatenated_outputs[(i + 1)*WIDTH - 1:i*WIDTH]));
      end //we hope that the indexing doesn't imply multiplying
          //in hardware
  endgenerate



endmodule