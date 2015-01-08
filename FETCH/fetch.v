module fetch
     #(parameter cache_line_width = 256,
      parameter word_width = 16,
      //in the data cache we will access not only
      //data with width 'word_width'
      parameter addr_width = 16,
      parameter num_cache_lines = 4)
(
  input [15:0]initial_inst_addr,  //fixed initial instruction address
  input [1:0]sel_pc,              //select the d input of pc register
  input [15:0]branch_pc,          // address to jump in a branch
    
  input clk,
  input enable_pc,
  input reset,

  //output[7:0]inst_code_high,  
  //output[7:0]inst_code_low
  output reg [15:0]inst_code
);

  wire [15:0]mux_out__pc_in;
  wire [15:0]pc_out__mem_in;
  wire isHit;
  wire serviceReadyArbCache;
  wire serviceReadyMemArb;
  wire [cache_line_width-1:0] dataMemCache;
  wire [addr_width-1:0] addrCacheArb;
  wire petitionCacheArb;
  wire petitionArbMem;
  wire [addr_width-1:0] addressArbMem;

  wire unconnectedReadyDataWire1;
  wire unconnectedReadyDataWire2;

  reg newEnablePC;

  wire [word_width-1:0] inst_code_from_cache;
  reg  petitionToCache;

  always @(*)
    begin
      if (reset == 0)
      begin
         newEnablePC <= enable_pc;
         inst_code <= inst_code_from_cache; //it doesn't matter
         petitionToCache <= 1'b0;
         //because the reset will put an 0 to the decode's register
      end
      if (!isHit)
      begin
         newEnablePC <= 1'b0;
         inst_code <= 4'h0000; //nop pushed towards following stages untill miss is served
         petitionToCache <= 1'b1;
      end
      else
      begin
         newEnablePC <= enable_pc; //it's an input
         inst_code <= inst_code_from_cache;
         petitionToCache <= 1'b1;
      end
    end

instr_cache my_instr_cache (
      .address(pc_out__mem_in),
      .clk(clk),
      .petFromProc(petitionToCache),
      .reset(reset),
      .memServiceReady(serviceReadyArbCache),
      .dataReadFromMem(dataMemCache),
      .instructionBits(inst_code_from_cache),
      .isHit(isHit),
      .addrToArb(addrCacheArb),
      .petitionToArb(petitionCacheArb)
);

arbiter my_arbiter
     (.addressInstr(addrCacheArb),
      .addressDat1(16'h0000),
      .addressDat2(16'h0002),
      .petitionInstr(petitionCacheArb),
      .petitionDat1(1'b0),
      .petitionDat2(1'b0),
      .serviceReady(serviceReadyMemArb),
      .serviceReadyInstr(serviceReadyArbCache),
      .serviceReadyDat1(unconnectedReadyDataWire1),
      .serviceReadyDat2(unconnectedReadyDataWire2),
      .petitionMem(petitionArbMem),
      .addressMem(addressArbMem)
      );

memory my_memory
     (.address(addressArbMem),
      .data_write(256'd0),
      .clk(clk),
      .we(1'b0),
      .reset(reset),
      .petition(petitionArbMem),
      .serviceReady(serviceReadyMemArb),
      //output reg [data_width-1:0] data_read_high,
      .data_read(dataMemCache));

//memory my_memory(
//  .address(pc_out__mem_in),
  //.data_read_high(inst_code_high),
//  .data_read(inst_code),
  //.data_read_low(inst_code_low),
//  .data_write_low(16'hxx),
//  .data_write_high(16'hxx),
//  .we(1'b0),
//  .clk(clk)
//);

mux4 my_mux(
  .a(initial_inst_addr), 
  .b(pc_out__mem_in+2'b01),
  .c(branch_pc),
  .d(16'h000),
  .sel(sel_pc),
  .out(mux_out__pc_in)
);

register my_pc(
  .clk(clk),
  .enable(newEnablePC),
  .reset(1'b1),
  .d(mux_out__pc_in),
  .q(pc_out__mem_in)
);


endmodule

