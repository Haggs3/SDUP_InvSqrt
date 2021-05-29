`timescale 1ns / 1ps

module invsqrt_pipeline_tb(

    );
    
real out, out_expected;
logic clk, ce;
logic [31:0] fp_in;
logic [30:0] float_out;
logic ready;

logic [31:0] float_out_expected;
logic [65:0] testvectors [12:0];
logic [31:0] vecnum;
integer f;

//Instantiation
invsqrt_pipeline invsqrt_pipelineTB(clk, ce, fp_in[31:0], float_out, ready);
//ce & clock generator stimuli
initial
begin
    $readmemh("C:/Users/LB197/Desktop/project_sqrt_test/invsq_pipe_in.tv", testvectors);
    f = $fopen("C:/Users/LB197/Desktop/project_sqrt_test/invsq_pipe_out.txt","w");
    vecnum <= 0;
    ce = 0;
    clk <= 1'b1;
    #130
    fp_in <= 0;
    @(negedge clk);
    ce = 1'b1;
    repeat(10) @(posedge clk);
    ce = 1'b0;
    repeat(5) @(posedge clk);
    ce = 1'b1;
end
always begin
    out <= $bitstoshortreal({1'b0, float_out});
    out_expected = $bitstoshortreal(float_out_expected);
    #5 clk <= ~clk;
end

always@(posedge clk)
begin
    $fwrite(f,"%h\n",float_out);
    if (ce == 1'b1) begin
        {fp_in, float_out_expected} = testvectors[vecnum];
        vecnum = vecnum + 1;
    end
    
    if (vecnum == 35) begin
       $fclose(f);
       $stop;
    end
end
    
endmodule