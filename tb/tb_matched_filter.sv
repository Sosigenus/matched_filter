`default_nettype none
`timescale 1ns / 1ps
module tb_matched_filter();
	
	parameter		SYS_CLK_MHZ		= 125.000;
	localparam		PERIOD			= 1000.0 / SYS_CLK_MHZ;

	parameter int 	AMOUNT_COEF 	= 16;
    parameter int 	DATA_WIDTH   	= 12;
    parameter int 	COEF_WIDTH		= 12;
    parameter int 	ACC_WIDTH 		= DATA_WIDTH + COEF_WIDTH + $clog2(AMOUNT_COEF);

    reg clk, rst_n;

    reg		signed	[DATA_WIDTH-1:0]	din;
    reg 								din_valid;

    wire	signed	[ACC_WIDTH-1:0]		dout;
    wire								dout_valid;

    matched_filter #(
    	.AMOUNT_COEF(AMOUNT_COEF),
    	.DATA_WIDTH (DATA_WIDTH),
    	.COEF_WIDTH (COEF_WIDTH),
    	.ACC_WIDTH  (ACC_WIDTH)
	) mtd_filter_inst
	(
		.clk       (clk),
		.rst_n     (rst_n),

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
	        @(negedge clk);
	        din       <= const_data_queue.pop_front();
	        din_valid <= 1;

	        cnt = cnt - 1;
	    end

	    @(negedge clk);
	    din_valid <= 0;
	endtask

	//send 
	task send_random(input int number);
		int cnt;
		cnt = number;
		while (cnt > 0) begin
			@(negedge clk);
			din 		<= $urandom_range(0,1);
			din_valid	<= 1'b1;

			cnt 		= cnt - 1;
		end
		@(negedge clk);
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

	task automatic generate_pn_sequence(input int length);
    pn_state_t state = 5'b11111; 
    for(int i = 0; i < length; i++) begin
        bit pn_bit;
        pn_bit = pn_next(state);
        add_const_data(pn_bit);
    end
	endtask
	//....................................................
	//....................................................
	//....................................................

	//golden model matched_filter
	//....................................................
	//....................................................
	//....................................................
	int golden_delay [$];
	int golden_queue [$];
	int coef;
	int acc;
	reg	signed	[ACC_WIDTH-1:0]		expected;
	reg	signed	[ACC_WIDTH-1:0]		gold;
	function automatic int golden_matched(int sample);

	    acc = 0;

	    golden_delay.push_front(sample);

	    if(golden_delay.size() > AMOUNT_COEF)
	        void'(golden_delay.pop_back());

	    for(int i=0;i<golden_delay.size();i++) begin
	        coef = (i % 2 == 0) ? 1 : -1;
	        acc += golden_delay[i] * coef;
	    end

	    return acc;
	endfunction

	always @(posedge clk) begin
	    if(din_valid) begin
		    gold = golden_matched(din[0] ? -1 : 1);
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
		rst_n 		= 0;
		din_valid 	= 0;
		din 		= 0;
		#20
		@(posedge clk);
		rst_n 	= 1;
	end

	initial begin
		wait(rst_n);
		//add_const_data(16'hBEEF);
		//add_const_data(16'hA55A);
		//send_random(16'h000F);
		generate_pn_sequence(32);
		debug_print_queue();
		send_const_queue(0);
	end

endmodule