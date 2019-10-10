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
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module stage3(input wire clock,
            input wire enable,
            input wire rst,
            input wire [15:0] L,
            input wire [15:0] magMN,
            output reg [11:0] asin,
            output reg valid);            
    
    // Use temporary working set to ignore values changing outside module.
    reg [15:0] L0;
    reg [15:0] mag0;
    wire [11:0] asin0;
    wire [31:0] divOut;
    
    // FLOW CONTROL SIGNALS
    wire divValid, asinValid;
    
    // PULSE-TO-LEVEL ENABLE
    reg running;
    
    always @(posedge clock) begin
        if (rst) begin
            L0 <= 0;
            mag0 <= 0;
            running <= 0;
        end else begin
            if (ready) begin
                running <= 0;
            end else if (enable) begin
                L0 <= L;
                mag0 <= magMN;
                running <= 1;
            end
        end
    end
    
    reg delayEnable;
    always @(posedge clock) delayEnable <= enable;
    
    // Compute normalized quotient L / mag(M, N) for arcsin lookup.
    divider div(.aclk(clock),
                .aclken(running),
                .aresetn(~rst),
                .s_axis_dividend_tready(),
                .s_axis_dividend_tdata(L0),
                .s_axis_dividend_tvalid(delayEnable),
                .s_axis_divisor_tready(),
                .s_axis_divisor_tdata(mag0),
                .s_axis_divisor_tvalid(delayEnable),
                .m_axis_dout_tdata(divOut),
                .m_axis_dout_tvalid(divValid));
                
    reg [15:0] LUTin; // L / mag(M, N) is the least sig 16 bits since its < 1
    reg asinEnable;
    always @(posedge clock) if (divValid) LUTin <= divOut[15:0];
    always @(posedge clock) asinEnable <= divValid;
    
    // Now, do the arcsin lookup.
    sintable arcsin(.i_clk(clock),
                   .i_reset(rst),
                   .i_ce(asinEnable),
                   .i_aux(),
                   .i_phase(LUTin),
                   .o_val(asin0),
                   .o_aux(),
                   .o_en(asinValid));
   
   wire ready;
   assign ready = (running && asinValid);
   
   // UPDATE LOGIC
   always @(posedge clock) begin
       if (rst) begin
           asin <= 0;
           valid <= 0;
       end else if (ready) begin
           asin <= asin0;
           valid <= 1;
       end else begin
           valid <= 0;
       end
   end
   
endmodule
