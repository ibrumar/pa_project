/*
	ddavila: This module is used to achieve multi-writing in the Register File of the Reorder Buffer.
*/
module port_selector #(parameter ADDR_WIDTH=3, parameter LOG_PORT_NUM=2)(
	input[ADDR_WIDTH-1:0] addr_a,
	input[ADDR_WIDTH-1:0] addr_b,
	input[ADDR_WIDTH-1:0] addr_c,
	input we_a,
	input we_b,
	input we_c,
	
	input[ADDR_WIDTH-1:0] fixed_addr, //address of the register this module will work for

	//outputs
	output reg we_output,
	output reg[LOG_PORT_NUM-1:0]sel //address of the port that will be read (used as selector of multiplexor)
	

);

	always @(*)begin
		if(we_a==1 & addr_a==fixed_addr) begin
			we_output<=1'b1;
			sel<=2'b00; //select first port (port a)
		end
		else if(we_b==1 & addr_b==fixed_addr) begin
			we_output<=1'b1;
			sel<=2'b01; 
		     end
		else if(we_c==1 & addr_c==fixed_addr) begin
			we_output<=1'b1;
			sel<=2'b10;
		     end
		else begin
			we_output<=1'b0;
			sel<=2'b00;	
		end
	end

endmodule
  
