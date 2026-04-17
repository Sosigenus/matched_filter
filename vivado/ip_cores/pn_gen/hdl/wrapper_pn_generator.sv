`default_nettype none
`timescale 1ns / 1ps
module wrapper_pn_generator #
(
    parameter S_AXI_ADDR_WIDTH = 5, 
    parameter S_AXI_DATA_WIDTH = 32,
    
    parameter OS 			= 1,
	parameter SEED_DEFAULT	= 5'b11011
)
(
    //axi4_lite 
    input wire [S_AXI_ADDR_WIDTH-1:0]       S_AXI_AWADDR,
    input wire                              S_AXI_AWVALID,
    output wire                             S_AXI_AWREADY,

    input wire [S_AXI_DATA_WIDTH-1:0]       S_AXI_WDATA,
    input wire [S_AXI_DATA_WIDTH/8 - 1:0]   S_AXI_WSTRB,
    input wire                              S_AXI_WVALID,
    output wire                             S_AXI_WREADY,

    output wire [1:0]                       S_AXI_BRESP,
    output wire                             S_AXI_BVALID,
    input wire                              S_AXI_BREADY,

    input wire [S_AXI_ADDR_WIDTH-1:0]       S_AXI_ARADDR,
    input wire                              S_AXI_ARVALID,
    output wire                             S_AXI_ARREADY,

    output wire [S_AXI_DATA_WIDTH-1:0]      S_AXI_RDATA,
    output wire [1:0]                       S_AXI_RRESP,
    output wire                             S_AXI_RVALID,
    input wire                              S_AXI_RREADY,
    
    input wire                              clk,
    input wire                              resetn,

    output wire q,
    output wire q_valid
);

axi4_lite_if axi_if(
    .clk    (clk     ),
    .resetn (resetn  )
);


assign axi_if.awaddr    = S_AXI_AWADDR;
assign axi_if.awvalid   = S_AXI_AWVALID;
assign S_AXI_AWREADY    = axi_if.awready;

assign axi_if.wdata     = S_AXI_WDATA;
assign axi_if.wstrb     = S_AXI_WSTRB;
assign axi_if.wvalid    = S_AXI_WVALID;
assign S_AXI_WREADY     = axi_if.wready;

assign S_AXI_BRESP      = axi_if.bresp;
assign S_AXI_BVALID     = axi_if.bvalid;
assign axi_if.bready    = S_AXI_BREADY;

assign axi_if.araddr    = S_AXI_ARADDR;
assign axi_if.arvalid   = S_AXI_ARVALID;
assign S_AXI_ARREADY    = axi_if.arready;

assign S_AXI_RDATA      = axi_if.rdata;
assign S_AXI_RRESP      = axi_if.rresp;
assign S_AXI_RVALID     = axi_if.rvalid;
assign axi_if.rready    = S_AXI_RREADY;

// CORE
pn_generator  #
(
    .S_AXI_ADDR_WIDTH(S_AXI_ADDR_WIDTH),
    .S_AXI_DATA_WIDTH(S_AXI_DATA_WIDTH),   

	.OS(OS),
	.SEED_DEFAULT(SEED_DEFAULT)
)
    core
(
    .clk            (clk    ),
    .resetn         (resetn ),
    .s_axi          (axi_if ),
    .q              (q      ),
    .q_valid        (q_valid)
);

endmodule
`default_nettype wire