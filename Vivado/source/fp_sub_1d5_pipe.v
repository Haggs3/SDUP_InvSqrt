`timescale 1ns / 1ps
`define EXP_SHIFT 23
`define ROUND_SHIFT 3

module fp_sub_1d5_pipe (clk, rstn, backprn, valid, float_in, float_in_delay, float_out, float_out_delay, ready, error_in, error_out);

input wire clk;
input wire rstn;
input wire valid;
input wire [30:0] float_in;
input wire [30:0] float_in_delay;
input wire error_in;

input wire backprn;
output wire [30:0] float_out;
output wire [30:0] float_out_delay;
output wire ready;
output wire error_out;

wire [`EXP_SHIFT +`ROUND_SHIFT:0] M_sub;
wire [30:0] float_delay;
wire valid_p;
wire error_mid;

fp_1d5_sub_subtract_pipe   subtract  (clk, rstn, backprn, valid, float_in, float_in_delay, M_sub, float_delay, valid_p, error_in, error_mid);
fp_1d5_sub_correction_pipe correction(clk, rstn, backprn, valid_p, M_sub, float_delay, float_out, float_out_delay, ready, error_mid, error_out);


endmodule
