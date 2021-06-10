`timescale 1ns / 1ps

module invsqrt_tb(

);

logic clk, rst, start;
logic [31:0] float_in;
logic [31:0] float_out;
logic ready;
real out, out_expected;

logic [31:0] float_out_expected;
logic [65:0] testvectors [12:0];
logic [31:0] vecnum;
integer f;

invsqrt invsqrt_TB(clk, rst, start, float_in, float_out, ready);

initial
begin
    $readmemh("C:/Users/LB197/Desktop/project_sqrt_test/invsq_in.tv", testvectors);
    f = $fopen("C:/Users/LB197/Desktop/project_sqrt_test/invsq_out.txt","w");
    clk <= 1'b0;
    vecnum <= 0;
    float_in = 32'b0;
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
    out = $bitstoshortreal(float_out);
    out_expected = $bitstoshortreal(float_out_expected);
end

always@(posedge ready)
begin
    start = 1'b1;
    @(negedge ready);
    start = 1'b0;
end

always@(posedge start)
begin
    vecnum = vecnum + 1;
    {float_in, float_out_expected} = testvectors[vecnum];
    $fwrite(f,"%h\n",float_out);
    
    if (vecnum == 14) begin
       $fclose(f);
       $stop;
    end
    
end
    
endmodule