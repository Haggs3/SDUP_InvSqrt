`timescale 1ns / 1ps

module float_1d5_sub_pipe_tb(

);

real out, out_expected;
logic clk, valid, ready, error_in, error_out;
logic [31:0] float_in;
logic [30:0] float_out, float_out_delay;
logic rstn;

logic [31:0] float_out_expected;
logic [67:0] testvectors [9:0];
logic [31:0] vecnum;
logic [3:0] error_4b;
integer f;


fp_sub_1d5_pipe fp_sub_1d5_pipeTB(clk, rstn, backprn, valid, float_in[30:0], 0, float_out, float_out_delay, ready, error_in, error_out);

initial
begin
//    $readmemh("C:/Users/LB197/Desktop/project_sqrt_test/sub_pipe_in.tv", testvectors);
//    f = $fopen("C:/Users/LB197/Desktop/project_sqrt_test/sub_pipe_out.txt","w");
    $readmemh("sub_pipe_in.tv", testvectors);
    f = $fopen("sub_pipe_out.txt","w");
    rstn <= 1;
    vecnum <= 0;
    valid <= 0;
    clk <= 1'b1;
    error_in <= 1'b0;
    float_in <= 0;
    #10
    rstn <= 0;
    #10
    rstn <= 1;
    #10
    {float_in, float_out_expected, error_4b} = testvectors[vecnum];
    vecnum = vecnum + 1;
    error_in <= error_4b[0];
    valid = 1'b1;
end

always begin
     #5 clk <= ~clk;
end

always@(posedge clk)
begin

    out <= $bitstoshortreal({1'b0, float_out});
    out_expected = $bitstoshortreal(float_out_expected);
    $fwrite(f,"%h\n",float_out);
        
    if (valid == 1) begin
        {float_in, float_out_expected, error_4b} = testvectors[vecnum];
        vecnum = vecnum + 1;
        error_in <= error_4b[0];
    end
    
    if (vecnum == 14) begin
       $fclose(f);
       $stop;
    end
end
    
endmodule