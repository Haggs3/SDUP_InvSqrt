`timescale 1ns / 1ps

module invsqrt_pipeline_axiswrap(
    input wire clk,
    input wire rstn,
    
    input wire [31:0] S_AXIS_tdata,
    input wire [3:0] S_AXIS_tkeep,
    input wire  S_AXIS_tvalid,
    output wire S_AXIS_tready,
    input wire  S_AXIS_tlast,
    
    output wire [31:0] M_AXIS_tdata,
    output wire [3:0] M_AXIS_tkeep,
    output wire  M_AXIS_tvalid,
    input wire  M_AXIS_tready,
    output wire  M_AXIS_tlast
    );

localparam DELAY = 9;

wire valid;
wire [31:0] float_in;
wire [31:0] float_out;
wire ready;
wire backprn;

reg last_delay [0:DELAY-1];

assign float_in = S_AXIS_tdata;
assign S_AXIS_tready = backprn;
assign valid = S_AXIS_tvalid;
assign M_AXIS_tkeep = ready ? 4'b1111 : 4'b0000;
assign M_AXIS_tdata = float_out;
assign M_AXIS_tvalid = ready;
assign backprn = M_AXIS_tready;
assign M_AXIS_tlast = last_delay[DELAY-1];

invsqrt_pipeline invsqrt_pipe(clk, rstn, backprn, valid, float_in, float_out, ready);

integer i;

always @(posedge clk) begin
    if(rstn == 1'b0) begin
        for(i = 0; i < DELAY; i = i + 1) begin
            last_delay[i] <= 1'b0;
        end
    end else begin
        if(backprn == 1'b0) begin
            for(i = 0; i < DELAY; i = i + 1) begin
                last_delay[i] <= last_delay[i];
            end
        end else begin
            last_delay[0] <= S_AXIS_tlast;
            for(i = 1; i < DELAY; i = i + 1) begin
                last_delay[i] <= last_delay[i - 1];
            end
        end
    end
end

endmodule
