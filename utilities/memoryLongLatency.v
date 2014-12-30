module memory
    #(parameter data_width = 16,
      parameter addr_width = 16)
     (input  [addr_width-1:0] address,
      input  [data_width-1:0] data_write_high,
      input  [data_width-1:0] data_write_low,
      input                   clk,
      input                   we,
      input                   reset,
      output reg              serviceReady,
      //output reg [data_width-1:0] data_read_high,
      output reg [data_width-1:0] data_read);

    reg [data_width-1:0] mem [0:(2**addr_width)-1];
    reg [1:0] state;

/*    always @(posedge clk) begin : write_proc
        if (we == 1)begin
            mem[address] = data_write_high;
            mem[address+1] = data_write_low;
        end
    end
*/

    always @(*) begin : read_proc
        data_read = mem[address];
        //data_read_low = mem[address+1];
    end

    parameter zero=0, one=1, two=2, three=3;

//se necesita implementar un registro de cambio de dirección
//nos servira para cambiar de dirección. De otra manera podemos
//dar xxxx para los ciclos cuando no se leen datos utiles.
    always @(state) 
         begin
              case (state)
                   zero:
                        serviceReady = 1'b0;

                   one:
                        serviceReady = 1'b0;
                   two:
                        serviceReady = 1'b0;
                   three:
                        serviceReady = 1'b1;
                        data_read = mem[previousAddress];
                   default:
                        serviceReady = 1'b0;

              endcase
         end

    always @(posedge clk or posedge reset or address)
         begin
              if (reset)
                   state = zero;
              else
                   case (state)
                        zero:
                             if (currentAddress != previousAddress) 
                                state = zero;
                             else
                                state = one;
                        one:
                             if (currentAddress != previousAddress) 
                                state = zero;
                             else
                                state = two;
                        two:
                             if (currentAddress != previousAddress) 
                                state = zero;
                             else
                                state = three;
                        three:
                            state = one;
                            //in the third cycle no cancelling
                            //should be requested
                   endcase
         end


endmodule

