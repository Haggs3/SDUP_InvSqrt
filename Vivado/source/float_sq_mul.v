`timescale 1ns / 1ps

module float_sq_mul (clk, rst, start, float_in_sq, float_in_mul, float_out, ready);

input wire start;
input wire clk;
input wire rst;
input wire [31:0] float_in_sq;
input wire [31:0] float_in_mul;

output reg [31:0] float_out;
output reg ready;

wire signed [7:0] E_sq, E_mul;
wire signed [7:0] E_sq2;
reg signed [7:0] E;
wire [22:0] M_in_sq, M_in_mul, M_sq_trunc, M_mul_trunc;
reg [22:0] M_sq_done, M;
reg [47:0] M_mul, M_sq, M_sq_of;
reg [2:0] state;

localparam IDLE_SQ = 3'b000,
           OVERLOWSQ = 3'b001,
           ROUNDSQ = 3'b010,
           MUL = 3'b011,
           OVERFLOWMUL = 3'b100,
           ROUNDMUL = 3'b101,
           FINISH = 3'b110;

assign E_sq = float_in_sq[30:23] - 127;
assign E_mul = float_in_mul[30:23] - 127;
assign E_sq2 = E_sq << 1;

assign M_in_sq = float_in_sq[22:0];
assign M_in_mul = float_in_mul[22:0];

assign M_sq_trunc = M_sq[22:0];
assign M_mul_trunc = M_mul[22:0];

always @(posedge clk)
    if(rst == 1'b1) begin
        float_out <= 32'b0;
        E <= 8'b0;
        M_sq_done <= 23'b0;
        M <= 23'b0;
        M_mul <= 48'b0;
        M_sq <= 48'b0;
        M_sq_of <= 48'b0;
        ready <= 1'b0;
        state <= IDLE_SQ;
    end else begin
        case(state)
            IDLE_SQ: begin
                ready <= 1'b0;
                if (start == 1'b1) begin
                    M_sq <= ({1'b1, M_in_sq} * {1'b1, M_in_sq});
                    state <= OVERLOWSQ;
                end else
                    state <= IDLE_SQ;
            end
            OVERLOWSQ: begin
                if (M_sq[47] == 1'b1) begin
                    M_sq_of <= (M_sq >> 1);
                    E <= E_sq2 + E_mul + 1;
                end else begin
                    M_sq_of <= M_sq;
                    E <= E_sq2 + E_mul;
                end
                state <= ROUNDSQ;
            end
            ROUNDSQ: begin
                if(M_sq_trunc[22] == 1'b1)
                    M_sq_done <= M_sq_of[45:23] + 1;
                else
                    M_sq_done <= M_sq_of[45:23];
                state <= MUL;
            end
            MUL: begin
                M_mul <= ({1'b1, M_sq_done} * {1'b1, M_in_mul});
                state <= OVERFLOWMUL;
            end
            OVERFLOWMUL: begin
                if (M_mul[47] == 1'b1) begin
                    M_mul <= (M_mul >> 1);
                    E <= E + 1;
                end else begin
                    M_mul <= M_mul;
                    E <= E;
                end
                state <= ROUNDMUL;
            end
            ROUNDMUL: begin
                if(M_mul_trunc[22] == 1'b1)
                    M <= M_mul[45:23] + 1;
                else
                    M <= M_mul[45:23];
                
                state <= FINISH;
            end
            FINISH: begin
                float_out[30:0] <= {(E + 127), M};
                float_out[31] <= 0;
                ready <= 1'b1;
                state <= IDLE_SQ;
            end
        endcase
    end
endmodule