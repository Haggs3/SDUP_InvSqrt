`timescale 1ns / 1ps

module invsqrt_pipe_init (clk, valid, number, x2, y, ready);

input wire clk;
input wire valid;
input wire [30:0] number;

output reg [30:0] x2;
output reg [30:0] y;
output reg ready;

wire [22:0] M_in;
wire [7:0] E_in_x2;
wire [30:0] num_shifted;

assign M_in = number[22:0];
assign E_in_x2 = number[30:23] - 1;
assign num_shifted = (number >> 1);

always @(posedge clk) begin
    if(valid == 1'b1) begin
        y <= 32'h5f3759df - num_shifted;
        x2 <= {E_in_x2, M_in};
        ready <= 1;
    end else begin
        y <= y;
        x2 <= x2;
        ready <= 0;
    end
end

endmodule
