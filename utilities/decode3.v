module decode3
( 
input writeEnable,
input [2:0] d,
output reg [7:0] q
);

always @(*)
begin
  if (writeEnable == 0)
    begin
      q = 2'h00;
    end
  else
    begin
      case(d)
        3'b000: q <= 8'b00000001;
        3'b001: q <= 8'b00000010;
        3'b010: q <= 8'b00000100;
        3'b011: q <= 8'b00001000;
        3'b100: q <= 8'b00010000;
        3'b101: q <= 8'b00100000;
        3'b110: q <= 8'b01000000;
        3'b111: q <= 8'b10000000;
        default: q <= 8'b00000000;
      endcase
    end
end

endmodule