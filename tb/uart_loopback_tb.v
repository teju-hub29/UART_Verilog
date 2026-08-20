`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module uart_loopback_tb;

reg clk;
reg reset;
reg start;
reg [7:0] data_in;

wire tx;
wire rx;
wire [7:0] data_out;
wire data_valid;
wire busy;

// Loopback
assign rx = tx;

// Instantiate TX
uart_tx #(.CLKS_PER_BIT(100)) tx_unit (
    .clk(clk), .reset(reset), .start(start),
    .data_in(data_in), .tx(tx), .busy(busy)
);

// Instantiate RX
uart_rx #(.CLKS_PER_BIT(100)) rx_unit (
    .clk(clk), .reset(reset), .rx(rx),
    .data_out(data_out), .data_valid(data_valid)
);

// 100MHz clock (10ns period)
always #5 clk = ~clk;

initial begin
    clk     = 0;
    reset   = 1;
    start   = 0;
    data_in = 8'hA5;

    #200  reset = 0;   // ✅ release reset after 200ns (was too long before)
    #300  start = 1;   // ✅ wait for IDLE state to settle
    #10   start = 0;   // ✅ one-shot pulse (just 1 clock wide)

    #50000;            // ✅ wait 20µs - enough for full frame + margin
    $finish;
end

// Monitor to confirm in console
initial begin
    $monitor("Time=%0t | tx=%b | data_out=%h | data_valid=%b | busy=%b",
              $time, tx, data_out, data_valid, busy);
end

endmodule