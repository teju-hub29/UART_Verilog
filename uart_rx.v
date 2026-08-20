`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.04.2026 18:13:21
// Design Name: 
// Module Name: uart_rx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module uart_rx #(parameter CLKS_PER_BIT = 100)(
    input clk,
    input reset,
    input rx,
    output reg [7:0] data_out,
    output reg data_valid
);

reg [3:0] bit_index = 0;
reg [15:0] clk_count = 0;
reg [7:0] data_reg = 0;
reg [2:0] state = 0;

localparam IDLE  = 0;
localparam START = 1;
localparam DATA  = 2;
localparam STOP  = 3;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        data_valid <= 0;
        clk_count <= 0;
        bit_index <= 0;
        data_reg <= 0;     
        data_out <= 0; 
    end else begin
        case (state)

        IDLE: begin
            data_valid <= 0;
            if (rx == 0) begin
                state <= START;
                clk_count <= 0;
            end
        end

        START: begin
            if (clk_count == ( CLKS_PER_BIT/2 - 1)) begin
                if(rx == 0) begin
                    clk_count <= 0;
                    bit_index <= 0;
                    state <= DATA;
                end else begin
                    state <= IDLE;
                end
            end else 
                clk_count <= clk_count + 1;
            
        end

        DATA: begin
            if (clk_count == CLKS_PER_BIT-1) begin
                clk_count <=0;
                data_reg[bit_index] <= rx;

                if (bit_index < 7)
                    bit_index <= bit_index + 1;
                else
                    state <= STOP;

            end else begin
                clk_count <= clk_count + 1;
            end
        end

        STOP: begin
            if (clk_count < CLKS_PER_BIT-1) 
                clk_count <= clk_count + 1;
            else begin
                data_out <= data_reg;
                data_valid <= 1;
                clk_count <= 0;
                state <= IDLE;
            end
        end

        endcase
    end
end

endmodule
