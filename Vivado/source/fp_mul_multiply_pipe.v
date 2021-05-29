`timescale 1ns / 1ps

module fp_mul_multiply_pipe (clk, valid, float_in_1, float_in_2, float_out_2, M_mul, E_mul, ready, error_in, error_out);

input wire clk;
input wire valid;
input wire [30:0] float_in_1;
input wire [30:0] float_in_2;
input wire error_in;

output reg [30:0] float_out_2;
output reg [47:0] M_mul;
output reg signed [7:0] E_mul;
output reg ready;
output reg error_out;

wire signed [7:0] E1, E2, Etmp1, Etmp2;
wire [22:0] M1, M2;

assign E1 = float_in_1[30:23] - 127;
assign E2 = float_in_2[30:23] - 127;

assign M1 = float_in_1[22:0];
assign M2 = float_in_2[22:0];

always @(posedge clk) begin
    if(valid == 1'b1) begin
        float_out_2 <= float_in_2;
        M_mul <= {1'b1, M1} * {1'b1, M2};
        E_mul <= E1 + E2;
        ready <= 1'b1;
        error_out <= error_in;
    end else begin
        float_out_2 <= float_out_2;
        M_mul <= M_mul;
        E_mul <= E_mul;
        ready <= 1'b0;
        error_out <= 0;
    end
end

endmodule
