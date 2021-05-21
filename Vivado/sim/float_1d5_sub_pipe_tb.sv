`timescale 1ns / 1ps

module float_1d5_sub_pipe_tb(

);

real out, in;
reg clk, rst, ce;
reg [31:0] fp_in;
wire [30:0] y1, float_out;

//Instantiation
fp_sub_1d5_pipe fp_sub_1d5_pipeTB(clk, ce, rst, fp_in[30:0], 0, float_out, y1);
//ce & clock generator stimuli
initial
begin
    ce = 0;
    clk <= 1'b1;
    in = 0.4;
    fp_in = $shortrealtobits(in);
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
    in = in + 0.01;
    fp_in = $shortrealtobits(in);
    out <= $bitstoshortreal({1'b0, float_out});
end
    
endmodule