`timescale 1ns / 1ps

module invsqrt (clk, rst, start, float_in, float_out, ready);

input wire start;
input wire clk;
input wire rst;
input wire [31:0] float_in;

output wire [31:0] float_out;
output reg ready;

wire [31:0] x2, y, mul_yyx2, sub_1d5_yyx2, fp;
wire [22:0] M_in;
wire [7:0] E_in_x2;
wire rdy_1, rdy_2, rdy_3;

assign M_in = float_in[22:0];
assign E_in_x2 = float_in[30:23] - 1;

assign x2 = {1'b0, E_in_x2, M_in};
assign y = 32'h5f3759df - (float_in >> 1);

float_sq_mul  multiply_yyx2     (clk, rst, start, y,        x2, mul_yyx2,            rdy_1);
float_sub_1d5 subtract_1d5_yyx2 (clk, rst, rdy_1, mul_yyx2, sub_1d5_yyx2,            rdy_2);
float_mul     multiply_y_sub    (clk, rst, rdy_2, y,        sub_1d5_yyx2, float_out, rdy_3);

always @(posedge clk)
    if(rst == 1'b1) begin
        ready <= 0;
    end else begin
        if (start == 1'b1) begin
            ready <= 0;
        end else if (rdy_3 == 1'b1) begin
            ready <= 1;
        end else begin
            ready <= ready;
        end
    end

endmodule
