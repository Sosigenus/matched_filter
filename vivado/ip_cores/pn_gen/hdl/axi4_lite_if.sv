`default_nettype none
`timescale 1ns / 1ps
interface axi4_lite_if #(
    parameter S_AXI_ADDR_WIDTH = 5,
    parameter S_AXI_DATA_WIDTH = 32
) (
    input wire clk,
    input wire resetn
);

    logic [S_AXI_ADDR_WIDTH-1:0]awaddr;
    logic [2:0]                 awprot;
    logic                       awvalid;
    logic                       awready;
    
    logic [S_AXI_DATA_WIDTH-1:0]      wdata;
    logic [(S_AXI_DATA_WIDTH/8)-1:0]  wstrb;
    logic                       wvalid;
    logic                       wready;
    
    logic [1:0]                 bresp;
    logic                       bvalid;
    logic                       bready;
    
    logic [S_AXI_ADDR_WIDTH-1:0]      araddr;
    logic [2:0]                 arprot;
    logic                       arvalid;
    logic                       arready;
    
    logic [S_AXI_DATA_WIDTH-1:0]      rdata;
    logic [1:0]                 rresp;
    logic                       rvalid;
    logic                       rready;

initial begin
    awaddr  = 0;
    awprot  = 0;
    awvalid = 0;
    wdata   = 0;
    wstrb   = 0;
    wvalid  = 0;
    bready  = 0;
    araddr  = 0;
    arprot  = 0;
    arvalid = 0;
    arready = 0;
end

    modport master (
        output awaddr, awprot, awvalid,
        input  awready,
        
        output wdata, wstrb, wvalid,
        input  wready,
        
        input  bresp, bvalid,
        output bready,
        
        output araddr, arprot, arvalid,
        input  arready,
        
        input  rdata, rresp, rvalid,
        output rready
    );
    
    modport slave (
        input  awaddr, awprot, awvalid,
        output awready,
        
        input  wdata, wstrb, wvalid,
        output wready,
        
        output bresp, bvalid,
        input  bready,
        
        input  araddr, arprot, arvalid,
        output arready,
        
        output rdata, rresp, rvalid,
        input  rready
    );

endinterface
`default_nettype wire