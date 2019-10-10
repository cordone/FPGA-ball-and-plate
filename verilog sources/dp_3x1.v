`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
// 
// Create Date: 12/05/2018 03:16:37 PM
// Design Name: 
// Module Name: dp_3x1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Computes fixed-point dot product between two 3x1 vectors using.
// 				single Multiply-Adder DSP slice.
//								[a1 a2 a3] * [b1 b2 b3]'
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module dp_3x1 #(parameter A_WIDTH = 18, B_WIDTH = 18)(
	input wire clock,
	input wire validIn,
	input wire reset,
	input wire signed [A_WIDTH-1:0] A1,
	input wire signed [A_WIDTH-1:0] A2,
	input wire signed [A_WIDTH-1:0] A3,
	input wire signed [B_WIDTH-1:0] B1,
	input wire signed [B_WIDTH-1:0] B2,
	input wire signed [B_WIDTH-1:0] B3,
	output reg signed [A_WIDTH+B_WIDTH:0] dp,
	output reg validOut
	);
  
  	localparam LATENCY = 3;
    reg [2:0] counter;
    reg enable;  
	wire signed [47:0] P1, P2, P3;
    
    pair_mult ONE(.CLK(clock),
        .CE(enable),
        .SCLR(reset || validIn),
        .A(A1),
        .B(B1),
        .P(P1));
    
    pair_mult TWO(.CLK(clock),
        .CE(enable),
        .SCLR(reset || validIn),
        .A(A2),
        .B(B2),
        .P(P2));
                
    pair_mult THREE(.CLK(clock),
        .CE(enable),
        .SCLR(reset || validIn),
        .A(A3),
        .B(B3),
        .P(P3));
        
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
                                               
    // PULSE-TO-ENABLE
    wire done;
    assign done = (enable && (counter == LATENCY));

    always @(posedge clock) validOut <= done;

    // COUNTING LOGIC
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            counter <= 0;
        end else if (enable) begin
            counter <= (counter == LATENCY) ? 0 : counter + 1;
        end  
    end
    
    wire [47:0] SUM = P1 + P2 + P3;
    
    // UPDATE LOGIC
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            dp <= 0;
        end else if (done) begin
            dp <= SUM[A_WIDTH+B_WIDTH:0];
        end
    end
   
endmodule