`timescale 1ns / 1ps

module fp_mul_pipe (clk, rstn, backprn, valid, float_in_1, float_in_2, float_out, float_out_delay, ready, error_in, error_out);

parameter END = 0;

input wire clk;
input wire rstn;
input wire valid;
input wire [30:0] float_in_1;
input wire [30:0] float_in_2;
input wire error_in;

input wire backprn;
output wire [30:0] float_out;
output wire [30:0] float_out_delay;
output wire ready;
output wire error_out;

wire [47:0] M_mul;
wire signed [7:0] E_mul;
wire [30:0] float_delay;
wire valid_p;
wire error_mid;

fp_mul_multiply_pipe multiply(clk, rstn, backprn, valid, float_in_1, float_in_2, float_delay, M_mul, E_mul, valid_p, error_in, error_mid);
fp_mul_correction_pipe #(END) correction(clk, rstn, backprn, valid_p, M_mul, E_mul, float_delay, float_out, float_out_delay, ready, error_mid, error_out);

endmodule
