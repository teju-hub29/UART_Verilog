`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module uart_tx #(parameter CLKS_PER_BIT = 100)(
    input  clk,
    input  reset,
    input  start,
    input  [7:0] data_in,
    output reg tx,
    output reg busy
);

reg [3:0]  bit_index;
reg [7:0]  data_reg;
reg [15:0] clk_count;
reg [1:0]  state;
reg        start_prev;

wire start_pulse = start && !start_prev; // one-shot rising edge

localparam IDLE  = 2'd0;
localparam START = 2'd1;
localparam DATA  = 2'd2;
localparam STOP  = 2'd3;

// Edge detection
always @(posedge clk or posedge reset) begin
    if (reset) start_prev <= 0;
    else       start_prev <= start;
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state     <= IDLE;
        tx        <= 1;
        busy      <= 0;
        clk_count <= 0;
        bit_index <= 0;
        data_reg  <= 0;
    end else begin
        case (state)

        IDLE: begin
            tx        <= 1;
            busy      <= 0;
            clk_count <= 0;
            if (start_pulse) begin      // ✅ edge-triggered, not level
                busy     <= 1;
                data_reg <= data_in;
                state    <= START;
            end
        end

        START: begin
            tx <= 0;
            if (clk_count < CLKS_PER_BIT - 1)
                clk_count <= clk_count + 1;
            else begin
                clk_count <= 0;
                bit_index <= 0;
                state     <= DATA;      // ✅ single reset of clk_count
            end
        end

        DATA: begin
            tx <= data_reg[bit_index];
            if (clk_count < CLKS_PER_BIT - 1)
                clk_count <= clk_count + 1;
            else begin
                clk_count <= 0;         // ✅ reset once here
                if (bit_index < 7)
                    bit_index <= bit_index + 1;
                else
                    state <= STOP;      // ✅ no second clk_count reset
            end
        end

        STOP: begin
            tx <= 1;
            if (clk_count < CLKS_PER_BIT - 1)
                clk_count <= clk_count + 1;
            else begin
                clk_count <= 0;
                state     <= IDLE;
                busy      <= 0;
            end
        end

        endcase
    end
end

endmodule