`timescale 1ns / 1ps

module invsqrt_pipeline_tb(

    );
    
real out, in;
reg clk, ce;
reg [31:0] fp_in;
wire [30:0] float_out;
wire ready;

//Instantiation
invsqrt_pipeline invsqrt_pipelineTB(clk, ce, fp_in[30:0], float_out, ready);
//ce & clock generator stimuli
initial
begin
    ce = 0;
    clk <= 1'b1;
    #130
    in = 0.125;
    fp_in = $shortrealtobits(in);
    @(negedge clk);
    ce = 1'b1;
    repeat(10) @(posedge clk);
    ce = 1'b0;
    repeat(5) @(posedge clk);
    ce = 1'b1;
end
always
    #5 clk <= ~clk;

always@(posedge clk)
begin
    if (ce == 1'b1) begin
        in = in * 2;
        fp_in = $shortrealtobits(in);
    end
    out <= $bitstoshortreal({1'b0, float_out});
end
    
endmodule