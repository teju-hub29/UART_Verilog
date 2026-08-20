`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////

module uart_rx_tb;

reg clk = 0;
reg reset;
reg rx;

wire [7:0] data_out;
wire data_valid;

// Instantiate RX
uart_rx uut (
    .clk(clk),
    .reset(reset),
    .rx(rx),
    .data_out(data_out),
    .data_valid(data_valid)
);

// Clock
always #5 clk = ~clk;

// Task to send UART frame
task send_byte(input [7:0] data);
integer i;
begin
    rx = 0; // start
    #1000; // 9600 baud delay

    for (i = 0; i < 8; i = i + 1) begin
        rx = data[i];
        #1000;
    end

    rx = 1; // stop
    #1000;
end
endtask

initial begin
    reset = 1;
    rx = 1;

    #100 reset = 0;

    send_byte(8'hA5);

    #2000000 $finish;
end

endmodule