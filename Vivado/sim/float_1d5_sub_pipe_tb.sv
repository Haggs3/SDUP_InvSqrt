`timescale 1ns / 1ps

module float_1d5_sub_pipe_tb(

);

real out, out_expected;
logic clk, rst, valid, ready, error_in, error_out;
logic [31:0] float_in;
logic [30:0] float_out, float_out_delay;

logic [31:0] float_out_expected;
logic [67:0] testvectors [9:0];
logic [31:0] vecnum;
logic [3:0] error_4b;
integer f;


fp_sub_1d5_pipe fp_sub_1d5_pipeTB(clk, valid, float_in[30:0], 0, float_out, float_out_delay, ready, error_in, error_out);

initial
begin
//    $readmemh("C:/Users/LB197/Desktop/project_sqrt_test/sub_pipe_in.tv", testvectors);
//    f = $fopen("C:/Users/LB197/Desktop/project_sqrt_test/sub_pipe_out.txt","w");
    $readmemh("sub_pipe_in.tv", testvectors);
    f = $fopen("sub_pipe_out.txt","w");
    vecnum <= 0;
    valid <= 0;
    clk <= 1'b1;
    error_in <= 1'b0;
    float_in <= 0;
    rst <= 1'b0;
    #5
    valid = 1'b1;
end

always begin
    out <= $bitstoshortreal({1'b0, float_out});
    out_expected = $bitstoshortreal(float_out_expected);
    #5 clk <= ~clk;
end

always@(posedge clk)
begin
    {float_in, float_out_expected, error_4b} = testvectors[vecnum];
    vecnum = vecnum + 1;
    error_in <= error_4b[0];
    $fwrite(f,"%h\n",float_out);
    
    if (vecnum == 14) begin
       $fclose(f);
       $stop;
    end
end
    
endmodule