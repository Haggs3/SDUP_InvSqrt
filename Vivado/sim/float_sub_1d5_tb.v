`timescale 1ns / 1ps


module float_sub_tb(

);

logic clk, rst, start;
logic [31:0] float_in;
logic [31:0] float_out;
logic [31:0] float_out_expected;
logic ready;

logic [63:0] testvectors [9:0];
real out, out_expected;
logic [31:0] vecnum;
integer f;

float_sub_1d5 float_sub_1d5(clk, rst, start, float_in, float_out, ready);

initial
begin
    $readmemh("C:/Users/LB197/Desktop/project_sqrt_test/sub_in.tv", testvectors);
    f = $fopen("C:/Users/LB197/Desktop/project_sqrt_test/sub_out.txt","w");
    float_in <= 32'b0;
    vecnum <= 32'b0;
    clk <= 1'b1;
    start = 1'b0;
    rst = 1'b1;
    #5
    rst = 1'b0;
    #5
    start = 1'b1;
    #5;
    start = 1'b0;
end
always begin
    #5 clk <= ~clk;
end

always@(posedge ready)
begin
    vecnum = vecnum + 1;
    out = $bitstoshortreal(float_out);
    out_expected = $bitstoshortreal(float_out_expected);
    start = 1'b1;
    @(negedge ready);
    start = 1'b0;
end

always@(posedge start)
begin
    {float_in, float_out_expected} = testvectors[vecnum];
    $fwrite(f,"%h\n",float_out);
       
    if (vecnum == 10) begin
       $fclose(f);
       $stop;
    end   
end 
endmodule