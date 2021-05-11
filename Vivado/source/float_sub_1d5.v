`timescale 1ns / 1ps
`define EXP_SHIFT 23
`define ROUND_SHIFT 3

module float_sub_1d5 (clk, rst, start, float_in, float_out, ready);

input wire start;
input wire clk;
input wire rst;
input wire [31:0] float_in;

output reg [31:0] float_out;
output reg ready;

wire [1:0] E_in;
wire [7:0] E;
reg [`EXP_SHIFT +`ROUND_SHIFT:0] M_in, M_sub, M_ov;
reg [`EXP_SHIFT:0] M_rd;
wire E_ov;
reg [2:0] state;
wire [22:0] M;

localparam IDLE = 3'b000,
           SUBTRACTION = 3'b001,
           OVERFLOW = 3'b010,
           ROUNDING = 3'b011,
           FINISH = 3'b100;

assign E_in = float_in[24:23];
assign M = float_in[22:0];
assign E_ov = (M_sub[`EXP_SHIFT+`ROUND_SHIFT] == 1'b0) ? 1'b0 : 1'b1;
assign E = {7'b011_1111, E_ov};

always @(posedge clk)
    if(rst == 1'b1) begin
        float_out <= 32'b0;
        M_in <= 27'b0;
        M_sub <= 27'b0;
        M_ov <= 27'b0;
        M_rd <= 24'b0;
        ready <= 1'b0;
        state <= IDLE;
    end else begin
        case(state)
            IDLE: begin
                ready <= 0;
                if (start == 1'b1) begin
                    if (E_in == 2'b10)
                        M_in <= (({1'b1, M, 3'b000}) >> 1);
                    else if (E_in == 2'b01)
                        M_in <= (({1'b1, M, 3'b000}) >> 2);
                    else
                        M_in <= M_in;
                    state <= SUBTRACTION;
                end else begin
                    state <= IDLE;
                end
            end
            SUBTRACTION: begin
                M_sub <= ({1'b1, 23'h40_0000, 3'b000}) - M_in;
                state <= OVERFLOW;
            end
            OVERFLOW: begin
                if (M_sub[`EXP_SHIFT+`ROUND_SHIFT] == 1'b0)
                    M_ov <= M_sub << 1;
                else
                    M_ov <= M_sub;
                state <= ROUNDING;
            end
            ROUNDING: begin
                if (M_ov[`ROUND_SHIFT-1] == 1'b1)
                    M_rd <= M_ov[`EXP_SHIFT+`ROUND_SHIFT:`ROUND_SHIFT] + 1;
                else
                    M_rd <= M_ov[`EXP_SHIFT+`ROUND_SHIFT:`ROUND_SHIFT];
                state <= FINISH;
            end
            FINISH: begin
                float_out[30:0] <= {E, M_rd[22:0]};
                float_out[31] <= 0;
                ready <= 1'b1;
                state <= IDLE;
            end
        endcase
    end
endmodule