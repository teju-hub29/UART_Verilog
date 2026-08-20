`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module uart_tx_tb;

reg clk = 0;
reg reset;
reg start;
reg [7:0] data_in;

wire tx;
wire busy;

// Instantiate TX
uart_tx uut (
    .clk(clk),
    .reset(reset),
    .start(start),
    .data_in(data_in),
    .tx(tx),
    .busy(busy)
);

// Clock generation
always #5 clk = ~clk; // 50MHz

initial begin
    reset = 1;
    start = 0;
    data_in = 8'hA5;

    #20 reset = 0;

    #20 start = 1;
    #10  start = 0;

    #2000000 $finish;
end

endmodule