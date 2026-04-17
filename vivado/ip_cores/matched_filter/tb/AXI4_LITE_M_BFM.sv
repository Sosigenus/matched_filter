`default_nettype none
`timescale 1ns / 1ps
module AXI4_LITE_M_BFM #(
    parameter S_AXI_ADDR_WIDTH = 5,
    parameter S_AXI_DATA_WIDTH = 32
)(
   input wire clk,
   input wire resetn,
   axi4_lite_if.master bus_if
);
localparam STRB_WIDTH = S_AXI_DATA_WIDTH / 8;
initial begin
    bus_if.awaddr  = 0;
    bus_if.awprot  = 0;
    bus_if.awvalid = 0;
    bus_if.wdata   = 0;
    bus_if.wstrb   = 0;
    bus_if.wvalid  = 0;
    bus_if.bready  = 0;
    bus_if.araddr  = 0;
    bus_if.arprot  = 0;
    bus_if.arvalid = 0;
    bus_if.rready  = 0;
end

task automatic axi4_write(
  input [S_AXI_ADDR_WIDTH-1:0] addr,
  input [S_AXI_DATA_WIDTH-1:0] data,
  input [(S_AXI_DATA_WIDTH/8)-1:0] strb = {STRB_WIDTH{1'b1}}
  );
  begin
    wait(resetn);
    @(posedge clk);
    bus_if.wstrb     = strb;
    bus_if.wdata     = data;
    bus_if.awaddr    = addr << 2;
    bus_if.awvalid   = 1'b1;
    bus_if.wvalid    = 1'b1;
    bus_if.bready    = 1'b1;
    //
    fork
        begin
            wait(bus_if.awready);
            @(posedge clk);
            bus_if.awvalid = 1'b0;
        end
        begin
            wait(bus_if.wready);
            @(posedge clk);
            bus_if.wvalid = 1'b0;
        end
    join
    //
    wait(bus_if.bvalid);
    @(posedge clk);
    bus_if.bready = 1'b0;
  end
endtask

//

task automatic axi4_read;
  input [S_AXI_ADDR_WIDTH-1:0] addr;
  output [S_AXI_DATA_WIDTH-1:0] data;
  begin
    wait(resetn);
    @(posedge clk);
    bus_if.araddr    = addr << 2;
    bus_if.arvalid   = 1'b1;
    bus_if.rready    = 1'b1;
    //
    wait(bus_if.arready);
    @(posedge clk);
    bus_if.arvalid = 1'b0;

    wait(bus_if.rvalid);
    data = bus_if.rdata;
    @(posedge clk);
    bus_if.rready    = 1'b0;
  end
endtask

endmodule
`default_nettype wire