module rob_register_file#(parameter NUM_REGISTERS = 8, parameter LOG_NUM_REGISTERS=3, parameter WIDTH = 41)
( 
  input clk,
  input [LOG_NUM_REGISTERS-1:0]ra,
  output reg [WIDTH-1:0] a,
  input [LOG_NUM_REGISTERS-1:0]rb,
  output reg [WIDTH-1:0] b,
  input [LOG_NUM_REGISTERS-1:0]rc,
  output reg [WIDTH-1:0] c,


  //# ports to write
  input [WIDTH-1:0] d_a,
  input [LOG_NUM_REGISTERS-1:0] writeAddr_a,
  input writeEnable_a, 

  input [WIDTH-1:0] d_b,
  input [LOG_NUM_REGISTERS-1:0] writeAddr_b,
  input writeEnable_b, 

  input [WIDTH-1:0] d_c,
  input [LOG_NUM_REGISTERS-1:0] writeAddr_c,
  input writeEnable_c, 
 
  input reset
  
  
  );

  //WIRES MULTI-WRITTING
  wire [NUM_REGISTERS-1:0]write_enable_reg;
     
  //2- Log2(num_ports)
  wire [2*NUM_REGISTERS-1:0] port_sel__mux;
  
  wire [WIDTH*NUM_REGISTERS - 1:0] mux_out__reg_in;
  
   
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
        default: a <= {36'hxxxxxxxxx,5'bxxxxx};
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
        default: b <= {36'hxxxxxxxxx,5'bxxxxxx};
      endcase
      
      case(rc)
        3'b000: c <= concatenated_outputs[WIDTH-1:0];
        3'b001: c <= concatenated_outputs[2*WIDTH-1:WIDTH];
        3'b010: c <= concatenated_outputs[3*WIDTH-1:2*WIDTH];
        3'b011: c <= concatenated_outputs[4*WIDTH-1:3*WIDTH];
        3'b100: c <= concatenated_outputs[5*WIDTH-1:4*WIDTH];
        3'b101: c <= concatenated_outputs[6*WIDTH-1:5*WIDTH];
        3'b110: c <= concatenated_outputs[7*WIDTH-1:6*WIDTH];
        3'b111: c <= concatenated_outputs[8*WIDTH-1:7*WIDTH];
        default: c <= {36'hxxxxxxxxx,5'bxxxxxx};
      endcase

    end

  genvar i;
  generate
    for (i=0; i<NUM_REGISTERS; i=i+1)
      begin: gen_regfile
        register #(WIDTH) my_register(.clk(clk), .d(mux_out__reg_in[(i + 1)*WIDTH - 1:i*WIDTH]),
          .enable(write_enable_reg[i]), 
          .reset(reset), 
          .q(concatenated_outputs[(i + 1)*WIDTH - 1:i*WIDTH]));
          
        
      end //we hope that the indexing doesn't imply multiplying
          //in hardware
  endgenerate

  generate
    for (i=0; i<NUM_REGISTERS; i=i+1)
      begin: control_multi_writting

      port_selector #(3, 2) my_port_selector(.addr_a(writeAddr_a), .addr_b(writeAddr_b), 
       .addr_c(writeAddr_c), .we_a(writeEnable_a), .we_b(writeEnable_b), .we_c(writeEnable_c),
       .fixed_addr(i[2:0]), .we_output(write_enable_reg[i]), 
       .sel(port_sel__mux[i*2+1:i*2]));
      
      mux4_ #(WIDTH) my_mux(.a(d_a), .b(d_b), .c(d_c), .d({36'hxxxxxxxxx,5'bxxxxxx}), 
            .sel(port_sel__mux[i*2+1:i*2]),
            .out(mux_out__reg_in[(i + 1)*WIDTH - 1:i*WIDTH]));
        
      end 
  endgenerate



endmodule