module memory
    #(parameter data_width = 16,
      parameter addr_width = 16)
     (input  [addr_width-1:0] address,
      input  [data_width-1:0] data_write_high,
      input  [data_width-1:0] data_write_low,
      input                   clk,
      input                   we,
      //output reg [data_width-1:0] data_read_high,
      output reg [data_width-1:0] data_read);

    reg [data_width-1:0] mem [0:(2**addr_width)-1];

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

endmodule

