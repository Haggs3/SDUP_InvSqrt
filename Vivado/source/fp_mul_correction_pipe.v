`timescale 1ns / 1ps

module fp_mul_correction_pipe (clk, valid, M_in_mul, E_in_mul, float_in_2, float_out_cor, float_out_2, ready, error_in, error_out);

parameter END = 0;

input wire clk;
input wire valid;
input wire [47:0] M_in_mul;
input wire signed [7:0] E_in_mul;
input wire [30:0] float_in_2;
input wire error_in; 
output reg error_out;

output reg [30:0] float_out_cor;
output reg [30:0] float_out_2;
output reg ready;

wire [22:0] M_trunc, M_cor;
wire overflow;
wire signed [7:0] E_cor;
reg [46:0] M_overflow;
reg signed [7:0] E_overflow;


generate begin
    if (END == 0) begin
        assign overflow = M_trunc[22];
        assign M_cor = M_overflow[45:23];
        assign E_cor = E_overflow + 127;
    end else begin
        assign overflow = (error_in == 0) ?  M_trunc[22] : 1'b0;
        assign M_cor = (error_in == 0) ? M_overflow[45:23] : 23'hFFFFFF;
        assign E_cor = (error_in == 0) ? (E_overflow + 127) : 8'hFF;
    end
end
endgenerate

assign M_trunc = M_overflow[22:0];

always @(posedge clk) begin
    if(valid == 1'b1) begin
        float_out_2 <= float_in_2;
        ready <= 1'b1;
        error_out <= error_in;
        float_out_cor[30:23] <= E_cor;
        if(overflow == 1'b1)
            float_out_cor[22:0] <= M_cor + 1;
        else
            float_out_cor[22:0] <= M_cor;
            
    end else begin
        float_out_cor <= float_out_cor;
        float_out_2 <= float_out_2;
        ready <= 1'b0;
        error_out <= 0;
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
