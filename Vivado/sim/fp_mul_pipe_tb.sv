`timescale 1ns / 1ps

module float_mul_pipe_tb(

);

real out, out_expected;
logic clk, valid, ready, error_in, error_out;
logic [31:0] float_in_1, float_in_2;
logic [30:0] float_out, float_out_delay;

logic [31:0] float_out_exp;
logic [99:0] testvectors [9:0];
logic [31:0] vecnum;
logic [3:0] error_4b;
integer f;

fp_mul_pipe #(1) float_mul_pipe_TB(clk, valid, float_in_1, float_in_2, float_out, float_out_delay, ready, error_in, error_out);

initial
begin
//    $readmemh("C:/Users/LB197/Desktop/project_sqrt_test/mul_pipe_in.tv", testvectors);
//    f = $fopen("C:/Users/LB197/Desktop/project_sqrt_test/mul_pipe_out.txt","w");
    $readmemh("mul_pipe_in.tv", testvectors);
    f = $fopen("mul_pipe_out.txt","w");
    vecnum <= 32'b0;
    valid <= 1'b0;
    error_in <= 1'b0;
    float_in_1 <= 32'b0;
    float_in_2 <= 32'b0;
    clk <= 1'b1;
    #5;
    valid = 1'b1;
end
always begin
    out = $bitstoshortreal(float_out);
    out_expected = $bitstoshortreal($bitstoshortreal(float_in_1) * $bitstoshortreal(float_in_2));
    #5 clk <= ~clk;
end

always@(posedge clk)
begin
    {float_in_1 ,float_in_2, float_out_exp, error_4b} = testvectors[vecnum];
    vecnum <= vecnum + 1;
    error_in <= error_4b[0];
    $fwrite(f,"%h\n",float_out);
    
    if (vecnum == 14) begin
       $fclose(f);
       $stop;
    end   
end  
    
endmodule