`timescale 1ns / 1ps
    
module shifter(clk, rst, direction, in, shift, shifted, ready);

input wire clk;
input wire rst;
input wire direction;
input wire [23:0] in;
input wire [7:0] shift;

output reg [31:0] shifted;
output reg ready;

reg [7:0] ctr;

always @ (posedge clk)
    if(rst == 1'b1)
    begin
        shifted <= in;
        ctr <= shift;
        ready <= 1'b0;
    end
    else
    begin
        if(ctr != 0)
        begin
            if(direction == 1) begin
                shifted <= shifted << 1;
            end else begin
                shifted <= shifted >> 1;
            end
        ctr <= ctr - 1;
        end else begin
            ready <= 1;
        end
    end
endmodule
