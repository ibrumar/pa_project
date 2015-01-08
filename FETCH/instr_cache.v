module instr_cache
     #(parameter cache_line_width = 256,
      parameter word_width = 16,
      //in the data cache we will access not only
      //data with width 'word_width'
      parameter addr_width = 16,
      parameter num_cache_lines = 4)
     (
      //inputs from processor
      input  [addr_width-1:0]       address,
      input                         clk,
      input                         reset,
      input                         petFromProc,

      //inputs from arbiter
      input                         memServiceReady,

      //input from memory
      input [cache_line_width-1:0]  dataReadFromMem,
      
      //output to processor
      output [word_width-1:0] instructionBits,
      output                  isHit,
      
      //output to arbitrer
      output [addr_width-1:0] addrToArb, //we keep this
                                         //to be consistent
                                         //with the data cache
      output                  petitionToArb
      );


   //General

   assign addrToArb = address;
   wire canWriteCache = !isHit && memServiceReady && petFromProc;
   wire [num_cache_lines-1:0] canWriteExtended = {num_cache_lines{canWriteCache}};
   reg [num_cache_lines-1:0] decodedLine; //decoder
   wire [num_cache_lines-1:0] enableBits = canWriteExtended&decodedLine;

   //Validity bits
   //line is written
   wire [num_cache_lines-1:0] validityBits;
   wire validLine = validityBits[address[5:4]];

   //DATA
      //this wires come from the data lines (registers of 256 bits)
   wire [cache_line_width-1:0] dataLines [0:num_cache_lines-1];

   wire [word_width-1:0] selectedLine [0:15];
   assign instructionBits = selectedLine[address[3:0]];
                                    
   
  //TAGS
  wire [addr_width-7:0] tagCables [0:num_cache_lines-1];
  wire [addr_width-7:0] selectedTagCables = tagCables[address[5:4]];

  always @(*)
    begin
      case (address[5:4]) //those bits are the cache line
      2'b00:
        decodedLine <= 4'b0001;

      2'b01:
        decodedLine <= 4'b0010;

      2'b10:
        decodedLine <= 4'b0100;
      
      2'b11:
        decodedLine <= 4'b1000;
      endcase
    end

  genvar i;
  generate
    for (i=0; i<num_cache_lines; i=i+1)
      begin: gen_register
        register #(cache_line_width) data_register(.clk(clk),
                           .enable(enableBits[i]),
                           .reset(reset),
                           .d(dataReadFromMem),
                           .q(dataLines[i]));
      end
  endgenerate

  generate
    for (i=0; i<num_cache_lines; i=i+1)
      begin: gen_valid_register
        register #(1) validity_register(.clk(clk),
                           .enable(enableBits[i]), 
                           .reset(reset),
                           .d(1'b1),
                           .q(validityBits[i]));
      end
  endgenerate


  generate
    for (i=0; i<num_cache_lines; i=i+1)
      begin: gen_tag_register
        register #(10) tag_register(.clk(clk),
                           .enable(enableBits[i]), 
                           .reset(reset),
                           .d(address[addr_width-1:6]),
                           .q(tagCables[i]));
      end
  endgenerate



  assign isHit = validLine && (selectedTagCables == address[addr_width-1:6]);

  assign petitionToArb = !isHit && petFromProc;

  assign selectedLine[0]  = dataLines[address[5:4]][15:0];
  assign selectedLine[1]  = dataLines[address[5:4]][31:16];
  assign selectedLine[2]  = dataLines[address[5:4]][47:32];
  assign selectedLine[3]  = dataLines[address[5:4]][63:48];
  assign selectedLine[4]  = dataLines[address[5:4]][79:64];
  assign selectedLine[5]  = dataLines[address[5:4]][95:80];
  assign selectedLine[6]  = dataLines[address[5:4]][111:96];
  assign selectedLine[7]  = dataLines[address[5:4]][127:112];
  assign selectedLine[8]  = dataLines[address[5:4]][143:128];
  assign selectedLine[9]  = dataLines[address[5:4]][159:144];
  assign selectedLine[10] = dataLines[address[5:4]][175:160];
  assign selectedLine[11] = dataLines[address[5:4]][191:176];
  assign selectedLine[12] = dataLines[address[5:4]][207:192];
  assign selectedLine[13] = dataLines[address[5:4]][223:208];
  assign selectedLine[14] = dataLines[address[5:4]][239:224];
  assign selectedLine[15] = dataLines[address[5:4]][255:240];


endmodule
