`timescale 1ns / 1ps

module fp_mul_correction_pipe (clk, valid, M_in_mul, E_in_mul, float_in_2, float_out_cor, float_out_2, ready);

input wire clk;
input wire valid;
input wire [47:0] M_in_mul;
input wire signed [7:0] E_in_mul;
input wire [30:0] float_in_2;

output reg [30:0] float_out_cor;
output reg [30:0] float_out_2;
output reg ready;

wire [22:0] M_trunc;
reg [46:0] M_overflow;
reg signed [7:0] E_overflow;

assign M_trunc = M_overflow[22:0];

always @(posedge clk) begin
    if(valid == 1'b1) begin
        float_out_cor[30:23] <= E_overflow + 127;
        float_out_2 <= float_in_2;
        ready <= 1'b1;
        if(M_trunc[22] == 1'b1)
            float_out_cor[22:0] <= M_overflow[45:23] + 1;
        else
            float_out_cor[22:0] <= M_overflow[45:23];
    end else begin
        float_out_cor <= float_out_cor;
        float_out_2 <= float_out_2;
        ready <= 1'b0;
    end
end

always @* begin
    if(M_in_mul[47] == 1'b1) begin
        M_overflow = M_in_mul >> 1;
        E_overflow = E_in_mul + 1;
    end else begin
        M_overflow = M_in_mul;
        E_overflow = E_in_mul;
    end
end

endmodule
