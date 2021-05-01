`timescale 1ns / 1ps


module float_to_fxp_tb(

);

reg clk, rst, start;
reg [31:0] float_in;
wire [31:0] fxp_out;
wire ready;

//Instantiation
float_to_fxp float_to_fxpTB (clk, rst, start, float_in, fxp_out, ready);
//ce & clock generator stimuli
initial
begin
    clk <= 1'b1;
    float_in = $shortrealtobits(0.0);
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

end
    
endmodule