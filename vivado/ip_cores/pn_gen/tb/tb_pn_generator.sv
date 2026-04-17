`default_nettype none
`timescale 1ns / 1ps
module tb_pn_generator ();
	//Parameters
	parameter real 	SYS_CLK_MHZ = 125.000;
	parameter 		OS 		 	= 1;
	parameter       SEED_DEFAULT = 27;
	
	parameter S_AXI_ADDR_WIDTH = 5;
    parameter S_AXI_DATA_WIDTH = 32;

	//Local parameters
	localparam real	PERIOD  	= 1000.0 / SYS_CLK_MHZ;
	localparam 		WIDTH_OS	= $clog2(OS);

	reg 				clk, resetn;
	wire 				q;
	wire 				q_valid;
	reg [4:0]			counter_q 	= 0;
	wire [3:0]	        over_sampling = dut.over_sampling;
	
	reg [S_AXI_DATA_WIDTH-1:0] bfm_read;


	always @(posedge clk) begin
        if (resetn) begin
            if ( dut.over_sampling == dut.os_init && dut.q_valid) begin
                if (counter_q % 31 == 0) begin
                    counter_q <= 1;
                end
                else begin
                    counter_q <= counter_q + 1;
                end

            end
        end
    end
	pn_generator 
	   #(
	   	.OS(OS),
	   	.SEED_DEFAULT(SEED_DEFAULT)
		)
	dut (
		.clk  		(clk 	     ),
		.resetn		(resetn 	     ),
		.q_valid	(q_valid     ),
		.q    		(q 		     ),
		
        .s_axi      (axi_if.slave)
		);
    
    //Interface axi4_lite
    axi4_lite_if #(
        .S_AXI_ADDR_WIDTH(S_AXI_ADDR_WIDTH),
        .S_AXI_DATA_WIDTH(S_AXI_DATA_WIDTH)
    ) axi_if (
        .clk(clk),
        .resetn(resetn)
    );
    
    AXI4_LITE_M_BFM # (
        .S_AXI_ADDR_WIDTH(S_AXI_ADDR_WIDTH),
        .S_AXI_DATA_WIDTH(S_AXI_DATA_WIDTH)
    )
    bfm (
        .clk(clk),
        .resetn(resetn),
        .bus_if(axi_if.master)
    );
	//create clock
	always #PERIOD clk <= ~clk;

	initial begin
		$monitor("t=%.2t ns, shift_register=%b, xor_sreg=%b", $realtime / 1000.0, dut.shift_register, dut.xor_sreg);
		clk = 0;
		resetn = 0;
		#200
		resetn = 1; 
		#500
		bfm.axi4_read(5'h0, bfm_read);
		bfm.axi4_write(5'h1, 32'h0000_041F);
		#100
		bfm.axi4_read(5'h0, bfm_read);
		bfm.axi4_write(5'h0, 32'h0000_0000);
		bfm.axi4_read(5'h0, bfm_read);
		bfm.axi4_read(5'h1, bfm_read);
		#500
		$finish;
	end
	

endmodule
`default_nettype wire