`timescale 1ns / 1ps

module float_mul_tb(

);

logic clk, rst, start;
logic [31:0] float_in_1;
logic [31:0] float_in_2;
logic [31:0] float_out;
logic ready;
real mul_module, mul_ideal;

logic [31:0] float_out_exp;
logic [95:0] testvectors [11:0];
logic [31:0] vecnum;
integer f;

float_mul float_mul_TB(clk, rst, start, float_in_1, float_in_2, float_out, ready);

initial
begin
//    $readmemh("C:/Users/LB197/Desktop/project_sqrt_test/mul_in.tv", testvectors);
//    f = $fopen("C:/Users/LB197/Desktop/project_sqrt_test/mul_out.txt","w");
    $readmemh("mul_in.tv", testvectors);
    f = $fopen("mul_out.txt","w");
    vecnum <= 32'b0;
    clk <= 1'b1;
    float_in_1 <= 32'b0;
    float_in_2 <= 32'b0;
    start = 1'b0;
    rst = 1'b1;
    #5
    rst = 1'b0;
    #5
    start = 1'b1;
    #10;
    start = 1'b0;
end
always begin
    #5 clk <= ~clk;
end

always@(posedge ready)
begin
    vecnum = vecnum + 1;
    mul_module = $bitstoshortreal(float_out);
    mul_ideal = $bitstoshortreal($bitstoshortreal(float_in_1) * $bitstoshortreal(float_in_2));
    start = 1'b1;
    @(negedge ready);
    start = 1'b0;
end

always@(posedge start)
begin  
    {float_in_1 ,float_in_2, float_out_exp} = testvectors[vecnum];
    $fwrite(f,"%h\n",float_out);
    
    if (vecnum == 13) begin
       $fclose(f);
       $stop;
    end   
end  
endmodule