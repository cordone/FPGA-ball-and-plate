`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2018 03:24:33 PM
// Design Name: 
// Module Name: servo_angle_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Transforms a leg length vector into a servo angle command.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module servo_angle_gen(input wire clock,
                    input wire validIn,
                    input wire reset,
                    input wire signed [8:0] lx, ly, lz,
                    output reg signed [16:0] LUTin,
                    output reg signed [12:0] atan,
                    output reg validOut);

    // Angle between servo centerline and the x-axis of the base.
    parameter BETA = 90;

    wire signed [15:0] L, magMN; 
    wire signed [14:0] M, N;
    wire signed [12:0] atan0;
    wire signed [16:0] LUTin0;
        
    // Enables for state machine operation.    
    wire s1Valid, s2Valid, s3Valid;
    
    // Stage 1: Compute L, M and N.
    stage1 #(.BETA(BETA)) 
        s1(.clock(clock),
            .validIn(validIn),
            .reset(reset),
            .lx(lx),
            .ly(ly),
            .lz(lz),
            .L(L),
            .M(M),
            .N(N),
            .validOut(s1Valid));
    
    // Stage 2: Compute sqrt(M^2 + N^2) and atan2(N/M).
    stage2 s2(.clock(clock),
            .reset(reset),
            .validIn(s1Valid),
            .M(M),
            .N(N),
            .magMN(magMN),
            .atan(atan0),
            .validOut(s2Valid));
    
    // Stage 3: Compute L / sqrt(M^2 + N^2) and arcsin LUT input.
    stage3 s3(.clock(clock),
            .reset(reset),
            .validIn(s2Valid),
            .L(L),
            .magMN(magMN),
            .LUTin(LUTin0),
            .validOut(s3Valid));
            
    always @(posedge clock) validOut <= s3Valid;
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            atan <= 0;
            LUTin <= 0;
        end else if (s3Valid) begin
            atan <= atan0;
            LUTin <= LUTin0;
        end
    end
    
endmodule
