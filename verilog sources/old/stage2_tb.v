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
    reg clock, reset, enable;
    reg [13:0] M;    
    reg signed [14:0] N;
    // OUTPUTS
    wire [15:0] magMN;
    wire signed [12:0] atan;
    wire valid;
    
    stage2 s2(.clock(clock),
            .enable(enable),
            .rst(reset),
            .M(M),
            .N(N),
            .magMN(magMN),
            .atan(atan),
            .valid(valid));
    
    always #5 clock <= ~clock;
    
    initial begin
        clock = 0;
        enable = 0;
        reset = 0;
        #5;
        // LOAD VALUES
        M = 14'd5850;
        N = -15'd1682;
//        M = 14'd10;
//        N = -15'd10;
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
        
//        #400;
//        lx = -9'd34;
//        ly = 9'd9;
//        lz = 8'd117;
//        #15;
//        enable = 1;
//        #100;
//        enable = 0;
    end
    
endmodule
