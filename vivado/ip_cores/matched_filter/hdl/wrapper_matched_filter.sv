`default_nettype none
`timescale 1ns / 1ps
module wrapper_matched_filter #
(
    parameter S_AXI_ADDR_WIDTH  = 7, 
    parameter S_AXI_DATA_WIDTH  = 32, 
    
    parameter AMOUNT_COEF = 16,
	parameter DATA_WIDTH  = 32
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
    
    input  wire signed [DATA_WIDTH-1:0]	    din,
    input  wire                    		    din_valid,

    output wire signed [DATA_WIDTH + DATA_WIDTH + $clog2(AMOUNT_COEF) -1:0]	            dout,
    output wire							                                                dout_valid
);

axi4_lite_if # (
    .S_AXI_ADDR_WIDTH(S_AXI_ADDR_WIDTH),
    .S_AXI_DATA_WIDTH(S_AXI_DATA_WIDTH)
)
    axi_if
(
    .clk    (clk     ),
    .resetn  (resetn  )
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
matched_filter  #
(
    .S_AXI_ADDR_WIDTH(S_AXI_ADDR_WIDTH),
    .S_AXI_DATA_WIDTH(S_AXI_DATA_WIDTH),   

	.AMOUNT_COEF(AMOUNT_COEF),
	.DATA_WIDTH(DATA_WIDTH)
)
    core
(
    .clk            (clk),
    .resetn         (resetn),
    .s_axi          (axi_if),
    // Data stream
    .din            (din),
    .din_valid      (din_valid),
    .dout           (dout),
    .dout_valid     (dout_valid)
);

endmodule
`default_nettype wire