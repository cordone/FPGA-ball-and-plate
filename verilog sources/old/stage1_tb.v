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
    reg clock, reset, enable;
    reg signed [8:0] lx, ly;
    reg [7:0] lz;
    // OUTPUTS
    wire [15:0] L;
    wire [13:0] M;    
    wire signed [14:0] N;
    wire valid;

    localparam BETA = 330;
    
    // Stage 1: Compute L, M and N.
    stage1 #(.BETA(BETA)) s1(.clock(clock),
                            .enable(enable),
                            .rst(reset),
                            .lx(lx),
                            .ly(ly),
                            .lz(lz),
                            .L(L),
                            .M(M),
                            .N(N),
                            .valid(valid));
    
    always #5 clock <= ~clock;
    
    initial begin
        clock = 0;
        #5;
        // LOAD VALUES
        lx = -9'd24;
        ly = 9'd26;
        lz = 8'd117;
//        lx = -9'd127;
//        ly = -9'd127;
//        lz = 8'd127;
        #10;
        // RESET STAGE
        reset = 1;
        #5
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