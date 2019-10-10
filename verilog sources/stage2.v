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
// Description: Compute sqrt(M^2 + N^2) and atan2(N/M)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module stage2(
    input wire clock,
    input wire validIn,
    input wire reset,
    input wire signed [14:0] M, N,
    output reg signed [15:0] magMN,
    output reg signed [12:0] atan,
    output reg validOut);

    wire [16:0] mag0;
    wire signed [14:0] atan0;
    wire hypValid, magValid, atanValid;
    
    // PULSE-TO-LEVEL ENABLE
    reg enable;
    always @(posedge clock) begin
        if (reset) begin
            enable <= 0;
        end else begin
            if (done) begin
                enable <= 0;
            end else if (validIn && ~enable) begin
                enable <= 1;
            end
        end
    end

    wire [29:0] sqM, sqN;
    wire [31:0] hypMN;
    
    ///////////////////////
    // PYTHAGOREAN SUM
    ///////////////////////
    squareMN squareM(.CLK(clock),
                    .A(M),
                    .B(M),
                    .CE(enable),
                    .SCLR(reset),
                    .P(sqM));
                    
    squareMN squareN(.CLK(clock),
                    .A(N),
                    .B(N),
                    .CE(enable),
                    .SCLR(reset),
                    .P(sqN));
    
    assign hypMN = sqM + sqN; // 3 cycle output latency

    ///////////////////////
    // MAGNITUDE
    ///////////////////////
    sqrt magnitude(.aclk(clock),
                 .aclken(enable),
                 .aresetn(~reset),
                 .s_axis_cartesian_tdata(hypMN),
                 .s_axis_cartesian_tvalid(hypValid),
                 .m_axis_dout_tdata(mag0),
                 .m_axis_dout_tvalid(magValid)); // (1 cycle per output bit = 17 cycle latency)      
    
    ///////////////////////
    // ARCTAN
    ///////////////////////

    reg d_validIn;
    always @(posedge clock) d_validIn <= validIn;

    wire signed [15:0] Y_IN, X_IN;
    wire signed [31:0] atanIn;
    assign Y_IN = {N[14], N[14], N[13:0]};
    assign X_IN = {M[14], M[14], M[13:0]};
    assign atanIn = {Y_IN, X_IN};

    arctan arctan(.aclk(clock),
              .aclken(enable),
              .aresetn(~reset),
              .s_axis_cartesian_tready(),
              .s_axis_cartesian_tvalid(enable),
              .s_axis_cartesian_tdata(atanIn),
              .m_axis_dout_tdata(atan0),
              .m_axis_dout_tvalid(atanValid)); // (1 cycle per output bit = 15 cycle latency)

    // Make sure arctan output is set to SCALED RADIANS.
    // It means the arctan is normalized to [-1, 1]  
                 
    // COUNTING LOGIC     
    reg [1:0] counter;
    wire done;
    assign hypValid = (counter == 3);
    assign done = (enable && (atanValid));

    always @(posedge clock) validOut <= done;
    
    always @(posedge clock) begin
        if (reset) begin
            counter <= 0;
        end else if (enable) begin
            counter <= (counter == 3) ? 0 : counter + 1;
        end  
    end

    // OUTPUT LOGIC
    always @(posedge clock) begin
        if (reset) begin
            magMN <= 0;
            atan <= 0;
        end else if (done) begin
            magMN <= mag0;
            atan <= {atan0[14], atan0[12:0]}; // Drop extra bit.
        end
    end
    
endmodule
