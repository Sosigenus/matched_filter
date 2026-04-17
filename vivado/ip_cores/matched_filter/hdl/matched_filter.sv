`default_nettype none
`timescale 1ns / 1ps
module matched_filter #(
    parameter S_AXI_DATA_WIDTH         = 32,
    parameter S_AXI_ADDR_WIDTH         = 7,

    parameter AMOUNT_COEF 	= 16,
    parameter DATA_WIDTH   	= 32
    //parameter int ACC_WIDTH 	= DATA_WIDTH + $clog2(AMOUNT_COEF + 1)
    
)(
    input  wire clk,
    input  wire resetn,

    input  wire signed [DATA_WIDTH-1:0]	            din,
    input  wire                    		            din_valid,

    output wire signed [DATA_WIDTH + DATA_WIDTH + $clog2(AMOUNT_COEF) -1:0]	dout,
    output wire						               	dout_valid,

    //axi4_lite
    axi4_lite_if.slave s_axi

);

    //axi4_lite
    wire reg_wr, reg_rd;
    wire [S_AXI_ADDR_WIDTH - 3 : 0] reg_wr_addr, reg_rd_addr;
    reg  [S_AXI_DATA_WIDTH - 1 : 0] reg_rd_data = 32'hDEADBEEF;

    axi4_lite_proc #
    (
        .S_AXI_ADDR_WIDTH ( S_AXI_ADDR_WIDTH ),
        .S_AXI_DATA_WIDTH ( S_AXI_DATA_WIDTH )
    )
    axi4_lite_proc_inst
    (
        .clk            ( clk           ),
        .resetn         ( resetn        ),

        .s_axi          (s_axi          ),

        .bus2ip_wr      ( reg_wr        ),
        .bus2ip_awaddr  ( reg_wr_addr   ),

        .bus2ip_rd      ( reg_rd ),
        .bus2ip_araddr  ( reg_rd_addr   ),
        .bus2ip_rdata   ( reg_rd_data   )
    );



    reg signed [DATA_WIDTH-1:0] coef [0:AMOUNT_COEF-1];

    ///
    ///
    // Register space

    //program reset
    reg          SW_RST;
    reg [S_AXI_ADDR_WIDTH - 3 : 0] idx_wr;
    reg [S_AXI_ADDR_WIDTH - 3 : 0] idx_rd;
    localparam BYTE_NUM = (DATA_WIDTH+7)/8;

    always @(posedge clk) begin
        if (!resetn) begin
            SW_RST <= 1;
            for (int i = 0; i < AMOUNT_COEF; i++)
                coef[i] <= 0;
        end 
        else if (reg_wr) begin
    
            //reg0 SW_RST
            if (reg_wr_addr == 0) begin
                if (s_axi.wstrb[3])
                    SW_RST <= s_axi.wdata[31];
            end
            //coeff
            else if (reg_wr_addr >= 1 && reg_wr_addr <= AMOUNT_COEF) begin
                idx_wr = reg_wr_addr - 1;
    
                for (int b = 0; b < BYTE_NUM; b++) begin
                if (s_axi.wstrb[b]) begin
                    for (int i = 0; i < 8; i++) begin
                        if (8*b + i < DATA_WIDTH)
                            coef[idx_wr][8*b + i] <= s_axi.wdata[8*b + i];
                    end
                end
            end
            end
    
        end
    end
/*
    always @(posedge clk) begin
        if (~resetn) begin
            SW_RST    <= 1;
            for (int i = 0; i < AMOUNT_COEF; i = i + 1) begin
                coef[i] <= 0;
            end
        end 
        else begin
            if (reg_wr) begin
                case (reg_wr_addr)
                5'h0: begin
                    if (s_axi.wstrb[3]) SW_RST <= s_axi.wdata[31];
                end
                    5'd1: begin
                        if (s_axi.wstrb[3]) coef[0][31 : 24] <= s_axi.wdata[31 : 24];
                        if (s_axi.wstrb[2]) coef[0][23 : 16] <= s_axi.wdata[23 : 16];
                        if (s_axi.wstrb[1]) coef[0][15 :  8] <= s_axi.wdata[15 :  8];
                        if (s_axi.wstrb[0]) coef[0][ 7 :  0] <= s_axi.wdata[ 7 :  0];
                    end
                    5'd2: begin
                        if (s_axi.wstrb[3]) coef[1][31 : 24] <= s_axi.wdata[31 : 24];
                        if (s_axi.wstrb[2]) coef[1][23 : 16] <= s_axi.wdata[23 : 16];
                        if (s_axi.wstrb[1]) coef[1][15 :  8] <= s_axi.wdata[15 :  8];
                        if (s_axi.wstrb[0]) coef[1][ 7 :  0] <= s_axi.wdata[ 7 :  0];
                    end
                    5'd3: begin
                        if (s_axi.wstrb[3]) coef[2][31 : 24] <= s_axi.wdata[31 : 24];
                        if (s_axi.wstrb[2]) coef[2][23 : 16] <= s_axi.wdata[23 : 16];
                        if (s_axi.wstrb[1]) coef[2][15 :  8] <= s_axi.wdata[15 :  8];
                        if (s_axi.wstrb[0]) coef[2][ 7 :  0] <= s_axi.wdata[ 7 :  0];
                    end
                    5'd4: begin
                        if (s_axi.wstrb[3]) coef[3][31 : 24] <= s_axi.wdata[31 : 24];
                        if (s_axi.wstrb[2]) coef[3][23 : 16] <= s_axi.wdata[23 : 16];
                        if (s_axi.wstrb[1]) coef[3][15 :  8] <= s_axi.wdata[15 :  8];
                        if (s_axi.wstrb[0]) coef[3][ 7 :  0] <= s_axi.wdata[ 7 :  0];
                    end
                    5'd5: begin
                        if (s_axi.wstrb[3]) coef[4][31 : 24] <= s_axi.wdata[31 : 24];
                        if (s_axi.wstrb[2]) coef[4][23 : 16] <= s_axi.wdata[23 : 16];
                        if (s_axi.wstrb[1]) coef[4][15 :  8] <= s_axi.wdata[15 :  8];
                        if (s_axi.wstrb[0]) coef[4][ 7 :  0] <= s_axi.wdata[ 7 :  0];
                    end
                    5'd6: begin
                        if (s_axi.wstrb[3]) coef[5][31 : 24] <= s_axi.wdata[31 : 24];
                        if (s_axi.wstrb[2]) coef[5][23 : 16] <= s_axi.wdata[23 : 16];
                        if (s_axi.wstrb[1]) coef[5][15 :  8] <= s_axi.wdata[15 :  8];
                        if (s_axi.wstrb[0]) coef[5][ 7 :  0] <= s_axi.wdata[ 7 :  0];
                    end
                    5'd7: begin
                        if (s_axi.wstrb[3]) coef[6][31 : 24] <= s_axi.wdata[31 : 24];
                        if (s_axi.wstrb[2]) coef[6][23 : 16] <= s_axi.wdata[23 : 16];
                        if (s_axi.wstrb[1]) coef[6][15 :  8] <= s_axi.wdata[15 :  8];
                        if (s_axi.wstrb[0]) coef[6][ 7 :  0] <= s_axi.wdata[ 7 :  0];
                    end
                    5'd8: begin
                        if (s_axi.wstrb[3]) coef[7][31 : 24] <= s_axi.wdata[31 : 24];
                        if (s_axi.wstrb[2]) coef[7][23 : 16] <= s_axi.wdata[23 : 16];
                        if (s_axi.wstrb[1]) coef[7][15 :  8] <= s_axi.wdata[15 :  8];
                        if (s_axi.wstrb[0]) coef[7][ 7 :  0] <= s_axi.wdata[ 7 :  0];
                    end
                    5'd9: begin
                        if (s_axi.wstrb[3]) coef[8][31 : 24] <= s_axi.wdata[31 : 24];
                        if (s_axi.wstrb[2]) coef[8][23 : 16] <= s_axi.wdata[23 : 16];
                        if (s_axi.wstrb[1]) coef[8][15 :  8] <= s_axi.wdata[15 :  8];
                        if (s_axi.wstrb[0]) coef[8][ 7 :  0] <= s_axi.wdata[ 7 :  0];
                    end
                    5'd10: begin
                        if (s_axi.wstrb[3]) coef[9][31 : 24] <= s_axi.wdata[31 : 24];
                        if (s_axi.wstrb[2]) coef[9][23 : 16] <= s_axi.wdata[23 : 16];
                        if (s_axi.wstrb[1]) coef[9][15 :  8] <= s_axi.wdata[15 :  8];
                        if (s_axi.wstrb[0]) coef[9][ 7 :  0] <= s_axi.wdata[ 7 :  0];
                    end
                    5'd11: begin
                        if (s_axi.wstrb[3]) coef[10][31 : 24] <= s_axi.wdata[31 : 24];
                        if (s_axi.wstrb[2]) coef[10][23 : 16] <= s_axi.wdata[23 : 16];
                        if (s_axi.wstrb[1]) coef[10][15 :  8] <= s_axi.wdata[15 :  8];
                        if (s_axi.wstrb[0]) coef[10][ 7 :  0] <= s_axi.wdata[ 7 :  0];
                    end
                    5'd12: begin
                        if (s_axi.wstrb[3]) coef[11][31 : 24] <= s_axi.wdata[31 : 24];
                        if (s_axi.wstrb[2]) coef[11][23 : 16] <= s_axi.wdata[23 : 16];
                        if (s_axi.wstrb[1]) coef[11][15 :  8] <= s_axi.wdata[15 :  8];
                        if (s_axi.wstrb[0]) coef[11][ 7 :  0] <= s_axi.wdata[ 7 :  0];
                    end
                    5'd13: begin
                        if (s_axi.wstrb[3]) coef[12][31 : 24] <= s_axi.wdata[31 : 24];
                        if (s_axi.wstrb[2]) coef[12][23 : 16] <= s_axi.wdata[23 : 16];
                        if (s_axi.wstrb[1]) coef[12][15 :  8] <= s_axi.wdata[15 :  8];
                        if (s_axi.wstrb[0]) coef[12][ 7 :  0] <= s_axi.wdata[ 7 :  0];
                    end
                    5'd14: begin
                        if (s_axi.wstrb[3]) coef[13][31 : 24] <= s_axi.wdata[31 : 24];
                        if (s_axi.wstrb[2]) coef[13][23 : 16] <= s_axi.wdata[23 : 16];
                        if (s_axi.wstrb[1]) coef[13][15 :  8] <= s_axi.wdata[15 :  8];
                        if (s_axi.wstrb[0]) coef[13][ 7 :  0] <= s_axi.wdata[ 7 :  0];
                    end
                    5'd15: begin
                        if (s_axi.wstrb[3]) coef[14][31 : 24] <= s_axi.wdata[31 : 24];
                        if (s_axi.wstrb[2]) coef[14][23 : 16] <= s_axi.wdata[23 : 16];
                        if (s_axi.wstrb[1]) coef[14][15 :  8] <= s_axi.wdata[15 :  8];
                        if (s_axi.wstrb[0]) coef[14][ 7 :  0] <= s_axi.wdata[ 7 :  0];
                    end
                    5'd16: begin
                        if (s_axi.wstrb[3]) coef[15][31 : 24] <= s_axi.wdata[31 : 24];
                        if (s_axi.wstrb[2]) coef[15][23 : 16] <= s_axi.wdata[23 : 16];
                        if (s_axi.wstrb[1]) coef[15][15 :  8] <= s_axi.wdata[15 :  8];
                        if (s_axi.wstrb[0]) coef[15][ 7 :  0] <= s_axi.wdata[ 7 :  0];
                    end
                endcase
            end
        end
    end
*/                
                
    always @(posedge clk) begin
        if (~resetn) reg_rd_data <= 32'hDEADBEEF;
        else begin
            if (reg_rd) begin
                if (reg_rd_addr == 0) begin
                    reg_rd_data <= {SW_RST, 31'b0};
                end
                
                if (reg_rd_addr >= 1 && reg_rd_addr <= AMOUNT_COEF) begin
                    idx_rd <= reg_rd_addr - 1;
                    reg_rd_data <= {{(32-DATA_WIDTH){1'b0}}, coef[idx_rd]};
                end
                else begin
                    reg_rd_data <= 32'hDEADBEEF;
                end
            end
        end
    end

    ///
    ///


	wire  signed [DATA_WIDTH-1:0] din_translate = din[0] ? {DATA_WIDTH{1'b1}} : {{DATA_WIDTH-1{1'b0}}, 1'b1};

    reg signed [DATA_WIDTH-1:0] delay [0:AMOUNT_COEF-1];

    always @(posedge clk) begin
    	if (!resetn || SW_RST) begin
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
    reg signed [DATA_WIDTH+DATA_WIDTH-1:0] prod [0:AMOUNT_COEF-1];

    always @(posedge clk) begin
        if(!resetn || SW_RST)
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
    reg signed [DATA_WIDTH + DATA_WIDTH + $clog2(AMOUNT_COEF)-1:0]
        sum_stage [0:STAGES][0:AMOUNT_COEF-1];

    // level 0
    always @(posedge clk) begin
        if(!resetn || SW_RST)
            for(int i=0; i < AMOUNT_COEF; i = i + 1)
                sum_stage[0][i] <= 0;
        else
            for(int i=0; i < AMOUNT_COEF; i = i + 1)
                sum_stage[0][i] <= prod[i];
    end

    // level 1..STAGES-1
    generate
        for(genvar s = 0; s < STAGES; s = s + 1) begin : TREE_STAGE
            localparam int ELEMS = AMOUNT_COEF >> (s+1);

            for(genvar i=0; i < ELEMS; i = i + 1) begin : ADD
                always @(posedge clk) begin
                    if(!resetn || SW_RST)
                        sum_stage[s+1][i] <= 0;
                    else
                        sum_stage[s+1][i] <=
                            sum_stage[s][2*i]
                          + sum_stage[s][2*i+1];
                end
            end

            // dragging an odd element
            if((AMOUNT_COEF >> s) % 2) begin : ODD_PASS
                always @(posedge clk) begin
                    if(!resetn || SW_RST)
                        sum_stage[s+1][ELEMS] <= 0;
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

    always @(posedge clk) begin
        if(!resetn || SW_RST) begin
            valid_pipe <= 0;
        end
        else begin
            valid_pipe <= {valid_pipe[LATENCY-2:0], din_valid};
        end
    end

    assign dout_valid = valid_pipe[LATENCY-1];

endmodule
`default_nettype wire