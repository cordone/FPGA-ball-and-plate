`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2018 03:16:37 PM
// Design Name: 
// Module Name: stage2
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


module stage2(input wire clock,
               input wire enable,
               input wire rst,
               input wire [13:0] M,
               input wire signed [14:0] N,
               output reg [15:0] magMN,
               output reg signed [12:0] atan,
               output reg valid);

    ///////////////////////
    // ACCEPT NEW INPUT DATA
    ///////////////////////
    
    // Use temporary working set to ignore values changing outside module.
    reg [13:0] M0;
    reg signed [14:0] N0;
    wire [15:0] mag0;
    wire signed [14:0] raw;
    wire signed [12:0] atan0;
    
    // FLOW CONTROL SIGNALS    
    wire hypValid, rawValid, magValid;
    
    // PULSE-TO-LEVEL ENABLE
    reg running;
    
    always @(posedge clock) begin
        if (rst) begin
            M0 <= 0;
            N0 <= 0;
            running <= 0;
        end else begin
            if (ready) begin
                running <= 0;
            end else if (enable) begin
                M0 <= M;
                N0 <= N;
                running <= 1;
            end
        end
    end
    
    reg delayEnable;
    always @(posedge clock) delayEnable <= enable;

    wire [27:0] sqM;
    wire [29:0] sqN;
    wire [30:0] hypMN;
    
    ///////////////////////
    // PYTHAGOREAN SUM
    ///////////////////////
    m_square squareM(.CLK(clock),
                    .A(M),
                    .B(M),
                    .CE(running),
                    .SCLR(rst),
                    .P(sqM));
                    
    n_square squareN(.CLK(clock),
                    .A(N),
                    .B(N),
                    .CE(running),
                    .SCLR(rst),
                    .P(sqN));
    
    assign hypMN = sqM + sqN; // 3 cycle output latency

    ///////////////////////
    // MAGNITUDE
    ///////////////////////
    sqrt magnitude(.aclk(clock),
                 .aclken(running),
                 .aresetn(~rst),
                 .s_axis_cartesian_tdata(hypMN),
                 .s_axis_cartesian_tvalid(hypValid),
                 .m_axis_dout_tdata(mag0),
                 .m_axis_dout_tvalid(magValid)); // (1 cycle per output bit = 17 cycle latency)      
    
    // M and N have the same range. N has a sign bit.
    wire signed [31:0] atanIn;
    wire signed [15:0] Y_IN, X_IN;
    // {Sign bit, integer bit, fraction bits
    assign Y_IN = {N0[14], N0[14], N0[13:0]}; // Two's complement*
    assign X_IN = {1'b0, 1'b0, M0};
//    assign Y_IN = 16'b1110000000000000;
//    assign X_IN = {16'b0010000000000000};
    assign atanIn = {Y_IN, X_IN};
    ///////////////////////
    // ARCTAN
    ///////////////////////
    arctan arctan(.aclk(clock),
              .aclken(running),
              .aresetn(~rst),
              .s_axis_cartesian_tready(),
              .s_axis_cartesian_tvalid(delayEnable), // Strange behavior without delay.
              .s_axis_cartesian_tdata(atanIn),
              .m_axis_dout_tdata(raw), // This is my output.
              .m_axis_dout_tvalid(rawValid)); // My output is valid. (1 cycle per output bit = 15 cycle latency)

    ///////////////////////
    // RESCALE ARCTAN
    ///////////////////////
    
    // Map default arctan from range [-1, 1] to [-2047, 2047].
    // Input has this fixed-point structure [1 SIGN bit, 0, 1 INTEGER bit, FRACTION bits]
    // Rescaling is actually easy because the fraction and integer ratio are equal.
    // E.g. 12 bits used for the FRACTION is conceptually equivalent to manual division by 4096.
    // At extremes -1 and 1, all fraction bits are zero.
    
    // This will never be at extremes so it's okay to just use the fraction bits.
    assign atan0 = {raw[14], raw[11:0]};
                         
    // COUNTING LOGIC                 
    reg [1:0] counter; // Longest delay is 3 + 17 = 20 cycles.
    wire ready;
    assign hypValid = (counter == 3);
    assign ready = (running && (rawValid));
    
    always @(posedge clock) begin
        if (rst) begin
            counter <= 0;
        end else if (running) begin
            counter <= (counter == 3) ? 0 : counter + 1;
        end  
    end
    
    // UPDATE LOGIC
    always @(posedge clock) begin
        if (rst) begin
            magMN <= 0;
            atan <= 0;
            valid <= 0;
        end else if (ready) begin
            magMN <= mag0;
            atan <= atan0;
            valid <= 1;
        end else begin
            valid <= 0;
        end
    end
    
endmodule
