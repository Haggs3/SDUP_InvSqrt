`timescale 1ns / 1ps


module shifter_tb(

);

reg clk, rst, direction;
wire ready;
wire [31:0] shifted;
reg [7:0] shift;
reg [23:0] in;

//Instantiation
shifter shifterTB(clk, rst, direction, in, shift, shifted, ready);

//ce & clock generator stimuli
initial
begin
    clk <= 1'b1;
    in = 24'h010101;
    shift = 6;
    direction = 1;
    rst = 1;
    #10
    rst = 0;
end
always
    #5 clk <= ~clk;

always@(posedge clk)
begin

end
    
endmodule