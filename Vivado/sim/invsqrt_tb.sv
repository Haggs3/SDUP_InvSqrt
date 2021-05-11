`timescale 1ns / 1ps


module invsqrt_tb(

);

logic clk, rst, start;
logic [31:0] float_in;
logic [31:0] float_out;
logic ready;
real x, in;

//Instantiation

invsqrt invsqrt_TB(clk, rst, start, float_in, float_out, ready);
//ce & clock generator stimuli
initial
begin
    clk <= 1'b0;
    in = 1;
    float_in = $shortrealtobits(in);
    start = 1'b0;
    rst = 1'b1;
    #100
    rst = 1'b0;
    #10
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
    in = in + 1;
    float_in = $shortrealtobits(in);
    start = 1'b1;
    @(negedge ready);
    start = 1'b0;
end
    
endmodule