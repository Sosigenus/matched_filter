`default_nettype none
`timescale 1ns / 1ps
module pn_generator # 
(
	parameter OS 			= 4,
	parameter SEED_DEFAULT	= 5'b11111
)
(
	input 	wire clk,
	input 	wire rst_n,

	output  wire q_valid,
	output 	wire q
);
/*
[5 3 0]
2^5 -1 = 31
z^5 + z^3 + 1 
[1 0 1 0 0]
*/
	//localparams
	localparam WIDTH_OS = $clog2(OS);

	//
	reg [4:0] 			shift_register;
	reg 				valid; 
	reg 				q_reg;
	reg [WIDTH_OS:0]	over_sampling;
	wire 				xor_sreg;

	//Calc comb logic
	assign xor_sreg = shift_register[4] ^ shift_register[2];

	//Calc sequence logic
	always @(posedge clk or negedge rst_n) begin : proc_q
		if(~rst_n) begin
			shift_register 	<= SEED_DEFAULT;
			valid 			<= 1'b0;
			over_sampling	<= OS-1;
		end else begin
			if (over_sampling == OS-1) begin
				shift_register 	<= {shift_register[3:0], xor_sreg};
				q_reg 			<= shift_register[4];
				valid 			<= 1'b1;
				over_sampling	<= 4'b0;
			end
			else begin
				over_sampling 	<=  over_sampling + 1;
			end
		end
	end

	//Output assignment
	assign q 		= q_reg;
	assign q_valid 	= valid;
endmodule : pn_generator