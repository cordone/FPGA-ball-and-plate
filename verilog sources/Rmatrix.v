`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
// 
// Create Date: 12/05/2018 03:16:37 PM
// Design Name: 
// Module Name: Rmatrix
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Compute rotation matrix terms.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Rmatrix(
    input wire clock,
    input wire validIn,
    input wire reset,
    input wire signed [12:0] Rx, Ry,
    output reg signed [17:0] R11, R12, R13, R21, R22, R23, R31, R32, R33, // 18 bits to play nice with mult adder
    output reg validOut
    );
       
    reg enable;
    reg d_validIn;
    
    wire scValid;
    wire done = (enable && scValid);
    always @(posedge clock) d_validIn <= validIn;
    always @(posedge clock) validOut <= done;
    
    // PULSE-TO-LEVEL ENABLE
    always @(posedge clock) begin
        if (reset) begin
            enable <= 0;
        end else begin
            if (done) begin
                enable <= 0;
            end else if (validIn && !enable) begin
                enable <= 1;
            end
        end
    end 
    
    wire [12:0] SUM = Ry + Rx; // Rx and Ry should be limited to 30 deg.
    wire [12:0] DIFF = Ry - Rx;
    
    wire signed [31:0] dOut1, dOut2, dOut3, dOut4;
    
    wire signed [15:0] sinRX, cosRX, 
                      sinRY, cosRY, 
                      sinSUM, cosSUM,
                      sinDIFF, cosDIFF;
    
    // Have CORDIC output width be 16.
    assign sinRX = dOut1[31:16];
    assign cosRX = dOut1[15:0];
    assign sinRY = dOut2[31:16];
    assign cosRY = dOut2[15:0];
    assign sinSUM = dOut3[31:16];
    assign cosSUM = dOut3[15:0];
    assign sinDIFF = dOut4[31:16];
    assign cosDIFF = dOut4[15:0];
    
    sincos sc1(.aclk(clock),
        .aclken(enable),
        .aresetn(~reset),
        .s_axis_phase_tready(),
        .s_axis_phase_tvalid(d_validIn),
        .s_axis_phase_tdata({Rx, 3'b0}),
        .m_axis_dout_tvalid(scValid),
        .m_axis_dout_tdata(dOut1));

    sincos sc2(.aclk(clock),
        .aclken(enable),
        .aresetn(~reset),
        .s_axis_phase_tready(),
        .s_axis_phase_tvalid(d_validIn),
        .s_axis_phase_tdata({Ry, 3'b0}),
        .m_axis_dout_tvalid(),
        .m_axis_dout_tdata(dOut2));

    sincos sc3(.aclk(clock),
        .aclken(enable),
        .aresetn(~reset),
        .s_axis_phase_tready(),
        .s_axis_phase_tvalid(d_validIn),
        .s_axis_phase_tdata({SUM, 3'b0}),
        .m_axis_dout_tvalid(),
        .m_axis_dout_tdata(dOut3));
        
    sincos sc4(.aclk(clock),
        .aclken(enable),
        .aresetn(~reset),
        .s_axis_phase_tready(),
        .s_axis_phase_tvalid(d_validIn),
        .s_axis_phase_tdata({DIFF, 3'b0}),
        .m_axis_dout_tvalid(),
        .m_axis_dout_tdata(dOut4));
    
    // OUTPUT
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            R11 <= 0;
            R12 <= 0;
            R13 <= 0;
            R21 <= 0;
            R22 <= 0;
            R23 <= 0;
            R31 <= 0;
            R32 <= 0;
            R33 <= 0;
        end else if (done) begin
            R11 <= cosRY;
            R12 <= (cosDIFF - cosSUM) >>> 1;
            R13 <= (sinSUM + sinDIFF) >>> 1;
            R21 <= 0;
            R22 <= cosRX;
            R23 <= -sinRX;
            R31 <= -sinRY;
            R32 <= (sinSUM - sinDIFF) >>> 1;
            R33 <= (cosSUM + cosDIFF) >>> 1;
        end
    end

endmodule