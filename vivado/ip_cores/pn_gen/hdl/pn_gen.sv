`default_nettype none
`timescale 1ns / 1ps
module pn_generator # 
(
    parameter S_AXI_ADDR_WIDTH = 5,
    parameter S_AXI_DATA_WIDTH = 32, 

	parameter OS 			= 1,
	parameter SEED_DEFAULT	= 5'b11011
)
(
	input 	wire clk,
	input 	wire resetn,

    output 	wire q,
	output  wire q_valid,

    //axi4_lite
    axi4_lite_if.slave s_axi

);

wire reg_wr, reg_rd;
wire [S_AXI_ADDR_WIDTH - 3 : 0] reg_wr_addr, reg_rd_addr;
reg  [S_AXI_DATA_WIDTH - 1 : 0] reg_rd_data = 32'hDEADBEEF;

axi4_lite_proc #
    (
        .S_AXI_DATA_WIDTH ( S_AXI_DATA_WIDTH ),
        .S_AXI_ADDR_WIDTH ( S_AXI_ADDR_WIDTH )
    )
    axi4_lite_proc_inst
    (
        .clk            (clk            ),
        .resetn         (resetn         ),
        .s_axi          (s_axi          ),

        .bus2ip_wr      ( reg_wr        ),
        .bus2ip_awaddr  ( reg_wr_addr   ),

        .bus2ip_rd      ( reg_rd ),
        .bus2ip_araddr  ( reg_rd_addr   ),
        .bus2ip_rdata   ( reg_rd_data   )
    );

/*
[5 3 0]
2^5 -1 = 31
z^5 + z^3 + 1 
[1 0 1 0 0]
*/
	reg	[4:0]	seed_init;
	reg [3:0]	os_init;
	reg        	SW_RST;
	always @(posedge clk) begin
        if (~resetn) begin
            SW_RST 		<= 1;
            seed_init 	<= SEED_DEFAULT; 
            os_init		<= OS;
        end 
        else begin
            if (reg_wr) begin
                case (reg_wr_addr)
                5'h0: begin
                    if (s_axi.wstrb[3]) SW_RST <= s_axi.wdata[31];
                end
                5'd1: begin
                    /*
                    ! reg4...0  - seed_init
                    reg7...5  - reserve 
                    ! reg11..8  - os_init
                    reg15..12 - reserve
                    other reg - reserve
                    */
                    if (s_axi.wstrb[0] && SW_RST) begin 
                        seed_init[4:0] 	<= s_axi.wdata[4:0];
                        os_init[3:0]	<= s_axi.wdata[11:8];
                    end
                end 
                endcase
            end
        end
    end
    
    always @(posedge clk) begin
    if (~resetn) reg_rd_data <= 32'hDEADBEEF;
    else begin
        if (reg_rd) begin
            case (reg_rd_addr)
                5'h0: reg_rd_data <= {31'b0, SW_RST};
                5'h1: reg_rd_data <= {20'b0, os_init, 3'b0, seed_init};
                default: reg_rd_data <= 32'hDEADBEEF;
            endcase
        end
    end
end

	//
	reg [4:0] 	shift_register;
	reg 		valid; 
	reg 		q_reg;
	reg [3:0]	over_sampling;
	wire 		xor_sreg;

	//Calc comb logic
	assign xor_sreg = shift_register[4] ^ shift_register[2];

	//Calc sequence logic
	always @(posedge clk) begin
		if(~resetn || SW_RST) begin
			shift_register 	<= seed_init;
			valid 			<= 1'b0;
			over_sampling	<= os_init;
		end else begin
			if (over_sampling == os_init) begin
				shift_register 	<= {shift_register[3:0], xor_sreg};
				q_reg 			<= shift_register[4];
				valid 			<= 1'b1;
				over_sampling	<= 4'b1;
			end
			else begin
				over_sampling 	<=  over_sampling + 1;
			end
		end
	end

	//Output assignment
	assign q 		= q_reg;
	assign q_valid 	= valid;
endmodule
`default_nettype wire