`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2018 03:46:52 PM
// Design Name: 
// Module Name: stage3_tb
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


module stage3_tb;
    // INPUT
    reg clock, enable, reset;
    reg [15:0] L;
    reg [15:0] magMN;
    // OUTPUT
    wire signed [11:0] asin;
    wire valid;
    
    always #5 clock <= ~clock;
    
    stage3 s3(.clock(clock),
           .enable(enable),
           .rst(reset),
           .L(L),
           .magMN(magMN),
           .asin(asin),
           .valid(valid)); 
    
    initial begin
        clock = 0;
        enable = 0;
        reset = 0;
        #5;
        // LOAD VALUES
        L = 16'd1166;
        magMN = 16'd6087;
        #10;
        // RESET STAGE
        reset = 1;
        #15
        reset = 0;
        #5
        // PULSE ENABLE
        enable = 1;
        #3;
        enable = 0;
    end
    
endmodule
