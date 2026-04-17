`default_nettype none
`timescale 1ns / 1ps
module axi4_lite_proc #
(
    //parameters
    parameter S_AXI_ADDR_WIDTH = 5,
    parameter S_AXI_DATA_WIDTH = 32
    
)
(
    input wire clk,
    input wire resetn,
    axi4_lite_if.slave  s_axi,
       
	output wire                            bus2ip_wr,
	output reg [S_AXI_ADDR_WIDTH-3 : 0]    bus2ip_awaddr = 0,
                                     
	output wire                            bus2ip_rd,
	output reg [S_AXI_ADDR_WIDTH-3 : 0]    bus2ip_araddr = 0,
	input wire [S_AXI_DATA_WIDTH-1 : 0]    bus2ip_rdata
);

//fsm
(* fsm_safe_state = "default_state" *) reg [2:0] wr_state = 3'b001, rd_state = 3'b001;

assign s_axi.awready    = wr_state[1];
assign s_axi.wready     = wr_state[1];
assign s_axi.bresp      = 2'b00;
assign s_axi.bvalid     = wr_state[2];
assign s_axi.arready    = rd_state[1];
assign s_axi.rresp      = 2'b00;
assign s_axi.rvalid     = rd_state[2];

//write transaction
always @(posedge clk) begin
    if (~resetn) wr_state <= 1;
    else begin
        case (wr_state)
            3'b001: begin
                if (s_axi.awvalid && s_axi.wvalid) wr_state <= 3'b010;
                else wr_state <= 3'b001;
            end
            3'b010: wr_state <= 3'b100;
            3'b100: begin
                if (s_axi.bready) wr_state <= 3'b001;
                else wr_state <= 3'b100;
            end
            default: wr_state <= 3'b001;
        endcase
    end
end

always @(posedge clk) begin
    if (~resetn) bus2ip_awaddr <= 0; 
    else if (s_axi.awvalid && s_axi.wvalid) 
        bus2ip_awaddr <= s_axi.awaddr[S_AXI_ADDR_WIDTH-1:2];
end

//read transaction
always @(posedge clk) begin
    if (~resetn) rd_state <= 1;
    else begin
        case (rd_state)
            3'b001: begin
                if (s_axi.arvalid) rd_state <= 3'b010;
                else rd_state <= 3'b001;
            end
            3'b010: rd_state <= 3'b100;
            3'b100: begin
                if (s_axi.rready) rd_state <= 3'b001;
                else rd_state <= 3'b100;
            end
            default: rd_state <= 3'b001;
        endcase
    end
end

always @(posedge clk) begin
    if (~resetn) bus2ip_araddr <= 0;
    else if (s_axi.arvalid) bus2ip_araddr <= s_axi.araddr[S_AXI_ADDR_WIDTH-1:2];
end

//output assigment
assign bus2ip_wr   = wr_state[1];
assign bus2ip_rd   = rd_state[1];
assign s_axi.rdata = bus2ip_rdata;

endmodule
`default_nettype wire