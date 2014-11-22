module memory_tb();
wire [7:0]data_read_high;
wire [7:0]data_read_low;
reg [7:0]data_write_high;
reg [7:0]data_write_low;
reg [15:0]address;
reg clock, we;

initial begin
  clock=1;
  we=0;
  /*
  address= 16'h00_00;
  data_write_high= 8'hFF;
  data_write_low= 8'hFF;
  #10 we=1;
  #10 we=0;
  
  #10 address= 16'h00_02;
  data_write_high= 8'hFE;
  data_write_low= 8'hFE;
  #10 we=1;
  #10 we=0;
  
  #10 address= 16'h00_04;
  data_write_high= 8'hFD;
  data_write_low= 8'hFD;
  #10 we=1;
  #10 we=0;
  
  #10 address= 16'h00_06;
  data_write_high= 8'hFC;
  data_write_low= 8'hFC;
  #10 we=1;
  #10 we=0;

  #20 address= 16'h00_00;  
  #20 address= 16'h00_02;
  #20 address= 16'h00_04;
  #20 address= 16'h00_06;
*/

  #20 address= 16'h00_0C;  
  #20 address= 16'h00_0D;
  #20 address= 16'h00_0E;
  #20 address= 16'h00_0F;
  #20 address= 16'h00_10;
  #20 address= 16'h00_11;
end

always begin
  #5 clock=~clock;
end

memory my_memory(
.clk(clock),
.we(we),
.data_write_high(data_write_high),
.data_write_low(data_write_low),
.data_read_high(data_read_high),
.data_read_low(data_read_low),
.address(address)
);

endmodule



