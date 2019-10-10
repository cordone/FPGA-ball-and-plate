`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2018 06:11:17 PM
// Design Name: 
// Module Name: stg_one_to_three_tb
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


module stage2_tb;
    // INPUTS
    reg clock, reset, validIn;
    reg [13:0] M;    
    reg signed [14:0] N;
    // OUTPUTS
    wire [15:0] magMN;
    wire signed [12:0] atan;
    wire validOut;
    
    stage2 s2(.clock(clock),
            .validIn(validIn),
            .reset(reset),
            .M(M),
            .N(N),
            .magMN(magMN),
            .atan(atan),
            .validOut(validOut));
    
    always #5 clock <= ~clock;
    
    initial begin
        clock = 0;
        validIn = 0;
        reset = 0;
        #5;
        // LOAD VALUES
        M = 14'd5850;
        N = -15'd1700;
        #10;
        // RESET STAGE
        reset = 1;
        #10
        reset = 0;
        #10
        // PULSE validIn
        validIn = 1;
        #3;
        validIn = 0;
    end
    
endmodule
