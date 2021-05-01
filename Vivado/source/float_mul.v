`timescale 1ns / 1ps
`define EXP_SHIFT 23

module float_mul (clk, rst, start, float_in_1, float_in_2, float_out, ready);

input wire start;
input wire clk;
input wire rst;
input wire [31:0] float_in_1;
input wire [31:0] float_in_2;

output reg [31:0] float_out;
output reg ready;

wire signed [7:0] E1, E2;
reg signed [7:0] E, exp;
wire [22:0] M1, M2, M_trunc;
reg [22:0] M;
reg [47:0] M_mul;
reg  [2:0]state;

localparam IDLE = 3'b000,
           MUL = 3'b001,
           OVERFLOW = 3'b010,
           ROUNDING = 3'b011,
           FINISH = 3'b100;

assign E1 = float_in_1[30:23] - 127;
assign E2 = float_in_2[30:23] - 127;

assign M1 = float_in_1[22:0];
assign M2 = float_in_2[22:0];

assign M_trunc = M_mul[22:0];

always @ (posedge clk)
                                                 
    if(rst == 1'b1) begin
        float_out <= 32'b0;
        ready <= 1'b0;
        state <= IDLE;
        exp <= 7'b0;
        E <= 7'b0;
        M <= 23'b0;
        M_mul <= 48'b0;
    end else begin
        case(state)
            IDLE: begin
                E <= E1 + E2;
                if (start == 1'b1) begin
                    ready <= 1'b0;
                    state <= MUL;
                end else begin
                    state <= IDLE;
                end
            end
            MUL:begin
                M_mul <= ({1'b1, M1} * {1'b1, M2});
                state <= OVERFLOW;
            end
            OVERFLOW: begin
            if (M_mul[47] == 1) begin
                    M_mul <= M_mul >> 1;
                    E <= E + 1;
                end else begin
                    M_mul <= M_mul;
                    E <= E;
                end
            state <= ROUNDING;
            end
            ROUNDING: begin
                if(M_trunc[22] == 1) begin
                    M <= M_mul[45:23] + 1;
                end else begin
                    M <= M_mul[45:23];
                end
            state <= FINISH;
            end
            FINISH: begin
                float_out <= {(E + 127), M};
                ready <= 1'b1;
                state <= IDLE;
            end
        endcase
    end
       
endmodule