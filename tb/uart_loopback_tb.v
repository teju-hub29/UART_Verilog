`timescale 1ns/1ps

module uart_loopback_tb;

    reg clk, reset, start;
    reg  [7:0] data_in;
    wire tx, rx, busy, data_valid;
    wire [7:0] data_out;

    assign rx = tx;   // loopback

    uart_tx TX (.clk(clk), .reset(reset), .start(start), .data_in(data_in), .tx(tx), .busy(busy));
    uart_rx RX (.clk(clk), .reset(reset), .rx(rx), .data_out(data_out), .data_valid(data_valid));

    always #5 clk = ~clk;

    task send_and_check(input [7:0] byte_val);
        begin
            @(posedge clk);
            data_in = byte_val;
            start   = 1;
            @(posedge clk);
            start   = 0;
            wait (data_valid == 1);

            // SystemVerilog immediate assertion
            assert (data_out === byte_val)
                $display("PASS: sent 0x%0h, received 0x%0h", byte_val, data_out);
            else
                $error("FAIL: sent 0x%0h, but received 0x%0h", byte_val, data_out);

            @(posedge clk);
        end
    endtask

    initial begin
        clk = 0; reset = 1; start = 0; data_in = 0;
        #20 reset = 0;

        send_and_check(8'hA5);
        send_and_check(8'h00);
        send_and_check(8'hFF);
        send_and_check(8'h3C);

        $display("All test cases completed.");
        $finish;
    end

endmodule
