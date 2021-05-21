`timescale 1ns / 1ps
`define EXP_SHIFT 23
`define ROUND_SHIFT 3

module fp_sub_1d5_pipe (clk, valid, float_in, float_in_delay, float_out, float_out_delay, ready);

input wire clk;
input wire valid;
input wire [30:0] float_in;
input wire [30:0] float_in_delay;

output wire [30:0] float_out;
output wire [30:0] float_out_delay;
output wire ready;

wire [`EXP_SHIFT +`ROUND_SHIFT:0] M_sub;
wire [30:0] float_delay;
wire valid_p;

fp_1d5_sub_subtract_pipe   subtract  (clk, valid, float_in, float_in_delay, M_sub, float_delay, valid_p);
fp_1d5_sub_correction_pipe correction(clk, valid_p, M_sub, float_delay, float_out, float_out_delay, ready);


endmodule
