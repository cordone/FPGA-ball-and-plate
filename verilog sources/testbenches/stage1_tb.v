`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2018 04:16:27 PM
// Design Name: 
// Module Name: stage1_tb
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


module stage1_tb;
    // INPUTS
    reg clock, reset, validIn;
    reg signed [8:0] lx, ly, lz;
    // OUTPUTS
    wire [15:0] L;
    wire [13:0] M;    
    wire signed [14:0] N;
    wire validOut;

    localparam BETA = 90;
    
    // Stage 1: Compute L, M and N.
    stage1 #(.BETA(BETA)) s1(.clock(clock),
                            .validIn(validIn),
                            .reset(reset),
                            .lx(lx),
                            .ly(ly),
                            .lz(lz),
                            .L(L),
                            .M(M),
                            .N(N),
                            .validOut(validOut));
    
    always #5 clock <= ~clock;
    
    initial begin
        clock = 0;
        validIn = 0;
        reset = 0;
        #5;
        // LOAD VALUES
        lx = -9'd10;
        ly = -9'd34;
        lz = 9'd117;
        #10;
        // RESET STAGE
        reset = 1;
        #5
        reset = 0;
        #5
        // Pulse validIn
        validIn = 1;
        #3;
        validIn = 0;
    end
    
endmodule