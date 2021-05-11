`timescale 1ns / 1ps


module float_sub_tb(

);

logic clk, rst, start;
logic [31:0] float_in;
logic [31:0] float_out;
logic ready;
real x, in;

//Instantiation

float_sub_1d5 float_sub_1d5(clk, rst, start, float_in, float_out, ready);
//ce & clock generator stimuli
initial
begin
    clk <= 1'b1;
    in = 0.4;
    float_in = $shortrealtobits(in);
    start = 1'b0;
    rst = 1'b1;
    #10
    rst = 1'b0;
    #5
    start = 1'b1;
    #10;
    start = 1'b0;
end
always begin
    #5 clk <= ~clk;
    x = $bitstoshortreal(float_out);
end

always@(posedge ready)
begin
    in = in + 0.005;
    float_in = $shortrealtobits(in);
    start = 1'b1;
    @(negedge ready);
    start = 1'b0;
end
    
endmodule