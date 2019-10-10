`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2018 03:16:37 PM
// Design Name: 
// Module Name: stage1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Compute L, M, and N. 3 clock cycle input-output latency.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module stage1 #(parameter BETA = 90)(
    input wire clock,
    input wire validIn,
    input wire reset,
    input wire signed [8:0] lx, ly, lz,
    output reg signed [15:0] L,
    output reg signed [14:0] M, N,
    output reg validOut
    );

    localparam offset = 16'd13775; // s^2 - a^2 = 120^2 - 25^2 = 13775

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
    
    ///////////////////////
    // CALCULATE L
    ///////////////////////
    wire [15:0] slx, sly, slz; // to hold (255)^2
    wire signed [16:0] L0; // to hold 2*(-128)^2 + (255)^2

    square sqX(.CLK(clock),
                .CE(enable),
                .SCLR(reset),
                .A(lx),
                .B(lx),
                .P(slx));
    
    square sqY(.CLK(clock),
                .CE(enable),
                .SCLR(reset),
                .A(ly),
                .B(ly),
                .P(sly));
                
    square sqZ(.CLK(clock),
                .CE(enable),
                .SCLR(reset),
                .A(lz),
                .B(lz),
                .P(slz)); 
    
    assign L0 = (slx + sly + slz) - offset;
    
    ///////////////////////
    // CALCULATE M
    ///////////////////////
    wire signed [14:0] M0; // 14 bits necessary to hold 50 * 255

    // M <= 2a * lz
    const_mult_M M_mult(.CLK(clock),
                    .CE(enable),
                    .SCLR(reset),
                    .A(lz),
                    .P(M0));
            
    ///////////////////////
    // CALCULATE N
    ///////////////////////
    wire signed [14:0] N0;
    wire signed [23:0] n1a;
    wire signed [13:0] n1, n2;
    
    generate

        // 50 * cos(30) = 16'b101011_0100110011 = 16'd44339
        //cos(beta) = 0 0.8660254 -0.8660254
        //sin(beta) = 1 -0.5 -0.5 

        if ((BETA == 330) || (BETA == 210)) begin
           // n1 <= 2a * cos(beta) * lx 
           const_mul_N1 N1_mult(.CLK(clock),
                               .CE(enable),
                               .SCLR(reset),
                               .A(lx[7:0]),
                               .P(n1a));
           
           // n2 <= 2a * sin(beta) * ly
           const_mult_N2 N2_mult(.CLK(clock),
                               .CE(enable),
                               .SCLR(reset),
                               .A(ly[7:0]),
                               .P(n2));
           
           assign n1 = n1a >>> 10;

        end else if (BETA == 90) begin
           // n1 <= 2a * cos(90) * lx = 0
           assign n1 = 0;
           // n2 <= 2a * sin(beta) * ly = 50*ly
           const_mult_N2_90 N2_mult(.CLK(clock),
                                   .CE(enable),
                                   .SCLR(reset),
                                   .A(ly[7:0]),
                                   .P(n2));
        end 
    endgenerate

    assign N0 = (BETA == 330) ? n1 - n2 : (BETA == 90) ?  n2 : (BETA == 210) ? -n1 - n2 : 0;

    ///////////////////////
    // CONTROL LOGIC
    ///////////////////////
    localparam LATENCY = 3;
    reg [3:0] counter = 0;
    wire done;
    assign done = (enable && (counter == LATENCY));

    always @(posedge clock) validOut <= done;

    // COUNTING LOGIC
    always @(posedge clock) begin
        if (reset) begin
            counter <= 0;
        end else if (enable) begin
            counter <= (counter == LATENCY) ? 0 : counter + 1;
        end  
    end
    
    // UPDATE LOGIC
    always @(posedge clock) begin
        if (reset) begin
            L <= 0;
            M <= 0;
            N <= 0;
        end else if (done) begin
            L <= L0;
            M <= M0;
            N <= N0;
        end
    end
   
endmodule
