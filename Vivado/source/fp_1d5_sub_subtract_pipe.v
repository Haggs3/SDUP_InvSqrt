`timescale 1ns / 1ps
`define EXP_SHIFT 23
`define ROUND_SHIFT 3

module fp_1d5_sub_subtract_pipe (clk, rstn, backprn, valid, float_in, float_in_delay, M_sub, float_out_delay, ready, error_in, error_out);

input wire clk;
input wire rstn;
input wire valid;
input wire [30:0] float_in;
input wire [30:0] float_in_delay;
input wire error_in;

input wire backprn;
output reg [`EXP_SHIFT +`ROUND_SHIFT:0] M_sub;
output reg [30:0] float_out_delay;
output reg ready;
output reg error_out;

wire [1:0] E_in;
reg [`EXP_SHIFT +`ROUND_SHIFT:0] M_in;
wire [22:0] M;

assign E_in = float_in[24:23];
assign M = float_in[22:0];

always @(posedge clk) begin
    if(rstn == 1'b0) begin
        ready <= 1'b0;
        error_out <= 1'b0;
    end else begin
        if(backprn == 1'b0) begin
            float_out_delay <= float_out_delay;
            M_sub <= M_sub;
            ready <= ready;
            error_out <= error_out;
        end else begin
            if(valid == 1'b1) begin
                float_out_delay <= float_in_delay;
                M_sub <= ({1'b1, 23'h40_0000, 3'b000}) - M_in;
                ready <= 1'b1;
                error_out <= error_in;
            end else begin
                float_out_delay <= float_in_delay;
                M_sub <= M_sub;
                ready <= 1'b0;
                error_out <= 1'b0;
            end
        end
    end
end

always @* begin
    if (E_in == 2'b10)
        M_in = (({1'b1, M, 3'b000}) >> 1);
    else if (E_in == 2'b01)
        M_in = (({1'b1, M, 3'b000}) >> 2);
    else
        M_in = {1'b1, M, 3'b000};
end

endmodule
