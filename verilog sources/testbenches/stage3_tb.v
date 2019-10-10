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
    reg clock, reset, validIn;
    reg [15:0] L;
    reg [15:0] magMN;
    // OUTPUT
    wire signed [15:0] LUTin;
    wire validOut;
    
    always #5 clock <= ~clock;
    
    stage3 s3(.clock(clock),
           .validIn(validIn),
           .reset(reset),
           .L(L),
           .magMN(magMN),
           .LUTin(LUTin),
           .validOut(validOut)); 
    
    initial begin
        clock = 0;
        validIn = 0;
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
        // PULSE validIn
        validIn = 1;
        #3;
        validIn = 0;
    end
    
endmodule
