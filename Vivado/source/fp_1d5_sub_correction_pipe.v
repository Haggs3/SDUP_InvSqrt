`timescale 1ns / 1ps
`define EXP_SHIFT 23
`define ROUND_SHIFT 3

module fp_1d5_sub_correction_pipe (clk, valid, M_sub, float_in_delay, float_out, float_out_delay, ready, error_in, error_out);

input wire clk;
input wire valid;
input wire [`EXP_SHIFT +`ROUND_SHIFT:0] M_sub;
input wire [30:0] float_in_delay;
input wire error_in;

output reg [30:0] float_out;
output reg [30:0] float_out_delay;
output reg ready;
output reg error_out;

reg [`EXP_SHIFT +`ROUND_SHIFT:0] M_ov;
wire E_ov;
wire [7:0] E;

assign E = {7'b0111_111, E_ov};
assign E_ov = (M_sub[`EXP_SHIFT+`ROUND_SHIFT] == 1'b0) ? 1'b0 : 1'b1;

always @(posedge clk) begin
    if(valid == 1'b1) begin
        float_out_delay <= float_in_delay;
        float_out[30:23] <= E;
        ready <= 1'b1;
        error_out <= error_in;
        if (M_ov[`ROUND_SHIFT-1] == 1'b1)
            float_out[22:0] <= M_ov[`EXP_SHIFT+`ROUND_SHIFT:`ROUND_SHIFT] + 1;
        else
            float_out[22:0] <= M_ov[`EXP_SHIFT+`ROUND_SHIFT:`ROUND_SHIFT];
    end else begin
        float_out_delay <= float_out_delay;
        float_out <= float_out;
        ready <= 1'b0;
        error_out <= 1'b0;
    end
end

always @* begin
    if (M_sub[`EXP_SHIFT+`ROUND_SHIFT] == 1'b0)
        M_ov = M_sub << 1;
    else
        M_ov = M_sub;
end

endmodule
