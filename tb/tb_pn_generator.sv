`timescale 1ns / 1ps
module tb_pn_generator ();
	//Parameters
	parameter real 	SYS_CLK_MHZ = 125.000;
	parameter 		OS 		 	= 4;

	//Local parameters
	localparam real	PERIOD  	= 1000.0 / SYS_CLK_MHZ;
	localparam 		WIDTH_OS	= $clog2(OS);

	reg 				clk, rst_n;
	wire 				q;
	wire 				q_valid;
	reg [4:0]			counter_q 	= 0;
	reg [WIDTH_OS-1:0]	over_sampling;


	initial begin
		forever begin
			@(posedge clk);
			if (rst_n) begin
				if (dut.over_sampling == OS-1) begin

					if (counter_q % 31 == 0) begin
						counter_q = 1;
					end
					else begin
						counter_q = counter_q + 1;
					end

				end
			end
			
		end
	end

	pn_generator 
	   #(
	   	.OS(OS)
		)
	dut (
		.clk  		(clk 	 ),
		.rst_n		(rst_n 	 ),
		.q_valid	(q_valid ),
		.q    		(q 		 )
		);

	//create clock
	always #PERIOD clk <= ~clk;

	initial begin
		$monitor("t=%.2t ns, shift_register=%b, xor_sreg=%b", $realtime / 1000.0, dut.shift_register, dut.xor_sreg);
		clk = 0;
		rst_n = 0;
		#20
		rst_n = 1; 
		#500
		$finish;
	end 
	

endmodule : tb_pn_generator
