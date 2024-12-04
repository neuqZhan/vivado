`timescale 1ns / 1ps

module timer (
    input clk,                
    output reg [7:0] timer    
);

    initial begin
        timer = 8'b0;
    end

    always @(posedge clk) begin
        timer <= timer + 1;
    end

endmodule
