`default_nettype none
`timescale 1ns / 1ps
module tb_matched_filter();
	
	parameter		SYS_CLK_MHZ		= 125.000;
	localparam		PERIOD			= 1000.0 / SYS_CLK_MHZ;
	
	parameter       S_AXI_ADDR_WIDTH = 7;
	parameter       S_AXI_DATA_WIDTH = 32;

	parameter 	    AMOUNT_COEF 	= 16;
    parameter    	DATA_WIDTH   	= 32;

    localparam PROD_WIDTH = DATA_WIDTH + DATA_WIDTH;
	localparam ACC_WIDTH = PROD_WIDTH + $clog2(AMOUNT_COEF);
	
    reg signed  [ACC_WIDTH-1:0] acc = 0;
    reg signed  [DATA_WIDTH-1:0]  coef_val;
	reg	signed	[ACC_WIDTH-1:0] expected;
	reg	signed	[ACC_WIDTH-1:0] gold;
	
	reg [S_AXI_DATA_WIDTH-1:0] reg_data;
	
    reg clk, resetn;

    reg		signed	[DATA_WIDTH-1:0]	din;
    reg 								din_valid;

    wire	signed	[ACC_WIDTH-1:0]		dout;
    wire					                        dout_valid;

    //Interface axi4_lite
    axi4_lite_if #(
        .S_AXI_ADDR_WIDTH(S_AXI_ADDR_WIDTH),
        .S_AXI_DATA_WIDTH(S_AXI_DATA_WIDTH)
    ) axi_if (
        .clk(clk),
        .resetn(resetn)
    );
    
    //Init bfm
        AXI4_LITE_M_BFM # (
        .S_AXI_ADDR_WIDTH(S_AXI_ADDR_WIDTH),
        .S_AXI_DATA_WIDTH(S_AXI_DATA_WIDTH)
    )
    bfm (
        .clk(clk),
        .resetn(resetn),
        .bus_if(axi_if.master)
    );
    
    matched_filter #(
        .S_AXI_DATA_WIDTH   (S_AXI_DATA_WIDTH),
        .S_AXI_ADDR_WIDTH   (S_AXI_ADDR_WIDTH),
        
        
    	.AMOUNT_COEF        (AMOUNT_COEF),
    	.DATA_WIDTH         (DATA_WIDTH)
	) mtd_filter_inst
	(
		.clk       (clk),
		.resetn    (resetn),
		
		.s_axi     (axi_if.slave),

		.din       (din),
		.din_valid (din_valid),

		.dout      (dout),
		.dout_valid(dout_valid)
	);

	//
	reg [DATA_WIDTH-1:0] const_data_queue [$];

	//write data to queue-array
	function void add_const_data(reg [DATA_WIDTH-1:0] data);
		const_data_queue.push_back(data);
	endfunction

	//send queue-array to matched_filter
	task send_const_queue(input int number);
	/*
		0 	- Infinity mode, while queue no empty
		>0 	- Limit mode, if queue no empty
	*/
	int cnt;

		if (const_data_queue.size() == 0) begin
	        $display("Warning: const_data_queue is empty!");
	        return;
	    end

		if (number == 0) begin
			cnt = const_data_queue.size();
		end
		else begin
			cnt = number;
		end

		while ((const_data_queue.size() > 0) && (cnt > 0)) begin
	        @(posedge clk);
	        din       <= const_data_queue.pop_front();
	        din_valid <= 1;

	        cnt = cnt - 1;
	    end

	    @(posedge clk);
	    din_valid <= 0;
	endtask

	//send 
	task send_random(input int number);
		int cnt;
		cnt = number;
		while (cnt > 0) begin
			@(posedge clk);
			din 		<= $urandom_range(0,1);
			din_valid	<= 1'b1;

			cnt 		= cnt - 1;
		end
		@(posedge clk);
		din_valid <= 0;
	endtask 

	task debug_print_queue();
	    $display("Queue size: %0d", const_data_queue.size());
	    for (int i = 0; i < const_data_queue.size(); i++) begin
	        $display("queue[%0d] = 0x%h", i, const_data_queue[i]);
	    end
	endtask

	//golden model pn_generator
	//....................................................
	//....................................................
	//....................................................

	typedef bit [4:0] pn_state_t;
	function automatic bit pn_next(ref pn_state_t state);

	    bit feedback;
    	$display("state: 0x%h", state);
	    // taps: [5,3]
	    feedback = state[4] ^ state[2];

	    pn_next = state[4];      // output bit

	    state = {state[3:0], feedback};

	endfunction

    bit pn_bit;
	task automatic generate_pn_sequence(input int length);
    pn_state_t state = 5'b11111; 
    for(int i = 0; i < length; i++) begin
        
        pn_bit = pn_next(state);
        add_const_data(pn_bit);
        //add_const_data((i % 2 == 0) ? 32'h00000001 : 32'h00000000); 
    end
	endtask
	//....................................................
	//....................................................
	//....................................................

	//golden model matched_filter
	//....................................................
	//....................................................
	//....................................................
	reg signed [DATA_WIDTH-1:0] golden_delay [$];
	reg signed [ACC_WIDTH-1:0] golden_queue [$];
	int coef;
	
	
    function automatic reg signed [ACC_WIDTH-1:0] golden_matched(reg signed [DATA_WIDTH-1:0] sample);
        acc = 0;
        
        golden_delay.push_front(sample);
        if(golden_delay.size() > AMOUNT_COEF)
            void'(golden_delay.pop_back());
        
        for(int i = 0; i < golden_delay.size(); i++) begin
            //coef_val = (i % 2 == 0) ? {DATA_WIDTH{1'b1}} : {{DATA_WIDTH-1{1'b0}}, 1'b1};
            coef_val = (i % 2 == 0) ? {{DATA_WIDTH-1{1'b0}}, 1'b1} : {DATA_WIDTH{1'b1}};
            acc = acc + golden_delay[i] * coef_val;
        end
        
        return acc;
    endfunction
    

	always @(posedge clk) begin
	    if(din_valid) begin
		    gold = golden_matched(din[0] ? {DATA_WIDTH{1'b1}} : {{DATA_WIDTH-1{1'b0}}, 1'b1});
		    golden_queue.push_back(gold);
	    end

	    if(dout_valid) begin
	    assert(golden_queue.size() > 0)
	        else $fatal("Golden queue empty!");

	    expected = golden_queue.pop_front();

	    assert(dout == expected)
	        else $fatal("Mismatch! dout=%0d expected=%0d", dout, expected);
		end
	end

	//....................................................
	//....................................................
	//....................................................

	//Initial design
	always #PERIOD clk <= ~clk;
	initial begin
		clk 		= 0;
		resetn 		= 0;
		din_valid 	= 0;
		din 		= 0;
		#20
		@(posedge clk);
		resetn 	= 1;
	end

    reg signed [DATA_WIDTH-1:0] coef_reg;
	initial begin
		wait(resetn);
	    bfm.axi4_write(7'h0, 32'h8000_0000);
	    #5
        for(int i = 0; i < AMOUNT_COEF; i = i + 1) begin
            //coef_reg = (i % 2 == 0) ? {DATA_WIDTH{1'b1}} : {{DATA_WIDTH-1{1'b0}}, 1'b1};
            coef_reg  = (i % 2 == 0) ? {{DATA_WIDTH-1{1'b0}}, 1'b1} : {DATA_WIDTH{1'b1}};
            bfm.axi4_write(i+1, coef_reg);
	    end
	    #5
	    bfm.axi4_write(7'h0, 32'h0000_0000);
	    #500
	    bfm.axi4_read(7'h2, reg_data);
	    bfm.axi4_read(7'h2, reg_data);
	    bfm.axi4_read(7'h3, reg_data);
	    bfm.axi4_read(7'h4, reg_data);
	    bfm.axi4_read(7'h5, reg_data);
	    bfm.axi4_read(7'h2, reg_data);
	    bfm.axi4_read(7'h1, reg_data);

		//add_const_data(16'hBEEF);
		//add_const_data(16'hA55A);
		//send_random(16'h000F);
		generate_pn_sequence(32);
		debug_print_queue();
		send_const_queue(0);
	end

endmodule