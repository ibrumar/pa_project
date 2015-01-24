module fetch
     #(parameter cache_line_width = 256,
      parameter word_width = 16,
      //in the data cache we will access not only
      //data with width 'word_width'
      parameter addr_width = 16,
      parameter num_cache_lines = 4,
      parameter num_phys_bits   = 7 //page of 128B = 1 cache line
    )
(
  input [15:0]initial_inst_addr,  //fixed initial instruction address
  input [1:0]sel_pc,              //select the d input of pc register
  input [15:0]branch_pc,          // address to jump in a branch
    
  input clk,
  input enable_pc,
  input reset,

  //memory stuff

  input                         serviceReadyArbCache,
  input  [cache_line_width-1:0] dataMemCache,
  output [addr_width-1:0]       addrCacheArb,
  output                        petitionCacheArb,

  //output[7:0]inst_code_high,  
  //output[7:0]inst_code_low
  output reg [15:0]inst_code
);

  wire [15:0]mux_out__pc_in;
  wire [15:0]pc_out__mem_in;
  wire isHit;

  reg newEnablePC;

  wire [word_width-1:0] inst_code_from_cache;
  reg  petitionToCache;

  wire [8:0] physical_pc;
  wire       tlb_hit;

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
      .virt_address(pc_out__mem_in),
      .phys_address(physical_pc),
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

itlb   my_itlb (
      .clk(clk),
      .reset(reset),
      .virtualAddress(pc_out__mem_in[15:6]),
      .physicalAddress(physical_pc),
      .isHit(tlb_hit)
);

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

