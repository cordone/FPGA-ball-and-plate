`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2018 11:35:18 PM
// Design Name: 
// Module Name: dp_3x1_tb
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

module Rmatrix_tb;       
    reg clock;
    reg validIn;
    reg reset;
    reg [12:0] Rx, Ry;
    wire [15:0] R11, R12, R13, R21, R22, R23, R31, R32, R33;
    wire validOut;

    localparam [12:0] 
    ZERO = 13'b000_0000000000, 
    THIRTY = 13'b000_0010101010,
    NTHIRTY = 13'b111_1101010101;
    
    Rmatrix Rtest(.clock(clock),
            .validIn(validIn),
            .reset(reset),
            .Rx(Rx),
            .Ry(Ry),
            .R11(R11),
            .R12(R12),
            .R13(R13),
            .R21(R21),
            .R22(R22),
            .R23(R23),
            .R31(R31),
            .R32(R32),
            .R33(R33),
            .validOut(validOut));
    
    always #5 clock <= ~clock;
    
    initial begin
        clock = 0;
        validIn = 0;
        reset = 0;
        Rx = ZERO;
        Ry = ZERO;
        #100
        reset = 1;
        #10
        reset = 0;
        Rx = NTHIRTY; // -30 degrees
        Ry = THIRTY; // 30 degrees
        #5
        validIn = 1;
        #5
        validIn = 0;
    end
        
endmodule
