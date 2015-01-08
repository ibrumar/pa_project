module memory
    #(parameter data_width = 16,
      parameter addr_width = 16,
      parameter cache_line_width = 256)
     (input  [addr_width-1:0] address,
      input  [cache_line_width-1:0] data_write,
      input                   clk,
      input                   we,
      input                   reset,
      input                   petition,
      output reg              serviceReady,
      //output reg [data_width-1:0] data_read_high,
      output  [cache_line_width-1:0] data_read);
//we are not yet implementing the writes

    reg [data_width-1:0] mem [0:(2**(addr_width - 1))-1];
    reg [1:0] state;
    reg enable_output_register;
    //reg enable_address_register;
    wire [addr_width-1:0] previousAddress;
    //the addresses in memory aren't conceptually at word level
    //they should be at {tag, line} level. We simulate this with 
    //the following variable.
    wire [addr_width-1:0] memoryAddress = {address[addr_width-1:4], 4'b0000}; // this should be ..-1:5
/*    always @(posedge clk) begin : write_proc
        if (we == 1)begin
            mem[address] = data_write_high;
            mem[address+1] = data_write_low;
        end
    end
*/

  register #(cache_line_width) output_register(
    .clk(clk),
    .enable(enable_output_register), //the enable is generated by the decode itself
    .reset(reset),
    .d({mem[memoryAddress+15], mem[memoryAddress+14], mem[memoryAddress+13],
    mem[memoryAddress+12], mem[memoryAddress+11], mem[memoryAddress+10],
    mem[memoryAddress+9], mem[memoryAddress+8], mem[memoryAddress+7],
    mem[memoryAddress+6], mem[memoryAddress+5], mem[memoryAddress+4],
    mem[memoryAddress+3], mem[memoryAddress+2], mem[memoryAddress+1],
    mem[memoryAddress]}),
    .q(data_read)
  );

//mem[memoryAddress], mem[memoryAddress+1],
//    mem[memoryAddress+2], mem[memoryAddress+3], mem[memoryAddress+4], 
//    mem[memoryAddress+5], mem[memoryAddress+6], mem[memoryAddress+7],
//    mem[memoryAddress+8], mem[memoryAddress+9], mem[memoryAddress+10],
//    mem[memoryAddress+11], mem[memoryAddress+12], mem[memoryAddress+13],
//    mem[memoryAddress+14], mem[memoryAddress+15]

//    .d({mem[address+15], mem[address+14], mem[address+13],
//    mem[address+12], mem[address+11], mem[address+10], mem[address+9],
//    mem[address+8], mem[address+7], mem[address+6], mem[address+5],
//    mem[address+4], mem[address+3], mem[address+2], mem[address+1],
//    mem[address]}

  register #(addr_width) address_register(
    .clk(clk),
    .enable(1'b1), //the enable is generated by the decode itself
    .reset(reset),
    .d(memoryAddress),
    .q(previousAddress)
  );

    parameter zero=0, one=1, two=2, three=3;

//se necesita implementar un registro de cambio de dirección
//nos servira para cambiar de dirección. De otra manera podemos
//dar xxxx para los ciclos cuando no se leen datos utiles.
  always @(state) 
    begin
    case (state)
      zero:
      begin
        serviceReady <= 1'b0;
        enable_output_register <= 1'b0;
      end
      one:
      begin
        serviceReady <= 1'b0;
        enable_output_register <= 1'b0;
      end
      two:
      begin
        serviceReady <= 1'b0;
        enable_output_register <= 1'b1;
      end
      three:
      begin
        serviceReady <= 1'b1;
        enable_output_register <= 1'b0;
        //next cycle the instruction may advance 
        //to cache stage and have read the valid data
        //in case of instructions, serviceReady
        //cycle is needed
      end
      default:
        begin
        serviceReady = 1'b0;
        enable_output_register <= 1'b0;
        end
    endcase
  end

  always @(posedge clk or posedge reset or address)
    begin
      if (reset == 0)
        state = zero;
      else
        if (petition)
          case (state) //petition is set to 1 in case of miss
            zero:
              if (memoryAddress != previousAddress) 
                state = zero;
              else
                state = one;
            one:
              if (memoryAddress != previousAddress) 
                state = zero;
              else
                state = two;
            two:
              if (memoryAddress != previousAddress) 
                state = zero;
              else
                state = three;
            three:
              state = zero;
               //in the third cycle no cancelling
               //should be requested
          endcase
        else
          state = zero;
      end

endmodule
