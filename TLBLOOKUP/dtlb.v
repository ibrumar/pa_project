module dtlb
     #(parameter cache_line_width = 256,
      parameter word_width = 16,
      //in the data cache we will access not only
      //data with width 'word_width'
      parameter addr_width = 16,
      parameter num_tlb_lines = 4,
      parameter tag_bits_per_addr = 9
      //the page size is equal to the cache size
      //i.e. 128B
      )  
      (
      //inputs from processor
      input                         clk,
      input                         reset,
      input                         isWordAccess,
      input  [addr_width-8:0]       virtualAddress0, //page size is 128B = 64 Words
      input  [addr_width-8:0]       virtualAddress1, //page size is 128B = 64 Words
      output reg [addr_width-8:0]   physicalAddress0, //ten upper bits. First one is 0
      output reg [addr_width-8:0]   physicalAddress1, //ten upper bits. First one is 0
      output                        isHit,
      output [addr_width-8:0]       offendingAddress //it's the virtual addr causing the
    );                                               //iTLB miss.
    
    reg  [num_tlb_lines-1:0] enable_tlb_write;
    wire [num_tlb_lines-1:0] valid_tlb_line_read;
    reg  [num_tlb_lines-1:0] valid_tlb_line_enable_write;
    reg  [num_tlb_lines-1:0] valid_tlb_value;
   
    reg  [tag_bits_per_addr-1:0] d_physical[0:num_tlb_lines-1];
    wire [tag_bits_per_addr-1:0] q_physical[0:num_tlb_lines-1];


    reg  [tag_bits_per_addr-1:0] d_virtual[0:num_tlb_lines-1];
    wire [tag_bits_per_addr-1:0] q_virtual[0:num_tlb_lines-1];

    reg isHit0;
    reg isHit1;

    assign isHit = isHit0 && (!isWordAccess || isHit1);
    wire [addr_width-8:0] concatAddrs [0:1];
    assign concatAddrs[0] = virtualAddress0;
    assign concatAddrs[1] = virtualAddress1;
    //if we miss in the tlb in both addresses, the first one is considered the
    //offending one. If the accesses were a hit, the offending address will be
    //ignored however.
    assign offendingAddress = concatAddrs[isHit0];
    
    always @(*) begin
       if (q_virtual[0] == virtualAddress0 && valid_tlb_line_read[0] == 1)
       begin
         physicalAddress0 <= q_physical[0];
         isHit0 <= 1'b1;
       end
       else if (q_virtual[1] == virtualAddress0 && valid_tlb_line_read[1] == 1)
       begin
         physicalAddress0 <= q_physical[1];
         isHit0 <= 1'b1;
       end
       else if (q_virtual[2] == virtualAddress0 && valid_tlb_line_read[2] == 1)
       begin
         physicalAddress0 <= q_physical[2];
         isHit0 <= 1'b1;
       end
       else if (q_virtual[3] == virtualAddress0 && valid_tlb_line_read[3] == 1)
       begin
         physicalAddress0 <= q_physical[3];
         isHit0 <= 1'b1;
       end
       else begin
         physicalAddress0 <= 9'bxxxxxxxxx;
         isHit0 <= 1'b0;
       end

       if (q_virtual[0] == virtualAddress1 && valid_tlb_line_read[0] == 1)
       begin
         physicalAddress1 <= q_physical[0];
         isHit1 <= 1'b1;
       end
       else if (q_virtual[1] == virtualAddress1 && valid_tlb_line_read[1] == 1)
       begin
         physicalAddress1 <= q_physical[1];
         isHit1 <= 1'b1;
       end
       else if (q_virtual[2] == virtualAddress1 && valid_tlb_line_read[2] == 1)
       begin
         physicalAddress1 <= q_physical[2];
         isHit1 <= 1'b1;
       end
       else if (q_virtual[3] == virtualAddress1 && valid_tlb_line_read[3] == 1)
       begin
         physicalAddress1 <= q_physical[3];
         isHit1 <= 1'b1;
       end
       else begin
         physicalAddress1 <= 9'bxxxxxxxxx;
         isHit1 <= 1'b0;
       end
    end

    always @(posedge clk) begin
      if (reset) begin
        //only two pages will be translated
        enable_tlb_write[0] <= 1'b1; 
        enable_tlb_write[1] <= 1'b1;
        enable_tlb_write[2] <= 1'b0; 
        enable_tlb_write[3] <= 1'b0;

        //Instructions virtually start at byte 1024
        //but are mapped to addresses begining with
        //byte 0. First instruction is virtually
        //1024 + c = 1036 = 0x040c
        d_virtual[0]  <= 9'b000010000; //0x0800 without first 7 bits
        //d_physical[0] <= 9'b000001000; //0x0400
        d_physical[0] <= 9'b000000000; //0x0000
        d_virtual[1]  <= 9'b000010001; //0x0880
        d_physical[1] <= 9'b000001001; //0x0480

        //the validity has to be set for
        //all pages in the tlb
        valid_tlb_line_enable_write[0] <= 1'b1; 
        valid_tlb_line_enable_write[1] <= 1'b1;
        valid_tlb_line_enable_write[2] <= 1'b1; 
        valid_tlb_line_enable_write[3] <= 1'b1;

        valid_tlb_value[0] <= 1'b1;
        valid_tlb_value[1] <= 1'b1;
        valid_tlb_value[2] <= 1'b0;
        valid_tlb_value[3] <= 1'b0;
      end 
      else begin
        //until tlbwrite is implemented,
        //the tlb cannot be written
        enable_tlb_write[0] <= 1'b0; 
        enable_tlb_write[1] <= 1'b0;
        enable_tlb_write[2] <= 1'b0; 
        enable_tlb_write[3] <= 1'b0;     

        valid_tlb_line_enable_write[0] <= 1'b1; 
        valid_tlb_line_enable_write[1] <= 1'b1;
        valid_tlb_line_enable_write[2] <= 1'b1; 
        valid_tlb_line_enable_write[3] <= 1'b1;
      end
    end

    genvar i;

    generate
    for (i=0; i<num_tlb_lines; i=i+1)
      begin: gen_tlb_valid_line
        register #(1) valid_tlb_entry_register(.clk(clk),
                           .enable(valid_tlb_line_enable_write[i]), 
                           .reset(1'b1),
                           .d(valid_tlb_value[i]),
                           .q(valid_tlb_line_read[i]));
      end
    endgenerate


    generate
    for (i=0; i<num_tlb_lines; i=i+1)
      begin: gen_tlb_line_virt
        register #(tag_bits_per_addr) virtual_addr_register(.clk(clk),
                           .enable(enable_tlb_write[i]), 
                           .reset(1'b1),
                           .d(d_virtual[i]),
                           .q(q_virtual[i]));
      end
    endgenerate


    generate
    for (i=0; i<num_tlb_lines; i=i+1)
      begin: gen_tlb_line_phys
        register #(tag_bits_per_addr) phys_addr_register(.clk(clk),
                           .enable(enable_tlb_write[i]), 
                           .reset(1'b1),
                           .d(d_physical[i]),
                           .q(q_physical[i]));
      end
    endgenerate



endmodule
