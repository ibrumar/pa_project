module alu #(parameter INPUT_WIDTH=16)(
  input unsigned [INPUT_WIDTH-1:0]reg_A,
  input unsigned [INPUT_WIDTH-1:0]reg_B,
  input [3:0] cop,
  
  
  output [INPUT_WIDTH-1:0]result,
  output OVF
);

wire unsigned [INPUT_WIDTH:0] aux_reg_A=reg_A;
wire unsigned [INPUT_WIDTH:0] aux_reg_B=reg_B;
reg unsigned [INPUT_WIDTH:0] result_aux;

assign result= result_aux[INPUT_WIDTH-1:0];
assign OVF= result_aux[INPUT_WIDTH];


always @(*)
  begin
    case(cop)
      4'b0000 : result_aux=0;
      4'b0001 : result_aux=aux_reg_A + aux_reg_B;
      4'b0010 : result_aux=aux_reg_A - aux_reg_B;
      4'b0011 : result_aux=aux_reg_B;
      4'b0100 : if(aux_reg_A == aux_reg_B)begin
                  result_aux=1;
                end else begin
                  result_aux=0;
                end
      //just to test
      4'b0110 : result_aux= aux_reg_A + aux_reg_B; 
      4'b0111 : result_aux= aux_reg_A + aux_reg_B; 
      default : result_aux= 16'hx;
    endcase
  end

  
endmodule