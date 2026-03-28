`default_nettype none
`timescale 1ns / 1ps
module matched_filter #(
    parameter int AMOUNT_COEF 	= 16,
    parameter int DATA_WIDTH   	= 12,
    parameter int COEF_WIDTH	= 12,
    parameter int ACC_WIDTH 	= DATA_WIDTH + COEF_WIDTH + $clog2(AMOUNT_COEF)
    
)(
    input  wire clk,
    input  wire rst_n,

    input  wire signed [DATA_WIDTH-1:0]	din,
    input  wire                    		din_valid,

    output wire signed [ACC_WIDTH-1:0]	dout,
    output wire							dout_valid
);

    logic signed [COEF_WIDTH-1:0] coef [0:AMOUNT_COEF-1];
	initial begin
        for(int i = 0; i < AMOUNT_COEF; i = i + 1)
        	coef[i] = (i % 2 == 0)? 1 : -1;
		//$readmemh("coeff.mem", coef);
	end

	wire  signed [DATA_WIDTH-1:0] din_translate = din[0] ? {DATA_WIDTH{1'b1}} : {{DATA_WIDTH-1{1'b0}}, 1'b1};

    logic signed [DATA_WIDTH-1:0] delay [0:AMOUNT_COEF-1];

    always_ff @(posedge clk) begin
    	if (!rst_n) begin
    		for (int i = 0; i < AMOUNT_COEF; i = i + 1) begin
    			delay[i] <= 0;
    		end
    	end
    	else begin
            delay[0] <= din_valid ? din_translate : 0;
	        for(int i = 1; i < AMOUNT_COEF; i = i + 1) begin
	            delay[i] <= delay[i-1];
	        end
        end
    end

    //stage 1
    logic signed [DATA_WIDTH+COEF_WIDTH-1:0] prod [0:AMOUNT_COEF-1];

    always_ff @(posedge clk) begin
        if(!rst_n)
            for(int i=0;i<AMOUNT_COEF; i = i + 1) begin
                prod[i] <= 0;
            end
        else begin
            for(int i=0;i<AMOUNT_COEF; i = i + 1) begin
                prod[i] <= delay[i] * coef[i];
            end
        end
    end



    localparam int STAGES = $clog2(AMOUNT_COEF);

    // tree storage
    logic signed [ACC_WIDTH-1:0]
        sum_stage [0:STAGES][0:AMOUNT_COEF-1];

    // level 0
    always_ff @(posedge clk) begin
        if(!rst_n)
            for(int i=0; i < AMOUNT_COEF; i = i + 1)
                sum_stage[0][i] <= '0;
        else
            for(int i=0; i < AMOUNT_COEF; i = i + 1)
                sum_stage[0][i] <= prod[i];
    end

    // level 1..STAGES-1
    generate
        for(genvar s = 0; s < STAGES; s = s + 1) begin : TREE_STAGE
            localparam int ELEMS = AMOUNT_COEF >> (s+1);

            for(genvar i=0; i < ELEMS; i = i + 1) begin : ADD
                always_ff @(posedge clk) begin
                    if(!rst_n)
                        sum_stage[s+1][i] <= '0;
                    else
                        sum_stage[s+1][i] <=
                            sum_stage[s][2*i]
                          + sum_stage[s][2*i+1];
                end
            end

            // dragging an odd element
            if((AMOUNT_COEF >> s) % 2) begin : ODD_PASS
                always_ff @(posedge clk) begin
                    if(!rst_n)
                        sum_stage[s+1][ELEMS] <= '0;
                    else
                        sum_stage[s+1][ELEMS]
                            <= sum_stage[s][AMOUNT_COEF>>(s) - 1];
                end
            end
        end
    endgenerate

    assign dout = sum_stage[STAGES][0];

    //valid
    localparam int LATENCY = STAGES + 3;

    logic [LATENCY-1:0] valid_pipe;

    always_ff @(posedge clk) begin
        if(!rst_n) begin
            valid_pipe <= '0;
        end
        else begin
            valid_pipe <= {valid_pipe[LATENCY-2:0], din_valid};
        end
    end

    assign dout_valid = valid_pipe[LATENCY-1];

endmodule