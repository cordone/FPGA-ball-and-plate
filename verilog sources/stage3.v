`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2018 03:16:37 PM
// Design Name: 
// Module Name: stage3
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Compute asin(L/sqrt(M^2+N^2))
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module stage3(
    input wire clock,
    input wire validIn,
    input wire reset,
    input wire signed [15:0] L,
    input wire signed [15:0] magMN,
    output reg signed [16:0] LUTin,
    output reg validOut
    );            
    
    wire [31:0] divOut;
    wire divValid, asinValid;
    
    // PULSE-TO-LEVEL ENABLE
    reg divEnable;
    always @(posedge clock)
    begin
        if (reset) begin
            divEnable <= 0;
        end else begin
            if (divValid) begin
                divEnable <= 0;
            end else if (validIn && ~divEnable) begin
                divEnable <= 1;
            end
        end
    end
        
    // Compute normalized quotient L / mag(M, N) for arcsin lookup.
    divider div(.aclk(clock),
                .aclken(divEnable),
                .aresetn(~reset),
                .s_axis_dividend_tready(),
                .s_axis_dividend_tdata(L),
                .s_axis_dividend_tvalid(divEnable),
                .s_axis_divisor_tready(),
                .s_axis_divisor_tdata(magMN),
                .s_axis_divisor_tvalid(divEnable),
                .m_axis_dout_tdata(divOut),
                .m_axis_dout_tvalid(divValid));
    
   always @(posedge clock) validOut <= divValid;
   
   always @(posedge clock) LUTin <= {divOut[15], divOut};
   
endmodule
