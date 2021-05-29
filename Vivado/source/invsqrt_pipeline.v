`timescale 1ns / 1ps

module invsqrt_pipeline (clk, valid, float_in, float_out, ready);

input wire clk;
input wire valid;
input wire [31:0] float_in;

output wire [30:0] float_out;
output wire ready;

wire [30:0] y [0:3];
wire [30:0] x2, x2y, x2yy, sub_x2yy;
wire valid_p [0:3];
wire error[3:0];

invsqrt_pipe_init invsqrt_pipe_init (clk, valid,      float_in, x2, y[0], valid_p[0], error[0]);
fp_mul_pipe       mul_pipe_x2y      (clk, valid_p[0], x2, y[0], x2y, y[1], valid_p[1], error[0], error[1]);
fp_mul_pipe       mul_pipe_x2yy     (clk, valid_p[1], x2y, y[1], x2yy, y[2], valid_p[2], error[1], error[2]);
fp_sub_1d5_pipe   sub_1d5_pipe      (clk, valid_p[2], x2yy, y[2], sub_x2yy, y[3], valid_p[3], error[2], error[3]);
fp_mul_pipe #(1)  mul_pipe_sub_x2yy (clk, valid_p[3], sub_x2yy, y[3], float_out, , ready, error[3]);

endmodule
