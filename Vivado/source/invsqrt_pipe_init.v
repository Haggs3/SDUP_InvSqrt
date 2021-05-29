`timescale 1ns / 1ps

module invsqrt_pipe_init (clk, valid, number, x2, y, ready, error_out);

input wire clk;
input wire valid;
input wire [31:0] number;

output reg [30:0] x2;
output reg [30:0] y;
output reg ready;
output reg error_out;

wire [22:0] M_in;
wire [7:0] E_in_x2;
wire [30:0] num_shifted;
wire error;

assign M_in = number[22:0];
assign E_in_x2 = number[30:23] - 1;
assign num_shifted = (number >> 1);

assign error = ((number == 31'h00000000) || (number[30:23] == 8'hFF)|| (number[31] == 1'b1)) ? 1'b1 : 1'b0;

always @(posedge clk) begin
    if(valid == 1'b1) begin
        y <= 32'h5f3759df - num_shifted;
        x2 <= {E_in_x2, M_in};
        ready <= 1;
        error_out <= error;
    end else begin
        y <= y;
        x2 <= x2;
        ready <= 0;
        error_out <= 0;
    end
end

endmodule
