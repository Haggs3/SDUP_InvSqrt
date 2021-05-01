`timescale 1ns / 1ps


module float_mul_tb(

);

reg clk, rst, start;
reg [31:0] float_in_1, float_in_2;
wire [31:0] float_out;
wire ready;
real x;

//Instantiation

float_mul float_mulTB(clk, rst, start, float_in_1, float_in_2, float_out, ready);
//ce & clock generator stimuli
initial
begin
    clk <= 1'b1;
    float_in_1 = $shortrealtobits(10231.9382123417);
    float_in_2 = $shortrealtobits(1334.921243746);
    start = 0;
    rst = 1'b1;
    #10
    rst = 1'b0;
    #5
    start = 1'b1;
    #100;
    start = 0;
end
always
    #5 clk <= ~clk;

always@(posedge clk)
begin
    x <= $bitstoshortreal(float_out);
end
    
endmodule