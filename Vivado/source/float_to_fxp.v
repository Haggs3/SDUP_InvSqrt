`timescale 1ns / 1ps

module float_to_fxp(clk, rst, start, float_in, fxp_out, ready);

input wire start;
input wire clk;
input wire rst;
input wire [31:0] float_in;

output reg [31:0] fxp_out;
output reg ready;

wire reset;
wire signed [7:0] exp;
wire [22:0] mant;
wire [23:0] in;
wire dir;
wire [7:0] bitshift;
wire rdy;
wire [31:0] shifted;

shifter shfter(clk, reset, dir, in, bitshift, shifted, rdy);
                                                          
assign reset = start | rst;
assign mant = float_in[22:0];                        
assign exp = 134 - float_in[30:23];                                                                             

assign in = {1'b1, mant};

assign dir = (exp > 0) ? 1'b0 : 1'b1;
assign bitshift = dir ? (~exp + 1) : exp;
                                                        
always @ (posedge clk)
begin                                                   
    if(rst == 1'b1) begin                                               
        fxp_out <= 32'b0;
        ready <= 1'b0;                               
    end else begin
        if (rdy == 1) begin
            fxp_out <= shifted;
            ready <= rdy;
        end
    end                                                                                                 
end                                                      
                                                         
endmodule
