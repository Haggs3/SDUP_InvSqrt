`timescale 1ns / 1ps

module fp_mul_pipe (clk, valid, float_in_1, float_in_2, float_out, float_out_delay, ready);

input wire clk;
input wire valid;
input wire [30:0] float_in_1;
input wire [30:0] float_in_2;

output wire [30:0] float_out;
output wire [30:0] float_out_delay;
output wire ready;

wire [47:0] M_mul;
wire signed [7:0] E_mul;
wire [30:0] float_delay;
wire valid_p;

fp_mul_multiply_pipe   multiply  (clk, valid, float_in_1, float_in_2, float_delay, M_mul, E_mul, valid_p);
fp_mul_correction_pipe correction(clk, valid_p, M_mul, E_mul, float_delay, float_out, float_out_delay, ready);

endmodule
