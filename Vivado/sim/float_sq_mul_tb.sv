`timescale 1ns / 1ps


module float_sq_mul_tb(

);

logic clk, rst, start;
logic [31:0] float_in_sq;
logic [31:0] float_in_mul;
logic [31:0] float_out;
logic ready;
real sq, mul, mul_module, mul_ideal;

//Instantiation

float_sq_mul float_sq_mul_TB(start, clk, rst, float_in_sq, float_in_mul, float_out, ready);
//ce & clock generator stimuli
initial
begin
    clk <= 1'b1;
    sq = 0.32;
    mul = 1.54;
    float_in_sq = $shortrealtobits(sq);
    float_in_mul = $shortrealtobits(mul);
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
    mul_module = $bitstoshortreal(float_out);
    mul_ideal = $bitstoshortreal($shortrealtobits(sq * sq * mul));
end

always@(posedge ready)
begin
//    in = in + 0.005;
//    float_in = $shortrealtobits(in);
    start = 1'b1;
    @(negedge ready);
    start = 1'b0;
end
    
endmodule