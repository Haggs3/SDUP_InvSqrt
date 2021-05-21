`timescale 1ns / 1ps

module float_mul_pipe_tb(

);

real out, in1, in2;
reg clk, rst, ce;
reg [31:0] fp_in_1, fp_in_2;
wire [30:0] y1, float_out;

//Instantiation
fp_mul_pipe fp_mulTB (clk, ce, rst, fp_in_1[30:0], fp_in_2[30:0], float_out, y1[30:0]);
//ce & clock generator stimuli
initial
begin
    ce = 0;
    clk <= 1'b1;
    in1 = 4.0;
    in2 = 52.0;
    fp_in_1 = $shortrealtobits(in1);
    fp_in_2 = $shortrealtobits(in2);
    rst = 1'b1;
    #10
    rst = 1'b0;
    #5
    ce = 1'b1;
end
always
    #5 clk <= ~clk;

    
always@(posedge clk)
begin
    in1 = in1 + 1;
    in2 = in2 + 5;
    fp_in_1 = $shortrealtobits(in1);
    fp_in_2 = $shortrealtobits(in2);
    out <= $bitstoshortreal({1'b0, float_out});
    
end
    
endmodule