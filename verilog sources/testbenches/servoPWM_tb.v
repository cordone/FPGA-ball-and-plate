`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2018 03:09:23 PM
// Design Name: 
// Module Name: servoPWM_tb
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

module servoPWM_tb;
    reg clock;
    reg enable;
    reg reset;
    reg [11:0] angle;
    wire pwm;
    
    servoPWM #(.SERVOMIN(124),
               .SERVOMAX(543),
               .REVERSED(0)) testPWM(.clock(clock),
                                    .enable(enable),
                                    .reset(reset),
                                    .angle(angle),
                                    .pwm(pwm));
        
    
    initial begin
        clock = 0;
        reset = 0;
        #5;
        // LOAD VALUES
        angle = 12'd2048;
        #10;
        // RESET
        reset = 1;
        #5
        reset = 0;
        #5
        // ENABLE
        enable = 1;
    end
    
    always #8 clock <= ~clock;
    
endmodule