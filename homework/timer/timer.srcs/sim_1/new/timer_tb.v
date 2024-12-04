`timescale 1ns / 1ps

module tb_timer();
    reg clk;
    wire [7:0] timer;

    timer uut (
        .clk(clk),
        .timer(timer)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk; 
    end


    initial begin
        #1000; 
        $stop;
    end
endmodule
